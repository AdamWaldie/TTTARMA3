# Waldo_fnc_* — Trouble In Armaville function library

All mission logic lives here as CBA/BIS-style functions compiled by the
`class CfgFunctions { class Waldo { ... } }` block in `description.ext`.
A file `functions/<group>/fn_<name>.sqf` becomes `Waldo_fnc_<name>`.

The engine entry points are thin: `init.sqf` (server) calls
`Waldo_fnc_loadParams` then spawns `Waldo_fnc_initServer`; `initPlayerLocal.sqf`
spawns `Waldo_fnc_initClient`; `config.sqf` only chooses the equipment modpack.

## The game mode (intent)

Trouble in Terrorist Town is a hidden-role social-deduction round game:

- **Innocent / Civilian** — majority, no powers, no knowledge. Wins when every
  Traitor is dead.
- **Traitor / Terrorist** — hidden minority (~25%). Know each other, share a
  credit shop, get sabotage tools. Win by killing everyone who is not a Traitor.
- **Detective** — a publicly-known Innocent (blue) with investigation tools
  (test bodies/players) and a support shop. Same win goal as Innocents.
- **Jester** — deals no damage and cannot win normally. Traitors are told who
  they are. "Wins" only if a **non-Traitor** kills them, denying the normal
  sides. Being killed by a Traitor does nothing.

## Layout

| Group | Functions | Runs on |
|-------|-----------|---------|
| `config` | `loadParams` | server |
| `core` | `resetState`, `initServer`, `initClient` | server / client |
| `arena` | `selectArena`, `buildArena`, `populateLoot`, `confineToArena` | server (confine: client) |
| `env` | `setupWeather` | server |
| `round` | `assignRoles`, `applyDetectiveLoadout`, `startRound`, `roundLoop`, `checkWin`, `endRound`, `onKilled`, `reviveAsTraitor` | server |
| `systems` | `spawnAirdrop`, `applyKarma` | server |
| `ui` | `initShops` (preInit), `initHud`, `drawRoleIcons`, `openBuyMenu`, `buyItem`, `titleSequence`, `pregameScreen` | client |
| `roles` | `traitorRadar`, `detectiveRadar`, `warpSmoke`, `suicideBomb`, `flowerPower`, `tester`, `revive`, `healthStation`, `holster` | client |
| `debug` | `debugInit` (preInit registry + API), `debugMenu` (client renderer), `debugExec` (server dispatch), `effectivePlayerCount` | every machine / client / server |

## Adding a shop item

Edit the catalog in `ui/fn_initShops.sqf`. Each entry is:

```
[ _name, _cost, _type, _onBuy, _onActivate, _tooltip ]
```

- `_type`: `"passive"` | `"weapon"` | `"activation"`.
- `_onBuy`: runs immediately on purchase.
- `_onActivate`: for activation items, runs when the player presses **Y**;
  return `true` to consume the item, `false` to keep it queued (e.g. no target).

The buy menu (`Waldo_fnc_openBuyMenu`) builds its buttons from the catalog at
runtime, so no `.hpp` changes are needed.

## Keys

- **B** — open your buy menu (Traitor / Detective).
- **Y** — use your most recently bought activation item.
- **L** — holster / lower weapon.
- **\\** — open the dev/test menu (**only** when the **Testing Mode** parameter is on).

## Testing / dev mode

Set the **Enable Testing Mode** lobby parameter to *Yes* to unlock a solo-friendly
test framework. Beyond the original behaviour (phase markers echoed to chat and the
"Traitors win" auto-end suppressed so a lone tester is never kicked out), pressing
**\\** in-round opens an extensible console (`Waldo_fnc_debugMenu`) that renders a
registry of test tools grouped by category. Everything is gated on `TestingFlag`:
the key does nothing, the server dispatch refuses to run, and the simulated
player-count override is ignored when Testing Mode is off, so normal games are
completely unaffected.

Built-in tools cover every area of the game:

- **Roles** — become any role, or re-run role assignment. Lists, loadouts and the
  Jester fire-block stay consistent so win checks keep behaving.
- **Loadout & shops** — grant credits, open either shop, or run every shop
  purchase effect at once.
- **Abilities** — fire each Traitor/Detective power (radars, warp smoke, flower
  power, health station, suicide bomb, holster) directly.
- **Test dummies** — spawn captive role dummies (deaths routed through
  `Waldo_fnc_onKilled`, so kill-credit / Jester clean-kill / karma work solo) or
  an armed hostile for combat testing; clear them all in one click.
- **Round flow** — skip warmup, freeze the clock, add/subtract time, or force any
  ending (END1–END4).
- **Arena & world** — rebuild/reselect the arena, repopulate loot, and set
  weather / time of day.
- **Karma & sim** — set your karma, and **simulate a lobby size** so arena
  scaling, traitor counts and credit scaling can be tested solo.
- **Player** — godmode, heal, refill ammo, infinite stamina, teleport, kill self.
- **Diagnostics** — dump game state to chat/`.rpt` or the clipboard.

### Extending it

The action list is a **registry**, not a hardcoded menu. Register a tool from any
code that runs at preInit on every machine (this mission's `Waldo_fnc_debugInit`,
or a future module's own preInit):

```sqf
["Category", "Label", "Tooltip", "local"|"server", { /* _this = acting unit */ }]
    call Waldo_debugRegister;
```

- `"local"` code runs on the clicking client; `"server"` code is dispatched to
  the server **by index** (no code crosses the wire) and run with the clicking
  unit as `_this`, keeping authoritative state correct.
- The menu groups entries by `Category` in `Waldo_debugCatOrder` and rebuilds
  itself automatically — no UI, dispatch or `description.ext` edits needed.
- Scripted testing: `"airdrop" call Waldo_debug` runs the first tool whose label
  matches. `Waldo_fnc_effectivePlayerCount` is the shared hook that lets size
  logic honour the simulated lobby size.

## State model & replay safety

Each round ends via `BIS_fnc_endMissionServer`, i.e. a full mission restart, so
`missionNamespace` is wiped every round. `Waldo_fnc_resetState` re-initialises
all round state defensively, and consumers wait on `Waldo_configReady` so they
never read config before the modpack/params are published. Karma is the only
cross-round state and lives in `profileNamespace`; `Waldo_fnc_applyKarma` decays
and prunes it so it can never accumulate unbounded.

Init progress is logged as `[Waldo][server]` / `[Waldo][client]` phase markers
in the `.rpt` (and on-screen when the **Testing Mode** parameter is on) to make
replay stalls easy to trace.
