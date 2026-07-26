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
