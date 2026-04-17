#!/usr/bin/env python3
"""Emit a small CI manifest consumed as an artifact (polyglot tooling hook)."""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument(
        "-o",
        "--output",
        default="manifest.json",
        help="Write JSON manifest to this path (default: manifest.json)",
    )
    args = p.parse_args()

    manifest = {
        "generated": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "project": "IntegratedDevEnv",
        "components": ["ios", "go", "python"],
        "note": "CI fan-out hook — not a product feature.",
    }
    text = json.dumps(manifest, indent=2) + "\n"
    sys.stdout.write(text)
    with open(args.output, "w", encoding="utf-8") as f:
        f.write(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
