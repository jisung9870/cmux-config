#!/usr/bin/env python3
"""Build generated cmux.json from config.d JSON fragments."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG_DIR = REPO_ROOT / "config.d"
OUTPUT_PATH = REPO_ROOT / "cmux.json"

BASE_ORDER = [
    "app.json",
    "terminal.json",
    "notifications.json",
    "sidebar.json",
    "automation.json",
    "browser.json",
    "workspace-groups.json",
    "shortcuts.json",
    "viewers.json",
]

COMMAND_ORDER = [
    "tools.json",
    "dev.json",
    "ops.json",
]


def load_json(path: Path):
    try:
        with path.open(encoding="utf-8") as f:
            return json.load(f)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"{path}: invalid JSON: {exc}") from exc


def ordered_json_files(
    directory: Path,
    preferred_order: list[str] | None = None,
    require_preferred: bool = False,
) -> list[Path]:
    files = sorted(directory.glob("*.json"))
    if preferred_order is None:
        return files

    by_name = {path.name: path for path in files}
    if require_preferred:
        missing = [name for name in preferred_order if name not in by_name]
        if missing:
            raise SystemExit(
                f"{directory}: missing expected fragment(s): {', '.join(missing)}"
            )

    ordered = [by_name.pop(name) for name in preferred_order if name in by_name]
    ordered.extend(by_name[name] for name in sorted(by_name))
    return ordered


def merge_top_level(config: dict, path: Path) -> None:
    fragment = load_json(path)
    if not isinstance(fragment, dict):
        raise SystemExit(f"{path}: expected top-level object")

    for key, value in fragment.items():
        if key in config:
            raise SystemExit(f"{path}: duplicate top-level key {key!r}")
        config[key] = value


def merge_actions(config: dict, path: Path) -> None:
    fragment = load_json(path)
    if not isinstance(fragment, dict):
        raise SystemExit(f"{path}: expected action object")

    actions = config.setdefault("actions", {})
    for key, value in fragment.items():
        if key in actions:
            raise SystemExit(f"{path}: duplicate action key {key!r}")
        actions[key] = value


def load_ui(path: Path) -> dict:
    ui = load_json(path)
    if not isinstance(ui, dict):
        raise SystemExit(f"{path}: expected ui object")
    return ui


def load_commands(path: Path) -> list:
    commands = load_json(path)
    if not isinstance(commands, list):
        raise SystemExit(f"{path}: expected command array")
    return commands


def build_config() -> dict:
    config: dict = {}

    for path in ordered_json_files(CONFIG_DIR / "base", BASE_ORDER, require_preferred=True):
        merge_top_level(config, path)

    for path in ordered_json_files(CONFIG_DIR / "actions"):
        merge_actions(config, path)

    ui_path = CONFIG_DIR / "ui" / "main.json"
    if "ui" in config:
        raise SystemExit(f"{ui_path}: duplicate top-level key 'ui'")
    config["ui"] = load_ui(ui_path)

    seen_command_names: set[str] = set()
    commands = []
    for path in ordered_json_files(
        CONFIG_DIR / "commands", COMMAND_ORDER, require_preferred=True
    ):
        for command in load_commands(path):
            if not isinstance(command, dict):
                raise SystemExit(f"{path}: each command must be an object")
            name = command.get("name")
            if not isinstance(name, str) or not name:
                raise SystemExit(f"{path}: each command must have a non-empty string name")
            if name in seen_command_names:
                raise SystemExit(f"{path}: duplicate command name {name!r}")
            seen_command_names.add(name)
            commands.append(command)

    if "commands" in config:
        raise SystemExit("duplicate top-level key 'commands'")
    config["commands"] = commands
    return config


def render_config(config: dict) -> str:
    return json.dumps(config, indent=2, ensure_ascii=False) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description="Build generated cmux.json")
    parser.add_argument(
        "--check",
        action="store_true",
        help="fail if cmux.json differs from generated output",
    )
    args = parser.parse_args()

    rendered = render_config(build_config())
    if args.check:
        current = OUTPUT_PATH.read_text(encoding="utf-8") if OUTPUT_PATH.exists() else ""
        if current != rendered:
            print("cmux.json is out of date; run scripts/build-config.py", file=sys.stderr)
            return 1
        return 0

    OUTPUT_PATH.write_text(rendered, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
