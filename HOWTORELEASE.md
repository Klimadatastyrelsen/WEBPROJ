# Release instructions for WEBPROJ

1. Checkout maintenance branch

If issueing a patch release a maintenance branch should already exists. Check it out:

```
git checkout 1.1
```

and ensure sure that all relevant commits have been backported to the maintenance branch in question.

If a major or minor version release is being prepared, a new maintenance branch based on the
master branch needs to be created:

```
git checkout -b 1.1
```

2. Tag the latest commit on the the maintenance branch with the new version number

On the maintenance branch the latest commit can now be tagged with the version number, e.g.:

```
git tag 1.1.1
git push --tags
```

3. Close the GitHub milestone for the version to be released

4. Write release notes on GitHub based on the tag created in step 2

5. Bump version number

We update the version number right away in preparation for the next release. This way we can distinguish
between released versions and to-be-released versions easily. If we see an unrelease version number we know
that we are using a development version of WEBPROJ.

`__version__` in `src/webproj/__init__.py` needs to be updated. After a patch release the version number is only updated on the maintenance branch. After a major or minor release it should be updated on the master branch and subsequently cherry-picked to the maintenance branch.

The version number is part of the OpenAPI spec. Regenerate `openapi.json` with `python scripts/export_openapi.py` and commit it together with the version bump, or CI fails.

6. Deploy to production

Pushing the tag in step 2 triggers `.github/workflows/release.yml`. This builds the container image and packages the Helm chart with matching version/appVersion, then pushes both to GHCR:

- `ghcr.io/klimadatastyrelsen/webproj:<version>`
- `oci://ghcr.io/klimadatastyrelsen/charts/webproj:<version>`

Production k8s clusters watching these artifacts will reconcile automatically, or when an operator bumps the version pin manually.

### Update the documentation
The KDS documentation site syncs the pages in `docs/site/` and the committed `openapi.json` from this repository. Keep `openapi.json` current (see step 5).
