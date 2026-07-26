# Per-terrain mission.sqm overrides

This folder is empty by default. The release workflow (`.github/workflows/release.yml`) checks it for each terrain it packages, and prefers whatever it finds here over everything else.

To supply a real, in-editor-verified `mission.sqm` for a terrain: open that terrain in Eden, build/verify a safe player-start layout on it directly, export it, and drop it at:

```
terrains/<Terrain>/mission.sqm
```

for example `terrains/Tanoa/mission.sqm`. The next release build will use that file verbatim for `Tanoa`'s zip instead of the interim researched-anchor transform in `.github/terrains.json`, no workflow change needed.

Until a terrain has a file here, the release workflow falls back to recentring the root `mission.sqm`'s 128 player-start positions onto a researched, named, spacious landmark for that terrain (see `.github/terrains.json` and `.github/scripts/patch_mission_positions.py`) - a reasonable starting point, not a substitute for verifying it in the actual editor.
