# Code Standards

These are the conventions the existing codebase actually follows. A pull request that matches them will look like it belongs here; one that doesn't will stand out in review. None of this is enforced by a linter, SQF doesn't have one, so it's enforced by everyone reading code before it merges.

## File and function naming

A file at `functions/<group>/fn_<name>.sqf` becomes `Waldo_fnc_<name>`. That's the whole naming rule, one function per file, filename gives you the function name. Every new file needs a matching entry in `description.ext`'s `CfgFunctions` block under its group, `class <name> {};`, with a trailing comment naming the function and what it does:

```cpp
class revive {};            // Waldo_fnc_revive
class reviveRelink {};      // Waldo_fnc_reviveRelink (server: relinks role/lists onto a revived unit's NEW object)
```

Nothing auto-scans the `functions/` folder. A file that exists but isn't registered here simply doesn't compile to a callable function, and that's a silent failure you won't see until something tries to call it.

Two files are marked `{ preInit = 1; };` instead of the default: `initShops` (defines the shop catalogs) and `debugInit` (builds the dev/test registry). Both need to exist before other preInit or init-time code references them, and both run on every machine, not just server or client.

## Guard clauses

The first line (or two) of a function states where it's allowed to run, before anything else:

```sqf
if (!isServer) exitWith {};
```
```sqf
if (!hasInterface) exitWith {};   // dedicated server / headless: nothing to do
```

If a function is genuinely both server- and client-aware in different parts, that's rare here and should be commented explicitly rather than left to be inferred.

## Params and privacy

`params` immediately follows any guard clause, using the `["_name", default]` form for anything optional:

```sqf
params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];
params [["_dir", 0]];
```

Every local variable is `private`. The handful of unprefixed globals you'll see on units (`role`, `points`, `tested`) predate the `Waldo_` convention and are treated as established public API, read by many systems, don't rename them. Everything new uses the `Waldo_` prefix, both to avoid colliding with another mod's globals and to make it obvious at a glance what's this mission's state versus the engine's or another mod's.

## Broadcasting state

`setVariable`'s third argument is a deliberate choice, not a habit:

- `true` when another machine needs to see the value: role, points, list membership, forensic tags on a body, anything read by `getVariable` on a different client than the one that set it.
- Omitted (local only) for state that's genuinely per-client and never read elsewhere: the activation key slots/backlog, a UI handler id, a debug toggle.

If you're not sure which a new variable needs, check whether anything on another machine will ever call `getVariable` on it. If yes, broadcast it.

## remoteExec targeting

The target argument routes execution, and the three forms used throughout mean specific things:

- An object argument routes to whichever machine currently owns (is local to) that object. This is how `setPlayerRespawnTime` and per-player UI refreshes reach the right client.
- `0` broadcasts to every currently connected machine. Nothing here passes the separate JIP-persistence argument, so a player who joins after the call won't have it replayed, which is fine for a one-off announcement but worth knowing if you add something a late joiner would actually need.
- `2` targets the server only, used for anything that must run with server authority (list mutations, spawning networked objects that need a stable owner).
- `-2` targets every client except whichever machine is calling `remoteExec`.

Don't guess a target number by trial and error, pick the one that matches which machine actually needs to run the code.

## Event handlers don't stack themselves

Anything that installs a `Draw3D`, `Fired`, `HandleDamage`, or CBA per-frame handler and might reasonably be triggered more than once (a shop item that can be bought twice, a dev-menu action fired again) stores the handler's id in a `getVariable` and removes any previous one before installing a new one:

```sqf
private _old = player getVariable ["Waldo_radarEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };
```

Skipping this doesn't crash anything, it just leaks a duplicate handler that runs forever alongside the new one. That bug has happened here before; don't reintroduce it.

`MPKilled` is installed with `addMPEventHandler`, since it's the one truly server-authoritative per-life event, everything downstream (credit awards, karma, the Jester win check) happens inside a function gated on `isServer`. Client-local reactions use plain `addEventHandler` or `CBA_fnc_addEventHandler`.

## A unit's identity doesn't survive a respawn

If you're writing anything that captures a unit object and expects to still be able to act on it later (a delayed `spawn`, a stored reference, anything not re-read at call time), read [Architecture](Dev-Architecture) first. Arma's respawn always creates a new object; a captured reference to the pre-respawn unit is a corpse forever afterward, and code that keeps acting on it fails silently rather than erroring.

## Equipment: no hardcoded classnames outside the arsenal

`Waldo_fnc_buildArsenal` is the only place a mod-specific or DLC-specific classname should ever appear (and even there, only as a documented vanilla fallback). Every other system reads the arsenal's published globals (`ShopArmorVest`, `TraitorRifle`, `uniformsConfig`, and so on with a `missionNamespace getVariable` and a sane default). If a new feature needs a new kind of gear, extend `buildArsenal`'s discovery and publish a new global, don't hand-list a classname somewhere downstream.

## Extending the dev/test menu

Never edit `WaldoDebug`'s `.hpp` or hand-add a case to `fn_debugMenu.sqf`. Register a tool instead, from code that runs at preInit on every machine:

```sqf
["Category", "Label", "Tooltip", "local"|"server", { /* _this = the acting unit */ }] call Waldo_debugRegister;
```

See [Dev and Test Mode](Dev-Test-Mode) for the full contract (what `"local"` vs `"server"` context means, and why the code itself never crosses the network).

## Comments explain why, not what

The line `player setDamage 1;` doesn't need a comment. A comment earns its place by explaining something the code alone can't: a constraint, a bug it's working around, why an obvious-looking alternative doesn't work. You'll see this throughout: several files carry a short note on a past bug and exactly how the current code avoids it. That's the standard, if you fix something non-obvious, say what would have gone wrong instead, not just what the new code does.

## Before you commit

SQF has no compiler. A mismatched brace or bracket doesn't fail until Arma tries to run that exact code path, sometimes mid-round, and the failure is a silent script abort logged to `.rpt`, not an error at load time. Before committing, check that every file you touched has balanced `()`, `{}`, `[]`, and quotes. A simple per-file character count catches the overwhelming majority of these before they ever reach a test session.
