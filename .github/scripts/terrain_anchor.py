#!/usr/bin/env python3
"""Print "<x> <y> <z>" for a terrain's entry in terrains.json, or nothing
if that terrain has no entry (e.g. Altis, which needs no transform).

Usage: terrain_anchor.py <terrain> <terrains.json path>
"""
import json
import sys


def main():
    if len(sys.argv) != 3:
        print("usage: terrain_anchor.py <terrain> <terrains.json>", file=sys.stderr)
        sys.exit(2)

    terrain, config_path = sys.argv[1], sys.argv[2]
    with open(config_path, encoding="utf-8") as f:
        config = json.load(f)

    entry = config.get(terrain)
    if entry:
        print(f"{entry['anchor'][0]} {entry['anchor'][1]} {entry['z']}")


if __name__ == "__main__":
    main()
