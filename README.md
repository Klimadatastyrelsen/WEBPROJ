# WEBPROJ

WEBPROJ is a REST API that transforms coordinates between the coordinate
reference systems used in Denmark and Greenland. The production version runs
as part of [Dataforsyningen](https://dataforsyningen.dk). To use the API you
need a Dataforsyningen token.

How to use the API (Danish): [docs/site/api/index.md](docs/site/api/index.md).

## Development

You can use [uv](https://docs.astral.sh/uv/) or [conda](https://anaconda.org/anaconda/conda).
Pick uv if you care about alignment with production.

### uv

Install the dependencies and the datum grids:

```bash
uv venv
uv pip install -e '.[dev]'
uv run pyproj sync --source-id dk_sdfe
uv run pyproj sync --source-id dk_sdfi
uv run pyproj sync --source-id dk_kds
```

Start the local server on `http://127.0.0.1:8000/`:

```bash
uv run fastapi dev src/app/main.py
```

Run the tests:

```bash
uv run pytest
```

### Conda

```bash
conda env create -f environment-dev.yaml
conda activate webproj
projsync --source-id dk_sdfe
projsync --source-id dk_sdfi
projsync --source-id dk_kds
pytest
```

### Docker

```bash
docker build -t webproj .
docker run -p 8000:8080 webproj
curl 127.0.0.1:8000/v1.2/info/
```

## OpenAPI spec

The running API serves interactive documentation at `/documentation` and the
spec at `/openapi.json`.

A copy of the spec is committed as `openapi.json` in the repository root.
The KDS documentation site syncs it, together with the pages in `docs/site/`,
from this repository. When the API or `__version__` changes, regenerate it
with `python scripts/export_openapi.py` and commit the result. CI fails if
the committed file is out of date.

## Releases

See [HOWTORELEASE.md](HOWTORELEASE.md).
