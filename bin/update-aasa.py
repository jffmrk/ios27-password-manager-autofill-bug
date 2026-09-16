#!/usr/bin/env python3
"""Write docs/.well-known/apple-app-site-association from Xcode build settings."""

import json
import os
import sys
from pathlib import Path


def require(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        sys.exit(f"error: {name} is empty. Select a Development Team in Signing & Capabilities.")
    return value


def main() -> None:
    srcroot = os.environ.get("SRCROOT", "").strip()
    if not srcroot:
        sys.exit("error: SRCROOT is not set. Run this from an Xcode Run Script build phase.")

    team = require("DEVELOPMENT_TEAM")
    bundle = require("PRODUCT_BUNDLE_IDENTIFIER")
    app_id = f"{team}.{bundle}"

    association = {
        "webcredentials": {"apps": [app_id]},
        "applinks": {
            "details": [
                {
                    "appIDs": [app_id],
                    "components": [{"/": "*", "comment": "Open every path in the app."}],
                }
            ]
        },
    }

    path = Path(srcroot) / "docs" / ".well-known" / "apple-app-site-association"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(association, indent=2) + "\n")
    print(f"Updated {path} with {app_id}")


if __name__ == "__main__":
    main()
