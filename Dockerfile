#
# this dockerfile builds proj from source, because pyproj
# natively lags its bundled proj (a couple of minor versions at time of writing)
# additionally, we enforce k8s-friendly security defaults
# to work safely and efficiently in a rootless, read-only context
#

# STAGE 1: BUILDER - proj built from source and pyproj linked against it

FROM python:3.14-slim-trixie AS builder

ARG PROJ_VERSION=9.8.1
ARG PROJ_SHA256=af5b731c145c1d13c4e3b4eeb7d167e94e845e440f71e3496b4ed8dae0291960

ENV PROJ_DIR=/opt/proj \
    PROJ_DATA=/opt/proj/share/proj \
    LD_LIBRARY_PATH=/opt/proj/lib \
    PATH=/opt/venv/bin:$PATH

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config \
      libsqlite3-dev libtiff-dev libcurl4-openssl-dev \
      sqlite3 ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# build proj from source. BUILD_APPS=OFF drops projinfo/cs2cs
# api never calls this, and skipping shrinks runtime payload
WORKDIR /build
RUN curl -fsSL -o proj.tar.gz "https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz" \
 && echo "${PROJ_SHA256}  proj.tar.gz" | sha256sum -c - \
 && tar xzf proj.tar.gz \
 && cmake -S "proj-${PROJ_VERSION}" -B build \
      -DCMAKE_INSTALL_PREFIX=/opt/proj \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=OFF \
      -DBUILD_APPS=OFF \
 && cmake --build build -j"$(nproc)" \
 && cmake --install build \
 && rm -rf /build

# isolated venv
RUN python -m venv /opt/venv

WORKDIR /src
COPY pyproject.toml README.md ./
COPY src ./src
RUN pip install --no-binary pyproj .

# pre-sync DK datum grids into data dir
RUN mkdir -p /proj \
 && pyproj sync --source-id dk_sdfe --target-dir /proj \
 && pyproj sync --source-id dk_sdfi --target-dir /proj \
 && pyproj sync --source-id dk_kds  --target-dir /proj

# strip pip + setuptools from the venv; runtime never installs anything
RUN rm -rf /opt/venv/lib/python*/site-packages/pip \
           /opt/venv/lib/python*/site-packages/pip-*.dist-info \
           /opt/venv/lib/python*/site-packages/setuptools \
           /opt/venv/lib/python*/site-packages/setuptools-*.dist-info \
           /opt/venv/lib/python*/site-packages/_distutils_hack \
           /opt/venv/lib/python*/site-packages/pkg_resources \
           /opt/venv/bin/pip*


# STAGE 2: RUNTIME - just what we need, and nothing more

FROM python:3.14-slim-trixie

# 1) wire pyproj to the source-built proj at /opt/proj
# 2) don't write __pycache__/*.pyc - respect read-only fs
# 3) force stdout/stderr to flush per-line for observability
ENV WEBPROJ_LIB=/proj \
    PROJ_DATA=/opt/proj/share/proj \
    PATH=/opt/venv/bin:$PATH \
    LD_LIBRARY_PATH=/opt/proj/lib \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends libsqlite3-0 libtiff6 libcurl4 \
 && rm -rf /var/lib/apt/lists/*

# rootless runtime user, mathces a proper helm securitycontext
RUN groupadd --system --gid 10001 webproj \
 && useradd --system --uid 10001 --gid webproj --no-create-home webproj

COPY --from=builder --chown=webproj:webproj /opt/proj /opt/proj
COPY --from=builder --chown=webproj:webproj /opt/venv /opt/venv
COPY --from=builder --chown=webproj:webproj /proj /proj

USER webproj

# 8080 to avoid privileged ports
EXPOSE 8080
CMD ["uvicorn", "--proxy-headers", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
