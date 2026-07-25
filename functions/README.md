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
| `debug` | `debugMenu` (client panel), `debugAction` (server ops) | client / server |

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
test harness. Beyond the original behaviour (phase markers echoed to chat and the
"Traitors win" auto-end suppressed so a lone tester is never kicked out), pressing
**\\** in-round opens a data-driven panel (`Waldo_fnc_debugMenu`) that lets one
person exercise every system:

- **Roles** — become Innocent / Traitor / Detective / Jester on demand (the
  Detective gets its loadout, the Jester its fire-block, and the authoritative
  role lists stay consistent so win checks still behave).
- **Credits & shops** — grant credits and open either shop to buy-test items.
- **Test dummies** — spawn a captive dummy of any role. Its death is routed
  through `Waldo_fnc_onKilled`, so kill-credit, the Jester clean-kill and karma
  can all be verified without a second player.
- **Systems** — force an airdrop, skip the warmup, and set your own karma high or
  low to test the low-karma penalty path.
- **Win conditions** — force any ending (END1–END4) to check each debrief.
- **Player utilities** — godmode toggle, self-heal, teleport to the arena centre,
  and a "reveal all roles" 3D overlay.

Everything is gated on `TestingFlag`: the key does nothing and the server ops are
inert when Testing Mode is off, so normal games are completely unaffected. To add
a test tool, append one `[label, tooltip, code]` row to `_actions` in
`fn_debugMenu.sqf` (server-authoritative work goes through `Waldo_fnc_debugAction`).

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
