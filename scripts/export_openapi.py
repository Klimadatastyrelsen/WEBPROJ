#!/usr/bin/env python
# no server: the app describes itself, so this needs neither proj grids nor env
import json
from pathlib import Path

from webproj.api import app

OUT = Path(__file__).resolve().parent.parent / "openapi.json"


def main() -> None:
    # sorted keys and a trailing newline, so a change to the contract reads as a diff
    spec = json.dumps(app.openapi(), indent=2, sort_keys=True, ensure_ascii=False)
    OUT.write_text(spec + "\n", encoding="utf-8")
    print(f"[+] wrote {OUT}")


if __name__ == "__main__":
    main()
