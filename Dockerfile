FROM python:3.14-slim-trixie

# 1) skip pip cache at runtime to keep image lean
# 2) don't write __pycache__/*.pyc - respect read-only fs
# 3) force stdout/stderr to flush per-line for observability
ENV WEBPROJ_LIB=/proj \
    PIP_NO_CACHE_DIR=1 \ 
    PYTHONDONTWRITEBYTECODE=1 \ 
    PYTHONUNBUFFERED=1

# set up for rootless runtime
RUN groupadd --system --gid 10001 webproj \
 && useradd --system --uid 10001 --gid webproj --no-create-home webproj \
 && mkdir -p $WEBPROJ_LIB

WORKDIR /webproj

COPY src ./src
COPY pyproject.toml README.md ./

RUN pip install . \
 && pyproj sync --source-id dk_sdfe --target-dir $WEBPROJ_LIB \
 && pyproj sync --source-id dk_sdfi --target-dir $WEBPROJ_LIB \
 && pyproj sync --source-id dk_kds  --target-dir $WEBPROJ_LIB \
 && chown -R webproj:webproj $WEBPROJ_LIB /webproj

USER webproj

# 8080 to avoid privileged ports
EXPOSE 8080
CMD ["uvicorn", "--proxy-headers", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
