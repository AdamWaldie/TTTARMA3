# Architecture

## Function library layout

Everything lives as `Waldo_fnc_*` functions compiled by the `CfgFunctions` block in `description.ext`. A file at `functions/<group>/fn_<name>.sqf` becomes `Waldo_fnc_<name>`. The engine entry points are thin on purpose:

- `init.sqf` (server): compiles `config.sqf`, calls `Waldo_fnc_loadParams` synchronously, then spawns `Waldo_fnc_initServer` to orchestrate the round.
- `initPlayerLocal.sqf`: spawns `Waldo_fnc_initClient` for per-client setup.
- `onPlayerRespawn.sqf` (mission root): the engine's per-respawn hook, used only to re-home a revived player's state onto their new unit (see below).

| Group | Runs on | Covers |
|---|---|---|
| `config` | server | Lobby parameter reads, the dynamic arsenal |
| `core` | server / client | Round (re)init, server/client orchestration, spawn loadout |
| `arena` | server (confine: client) | Arena selection, wall construction, loot scatter, keeping players inside |
| `env` | server | Weather and time of day |
| `round` | server | Role assignment, the round loop, win checks, kill handling, revive relinking, MVP |
| `systems` | server | Airdrops, karma, C4, Identify Body, DNA contamination, the Dead Ringer decoy |
| `ui` | client | Shop dialogs, HUD, scoreboard, title sequence, MVP celebration |
| `roles` | client | Everything a player presses Y or a hotkey for |
| `debug` | every machine / client / server | The dev/test registry, its renderer, and its server dispatch |

## Round lifecycle and state

Each round ends by calling `BIS_fnc_endMissionServer`, a full mission restart. `missionNamespace` is wiped every time, so `Waldo_fnc_resetState` re-initializes every piece of round state defensively at the start of `Waldo_fnc_initServer` rather than assuming a clean slate. Clients wait on a `Waldo_configReady` flag before reading any config, so nothing races the server's synchronous `loadParams` pass.

Karma is the one exception: it's stored in `profileNamespace` (which survives the restart) rather than `missionNamespace`, keyed per player UID, and `Waldo_fnc_applyKarma` decays it back toward neutral and prunes UIDs no longer present, so a punishment never becomes permanent and the profile store can't grow without bound.

Init progress is logged as `[Waldo][server]` / `[Waldo][client]` phase markers to the `.rpt`, and echoed to chat when Testing Mode is on, specifically so a stalled replay can be traced to the exact phase it stopped at.

## Why respawn needs special handling

Arma has no "undo death." A unit that's actually died (`damage` 1, `Killed` fired) can never be revived in place, respawn always creates a brand-new object. Everything the mission does per-life, and might need to survive a mid-round revive, has to be explicitly re-homed onto that new object:

- **Role, credits, kill count, purchase log** - captured from the old (dead) unit and re-applied to the new one by `onPlayerRespawn.sqf`.
- **`TraitorList` / `DetectiveList` / `JesterList` membership** - repointed by the server-side `Waldo_fnc_reviveRelink`, since these authoritative lists drive win checks and credit awards and would otherwise keep referencing an object that can never act again.
- **Per-life event handlers** - `addMPEventHandler`/`addEventHandler` attach to a specific object, not to whatever the `player` command happens to resolve to. The `MPKilled` kill handler and the Dead Ringer `HandleDamage` guard, both installed once in `Waldo_fnc_initClient`, have to be reinstalled on the new unit or a revived player would have no kill-credit tracking and no Dead Ringer protection for the rest of the round.
- **Loadout** - a freshly respawned unit is otherwise bare. `Waldo_fnc_applySpawnLoadout` (shared with the initial spawn) gives it a random uniform/vest/headgear from the discovered pools.

Anything that reads the `player` command directly at call time, rather than holding onto a captured object reference, already tracks a respawn on its own and needs none of this. The `ace_unconscious` watchdog installed in `initClient` is the clearest example: it re-evaluates `player` on every loop tick, so it automatically follows whichever unit is currently controlled.

## Terrain independence

The mission runs on Altis, Tanoa, Stratis, or any other terrain, but this is solved at two different levels, and it matters which one:

**At runtime**, `Waldo_fnc_selectArena` scores candidate positions live rather than reading a fixed spot, and `Waldo_fnc_selectHoldingPos` does the same for the brief window before the real arena exists: a fast, `surfaceIsWater`-checked position every player is moved to the instant they join. `Waldo_fnc_initClient` also disables damage as its very first line, before either of those waits, so nothing about the gap between actually spawning and being relocated can hurt anyone. This is a safety net, not the fix, it can't stop someone from visibly spawning outside the map for a moment.

`Waldo_fnc_selectArena` only scores a candidate by how many lootable buildings sit inside it - it has no idea whether the interior is actually walkable end to end. A town's own property fence, walled compound, or similar terrain object can land running across an otherwise good arena and split it in two. `Waldo_fnc_clearArenaPaths` runs after `Waldo_fnc_buildArena` and sweeps parallel chords across the arena's full width at three angles (not just a few lines through the centre, so an obstruction sealing off a corner is caught too), walking each chord in ground-hugging sub-segments so a hill partway along it can't hide a fence sitting on it. A chord only counts as part of a real divider once it's part of a run of 3+ consecutive blocked chords - since an arena worth playing on is almost always in or near a town, and towns are full of small, walkable-around yard fences that would otherwise false-positive constantly. Only the middle chord of each qualifying run gets a gate cut (the blocking `Wall`-class object, CfgVehicles' base class for placeable fences/walls, plus its immediate neighbours - deleted, not the whole obstruction). If more than 2 separate dividing runs turn up, the whole arena is re-rolled (bounded retries in `Waldo_fnc_initServer`) rather than turned into Swiss cheese; the last attempt force-clears regardless, since a heavily gated round still beats an uncrossable one.

**At the file/workflow level**, the actual fix: `mission.sqm`'s 128 placed player-start positions are raw world coordinates baked in when the mission was saved in Eden, real only for the one terrain it was authored on (Altis). Reusing them unmodified on a smaller terrain isn't a "might be in water" risk, it can be flatly out of bounds (Stratis is smaller than Altis's coordinate range). `.github/workflows/release.yml` resolves this per terrain, in order:

1. `terrains/<Terrain>/mission.sqm`, if it exists - a real file someone built and verified in Eden directly on that terrain. Always preferred when present.
2. Otherwise, `.github/terrains.json`'s entry for that terrain - an anchor point (a named, spacious, dry landmark, e.g. an airfield apron) that `.github/scripts/patch_mission_positions.py` recenters the existing 128-position grid onto, preserving its layout, with height set well above plausible ground so an imprecise anchor still drops players safely rather than into the terrain.
3. Otherwise (Altis) - `mission.sqm` ships exactly as authored.

`terrains/README.md` documents how to move a terrain from step 2 to step 1. The release workflow packages the result once per terrain (`TroubleInArmaville_<version>.<Terrain>`), since Arma keys a mission's terrain off its folder name, not off anything inside `mission.sqm`.
