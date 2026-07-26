#!/usr/bin/env python3
"""
Recenter mission.sqm's 128 playable-unit start positions onto a different
terrain's anchor point, preserving their exact relative arrangement (the
existing 2m grid, known to work) rather than inventing a new layout.

This is an interim measure: mission.sqm's positions are only ever real,
verified coordinates for the ONE terrain the mission was actually authored
and saved in Eden on (Altis). Shipping those same raw coordinates for a
differently-shaped terrain risks landing outside the map entirely, not just
in water. Until a real per-terrain mission.sqm exists (see
terrains/<Terrain>/mission.sqm - checked for and preferred over this script
by the release workflow), this recenters onto a real, named, definitely
in-bounds landmark (an airfield apron: flat, paved, spacious) researched per
terrain, and sets height well above any plausible ground elevation so a
transform that's slightly off drops the unit safely onto real ground rather
than inside it - the mission's own Waldo_fnc_initClient already disables
damage before anything else runs, so a short fall here is cosmetic, not
harmful.

Usage: patch_mission_positions.py <mission.sqm> <anchor_x> <anchor_y> <z>
"""
import re
import sys


def find_player_position_lines(lines):
    """Indices of position[] lines belonging to a playable I_Survivor_F
    unit, identified by a type="I_Survivor_F" marker in the next few lines,
    before another position[] line starts the next entity. This is how the
    128 player slots are told apart from the 2 other placed entities (a
    view-distance Logic and a Curator module) that also have position[]."""
    idx = []
    for i, line in enumerate(lines):
        if "position[]=" not in line:
            continue
        for j in range(i + 1, min(i + 20, len(lines))):
            if "position[]=" in lines[j]:
                break
            if 'type="I_Survivor_F"' in lines[j]:
                idx.append(i)
                break
    return idx


def parse_position(line):
    m = re.search(r"position\[\]=\{([^}]*)\}", line)
    x, y, z = (float(v) for v in m.group(1).split(","))
    return x, y, z


def format_position(line, x, y, z):
    triplet = f"{x:.7g},{y:.7g},{z:.7g}"
    return re.sub(r"position\[\]=\{[^}]*\}", f"position[]={{{triplet}}}", line)


def main():
    if len(sys.argv) != 5:
        print("usage: patch_mission_positions.py <mission.sqm> <anchor_x> <anchor_y> <z>", file=sys.stderr)
        sys.exit(2)

    path, anchor_x, anchor_y, z = sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4])

    with open(path, encoding="utf-8") as f:
        lines = f.readlines()

    player_idx = find_player_position_lines(lines)
    if len(player_idx) != 128:
        print(f"error: expected 128 player position lines, found {len(player_idx)} - refusing to patch", file=sys.stderr)
        sys.exit(1)

    coords = [parse_position(lines[i]) for i in player_idx]
    cx = sum(c[0] for c in coords) / len(coords)
    cy = sum(c[1] for c in coords) / len(coords)

    for i, (x, y, _z) in zip(player_idx, coords):
        lines[i] = format_position(lines[i], anchor_x + (x - cx), anchor_y + (y - cy), z)

    with open(path, "w", encoding="utf-8") as f:
        f.writelines(lines)

    print(f"patched {len(player_idx)} positions: centroid ({cx:.2f},{cy:.2f}) -> anchor ({anchor_x},{anchor_y}), z={z}")


if __name__ == "__main__":
    main()
