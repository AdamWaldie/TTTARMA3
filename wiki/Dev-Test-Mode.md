# Dev and Test Mode

Turn on **Enable Testing Mode** in the lobby to test the entire game alone, without changing how a real game with other players behaves. Everything described here is gated on that one parameter: with it off, the menu key does nothing, the server refuses to dispatch any of it, and the simulated-player-count override is ignored, so a live game runs exactly as if none of this existed.

## Opening it

Press **[** in-round to open the menu, or **]** to instantly cycle your own role (Innocent -> Traitor -> Detective -> Jester -> Innocent) without opening anything. Both only work under Testing Mode.

## How the menu is built

The menu is a registry, not a hardcoded list. Anything that runs at preInit on every machine can register a tool with one call:

```sqf
["Category", "Label", "Tooltip", "local"|"server", { /* _this = the acting unit */ }]
    call Waldo_debugRegister;
```

`"local"` code runs on the clicking client. `"server"` code is dispatched to the server by registry index (no code ever crosses the network) and runs there with the clicking unit as `_this`, which is what keeps authoritative state like `TraitorList` or the round timer correct no matter who clicked the button. The menu itself (`Waldo_fnc_debugMenu`) only ever renders whatever is in the registry and dispatches by index; adding a tool never needs a UI or `description.ext` change.

## What's built in

- **Roles** - become any role directly, or re-run role assignment for the whole lobby. A 3D overlay can reveal every unit's true role for debugging.
- **Loadout & Shops** - grant credits, open either shop to inspect or buy-test it, or run every catalog item's purchase effect at once.
- **Abilities** - fire Traitor/Detective role powers directly (radars, warp smoke, flower power, health station, suicide bomb, holster) without buying them first.
- **Test Dummies** - captive AI whose deaths route through the real kill handler (`Waldo_fnc_onKilled`), so kill-credit, the Jester clean-kill check, and karma can all be verified solo. These do not count toward win conditions.
- **Simulated Players** - the one category that *does* count toward win conditions. Traitor sims join `TraitorList` (so an Innocents-win check needs them dead too); non-Traitor sims mark that a non-Traitor side exists, unlocking the Traitors-win ending. Build a roster, then "Kill Sim Traitors" or "Kill Sim Innocents" and watch the corresponding ending actually resolve. "Clear Sim Players" tears the scenario down and repairs the authoritative lists so nothing is left stale.
- **Round Flow** - skip warmup, freeze the clock (pauses the timer, airdrops, and win checks so a system can be inspected mid-round), add or subtract time, or force any of the four endings directly.
- **Arena & World** - rebuild or reselect the arena, repopulate loot, and set weather or time of day on demand.
- **Karma & Sim** - set your own stored karma, and override the player count that size-dependent systems (arena radius, Traitor count, starting credits) scale to, so lobby-size behavior can be tested without an actual crowd.
- **Player** - godmode, heal, refill ammo, infinite stamina, teleport to the arena center, kill yourself on command.
- **Diagnostics** - dump round state to chat/`.rpt`, or to the clipboard.

## Mod independence

The framework carries no mod-specific classnames of its own. Anything that gives gear runs the shop's actual purchase effects, which already read the dynamic arsenal's globals with vanilla fallbacks (see [Equipment System](Dev-Equipment-System)). Spawned test units (dummies, sims, the hostile combat dummy) go through one shared helper that validates a configurable unit class and falls back to a base-game class if it's missing, and dresses non-enemy units from the discovered clothing pools so they look like the current players.
