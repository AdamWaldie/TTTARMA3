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
| `config` | `loadParams`, `buildArsenal` | server |
| `core` | `resetState`, `initServer`, `initClient` | server / client |
| `arena` | `selectArena`, `buildArena`, `populateLoot`, `confineToArena` | server (confine: client) |
| `env` | `setupWeather` | server |
| `round` | `assignRoles`, `applyDetectiveLoadout`, `startRound`, `roundLoop`, `checkWin`, `endRound`, `onKilled`, `reviveAsTraitor` | server |
| `systems` | `spawnAirdrop`, `applyKarma` | server |
| `ui` | `initShops` (preInit), `initHud`, `drawRoleIcons`, `openBuyMenu`, `buyItem`, `titleSequence`, `pregameScreen` | client |
| `roles` | `traitorRadar`, `detectiveRadar`, `warpSmoke`, `suicideBomb`, `flowerPower`, `tester`, `revive`, `healthStation`, `holster` | client |
| `debug` | `debugInit` (preInit registry + API), `debugMenu` (client renderer), `debugExec` (server dispatch), `effectivePlayerCount` | every machine / client / server |

## Equipment — dynamic, intent-aware arsenal

Equipment is discovered at runtime, not hand-listed per modpack.
`Waldo_fnc_buildArsenal` runs once in `loadParams` (server), scans the loaded
`CfgWeapons` a single time, and classifies what is actually available:

- weapons are bucketed by **config inheritance** (`isKindOf` on `Rifle` /
  `Pistol` / `Launcher`, so mods that inherit from the base classes are picked
  up) and then by **power** — a primary's default-magazine ammo `hit` and round
  count sort it into low / standard / sniper / LMG;
- clothing is bucketed by `ItemInfo` type (uniform / vest / headgear);
- thermal optics are auto-detected (via `OpticsModes` `visionMode`) and
  blacklisted from loot.

It then publishes the exact globals the mission already consumes
(`lootPriWeapons`, `lootSecWeapons`, `lootAttachments`, `airdropLoadouts`,
`TraitorRifle`/`*Mag`/`*Optics`, `TraitorLauncher`/`*Mag`, `uniformsConfig`,
`headgearsConfig`, `vestsConfig`, `detectiveConfig`) by **intent**:

| Intent | Pool |
|--------|------|
| Ground loot | low-powered primaries + sidearms (falls back to standard rifles if too few low-powered exist) |
| Airdrops (reward) | snipers + LMGs + standard rifles |
| Traitor "Long Rifle" | the highest-`hit` sniper found, with a compatible optic |
| Traitor "Rocket Launcher" | any launcher found |
| Spawn / detective clothing | discovered uniforms / vests / headgear |

Every bucket has a **vanilla fallback**, so an empty category never breaks a
round, and consumers keep their own `isNil`/`getVariable` guards. Because it is a
drop-in for those globals, `Waldo_fnc_populateLoot`, `Waldo_fnc_spawnAirdrop`,
the shop and the spawn loadout needed **no changes**.

### Optional override

`config.sqf` is dynamic by default (no modpack set). To pin a hard theme (e.g.
WW2, so modern vanilla weapons are not mixed in), point `Waldo_modpack` at a file
in `modpacks/`; `loadParams` loads it **after** the dynamic pass, so it overrides
whichever globals it sets. The `modpacks/*.sqf` files are now just optional
override presets, not the primary equipment source.

## Adding a shop item

Edit the catalog in `ui/fn_initShops.sqf`. Each entry is:

```
[ _name, _cost, _type, _onBuy, _onActivate, _tooltip ]
```

- `_type`: `"passive"` | `"weapon"` | `"activation"`.
- `_onBuy`: runs immediately on purchase.
- `_onActivate`: for activation items, runs when the player presses **Y**;
  return `true` to consume the item, `false` to keep it queued (e.g. no target).

The buy menu (`Waldo_fnc_openBuyMenu`) builds its cards from the catalog at
runtime, so no `.hpp` changes are needed. The dialog is a centred panel with a
role-tinted header, a scrollable card grid coloured by affordability, and a
footer that shows the hovered item's name, cost, type and `_tooltip` (so write
`_tooltip` as the item's description). Buying refreshes credits + affordability
in place and leaves the shop open (`Waldo_fnc_buyItem`); Esc or **Close** exits.

The traitor and detective catalogs each carry ~12 items — offence (silenced
sidearm, frags, launcher, long rifle), utility (radar, stamina, night vision,
body armor), and role tools (defibrillator, tester, health station, body
remover). The silenced sidearm is sourced from the dynamic arsenal
(`ShopPistol*`), so it follows the loaded modpack.

## Keys

- **B** — open your buy menu (Traitor / Detective).
- **Y** — use your most recently bought activation item.
- **L** — holster / lower weapon.
- **\\** — open the dev/test menu (**only** when the **Testing Mode** parameter is on).
- **]** — instantly cycle your own role Innocent → Traitor → Detective → Jester (Testing Mode only).

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

- **Roles** — become any role (or press **]** to cycle instantly, no menu), or
  re-run role assignment. Every switch is complete and reversible: role lists,
  detective loadout, shop access and the Jester fire-block are all reconciled, so
  you can hop between roles on the fly and each one behaves exactly as in a real
  game. Shop roles are handed a usable test balance on switch.
- **Loadout & shops** — grant credits, open either shop, or run every shop
  purchase effect at once.
- **Abilities** — fire each Traitor/Detective power (radars, warp smoke, flower
  power, health station, suicide bomb, holster) directly.
- **Test dummies** — spawn captive role dummies (deaths routed through
  `Waldo_fnc_onKilled`, so kill-credit / Jester clean-kill / karma work solo) or
  an armed hostile for combat testing; clear them all in one click. These do
  **not** count toward win conditions.
- **Simulated players** — spawn AI that genuinely participate in the win check:
  traitor sims join `TraitorList` (so END1 needs them dead), non-traitor sims
  mark that a non-traitor side exists (so END2 becomes reachable). Build a roster,
  then "Kill Sim Traitors" (be a non-traitor → **END1**) or "Kill Sim Innocents"
  (be a traitor → **END2**) and watch the ending resolve. "Clear Sim Players"
  tears the scenario down and repairs the lists.
- **Round flow** — skip warmup, freeze the clock, add/subtract time, or force any
  ending (END1–END4).
- **Arena & world** — rebuild/reselect the arena, repopulate loot, and set
  weather / time of day.
- **Karma & sim** — set your karma, and **simulate a lobby size** so arena
  scaling, traitor counts and credit scaling can be tested solo.
- **Player** — godmode, heal, refill ammo, infinite stamina, teleport, kill self.
- **Diagnostics** — dump game state to chat/`.rpt` or the clipboard.

Testing the endings also hardened `Waldo_fnc_checkWin` for **live** games: every
roster test is null-safe, and both team-win endings now require a Traitor side to
have existed — with the Traitors-win ending additionally requiring that
non-Traitors existed this round (`Waldo_hadNonTraitors`, set in `assignRoles`).
That closes the degenerate all-Traitor lobby that used to insta-win. The
simulated-player roster is only mixed in under Testing Mode, so a normal game's
win check is otherwise unchanged.

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

### Modpack independence

The framework carries no modpack-specific classnames. Weapon/loadout tools run
the shop's own `_onBuy` effects, which already read modpack globals with vanilla
fallbacks, so they follow whichever modpack is loaded. Spawned test units
(dummies, simulated players, hostile) go through one helper, `Waldo_debugMakeUnit`,
which:

- reads its unit class from `Waldo_debugCivUnit` / `Waldo_debugEnemyUnit`,
  **validating** it and falling back to a base-game class (`C_man_1` /
  `O_Soldier_F`) that exists in every install, and
- dresses non-enemy units from the active modpack's `uniformsConfig` /
  `headgearsConfig` / `vestsConfig`, so they look like that modpack's players.

A modpack that replaces the base man classes can point those two variables at its
own units (see the commented example in `modpacks/Custom.sqf`); with no config,
testing works out of the box under any modpack.

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
