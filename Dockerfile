FROM condaforge/miniforge3:26.1.1-3

# We store PROJ ressources in $WEBPROJ_LIB
ENV WEBPROJ_LIB=/proj
RUN mkdir $WEBPROJ_LIB

# Copy necessary files. Tests and README are needed by setup.py
COPY /src/webproj /webproj/src/webproj
COPY /src/app /webproj/src/app
COPY /tests /webproj/tests
COPY /pyproject.toml /webproj/pyproject.toml
COPY /environment.yaml /webproj/environment.yaml
COPY /README.md /webproj/README.md

WORKDIR /webproj

# Running upgrade for security
RUN apt-get update -y && apt-get upgrade -y

# Set up virtual environment
RUN conda env create -f environment.yaml

# Install webproj in conda environment
RUN conda run -n webproj pip install /webproj/

# Sync PROJ-data files
RUN conda run -n webproj pyproj sync --source-id dk_sdfe --target-dir $WEBPROJ_LIB
RUN conda run -n webproj pyproj sync --source-id dk_sdfi --target-dir $WEBPROJ_LIB
RUN conda run -n webproj pyproj sync --source-id dk_kds  --target-dir $WEBPROJ_LIB

CMD ["conda", "run", "-n", "webproj", "uvicorn", "--proxy-headers", "app.main:app", "--host", "0.0.0.0", "--port", "80"]

EXPOSE 80
