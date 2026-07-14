#!/usr/bin/env python3
"""feature_list.py — the only way to mutate feature_list.json.

This script is the mandatory interface for any operation on
feature_list.json: listing features, marking them passing, adding new
features, and updating metadata. Direct editing of feature_list.json
(scripts, sed, manual) is a Hard Rule violation in CODE_STYLE.md.

All commands are read-modify-write on the same JSON file and keep the
file's formatting (2-space indent). The script exits non-zero on errors
so coding agents can detect failures.

Usage:
    python tools/feature_list.py <command> [args]

Commands:
    list
        Print every feature as one line (id, category, passes, priority,
        description). Useful for agents or humans to scan.

    mark-passing <feature_id>
        Set the feature's "passes" to true. Recomputes metadata
        (total_features / passing / failing / last_updated). Refuses
        if the id does not exist or the feature already passes.

    add <feature_id> <category> <description>
        Append a new feature with the given id, category, and a
        single-line description. Generates empty steps[] and sets
        passes=false. Refuses on duplicate id.

    update-metadata
        Recompute total_features / passing / failing from the current
        features[] and stamp last_updated to today. Use this after any
        manual repair (rare) or to force a freshness update.

Categories: functional, ui, error-handling, accessibility, performance.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import date
from pathlib import Path
from typing import Any

FEATURE_LIST_PATH = Path("feature_list.json")
VALID_CATEGORIES = {"functional", "ui", "error-handling", "accessibility", "performance"}
INDENT = 2


# ---------- I/O helpers ----------

def load_features() -> dict[str, Any]:
    """Read feature_list.json. Exits with a clear error if missing or malformed."""
    if not FEATURE_LIST_PATH.exists():
        fail(f"{FEATURE_LIST_PATH} not found. Are you in the project root?")
    try:
        with FEATURE_LIST_PATH.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        fail(f"{FEATURE_LIST_PATH} is not valid JSON: {e}")
    if "features" not in data or not isinstance(data["features"], list):
        fail(f"{FEATURE_LIST_PATH} must contain a 'features' array.")
    return data


def save_features(data: dict[str, Any]) -> None:
    """Write feature_list.json with stable formatting."""
    with FEATURE_LIST_PATH.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=INDENT, ensure_ascii=False)
        f.write("\n")


def recompute_metadata(data: dict[str, Any]) -> None:
    """Recompute aggregate counters and stamp last_updated."""
    features = data["features"]
    data["metadata"] = {
        "total_features": len(features),
        "passing": sum(1 for f in features if f.get("passes") is True),
        "failing": sum(1 for f in features if f.get("passes") is False),
        "last_updated": date.today().isoformat(),
    }


# ---------- commands ----------

def cmd_list(_: argparse.Namespace) -> None:
    data = load_features()
    if not data["features"]:
        print("(no features yet)")
        return
    for f in data["features"]:
        marker = "x" if f.get("passes") else " "
        print(
            f"[{marker}] {f.get('id', '???'):<12} "
            f"{f.get('category', '???'):<16} "
            f"pri={f.get('priority', '-'):<6} {f.get('description', '')}"
        )


def cmd_mark_passing(args: argparse.Namespace) -> None:
    data = load_features()
    target_id = args.feature_id
    for f in data["features"]:
        if f.get("id") == target_id:
            if f.get("passes") is True:
                fail(f"feature {target_id!r} already passes.")
            f["passes"] = True
            recompute_metadata(data)
            save_features(data)
            print(
                f"marked {target_id} passing "
                f"({data['metadata']['passing']}/{data['metadata']['total_features']} now passing)"
            )
            return
    fail(f"feature id {target_id!r} not found.")


def cmd_add(args: argparse.Namespace) -> None:
    data = load_features()
    new_id = args.feature_id
    category = args.category
    if category not in VALID_CATEGORIES:
        fail(f"invalid category {category!r}. Choose one of: {sorted(VALID_CATEGORIES)}")
    if any(f.get("id") == new_id for f in data["features"]):
        fail(f"feature id {new_id!r} already exists.")
    data["features"].append({
        "id": new_id,
        "category": category,
        "description": args.description,
        "steps": [],
        "passes": False,
        "priority": args.priority or "medium",
    })
    recompute_metadata(data)
    save_features(data)
    print(f"added feature {new_id} ({category})")


def cmd_update_metadata(_: argparse.Namespace) -> None:
    data = load_features()
    recompute_metadata(data)
    save_features(data)
    print(f"metadata updated: {data['metadata']}")


# ---------- entry point ----------

def fail(msg: str) -> None:
    """Print an error to stderr and exit with a non-zero status."""
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="feature_list.py",
        description="Mandatory interface to feature_list.json. "
                    "Direct edits are forbidden by CODE_STYLE.md.",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list", help="Print all features.")
    p_list.set_defaults(func=cmd_list)

    p_pass = sub.add_parser("mark-passing", help="Mark a feature passes=true.")
    p_pass.add_argument("feature_id")
    p_pass.set_defaults(func=cmd_mark_passing)

    p_add = sub.add_parser("add", help="Append a new feature.")
    p_add.add_argument("feature_id")
    p_add.add_argument("category", choices=sorted(VALID_CATEGORIES))
    p_add.add_argument("description")
    p_add.add_argument("--priority", choices=["high", "medium", "low"],
                       help="Default: medium")
    p_add.set_defaults(func=cmd_add)

    p_meta = sub.add_parser("update-metadata",
                            help="Recompute metadata (use after manual edits).")
    p_meta.set_defaults(func=cmd_update_metadata)

    return parser


def main(argv: list[str] | None = None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    if not argv:
        fail("no command given. Try: list / mark-passing / add / update-metadata")
    parser = build_parser()
    args = parser.parse_args(argv)
    args.func(args)
    return 0


if __name__ == "__main__":
    sys.exit(main())