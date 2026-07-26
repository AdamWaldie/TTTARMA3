# Trouble In Armaville

**An Arma 3 adaptation of the iconic Trouble In Terrorist Town game mode.**  
Built for tactical deception, social deduction, and explosive chaos — in the uniquely sandboxy Arma 3 engine.

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/ui/TroubleInArmaville.jpg?raw=true" alt="Trouble In Armaville Logo" width="512">
</p>

---

## About

Trouble In Armaville (TTT) is a re-imagining of the GMod game mode **Trouble In Terrorist Town**, fully implemented in **Arma 3**.

Built for seamless multiplayer, TTT in Armaville supports:
- Randomised traitor/detective/innocent role assignment
- Investigative gameplay with hidden objectives
- Dynamic airdrops, loot spawns, buy menus and arena generation
- Clean UI and round timers
- Jester chaos

This version (2.5.0 RC) includes a major refactor for stability, scalability, and maintainability.

---

## Features

- 🔀 **Dynamic Role System** – configurable traitor %, detective, jester inclusion  
- 🌆 **Arena Generator** – auto-finds towns and builds circular, scalable play zones  
- 🎯 **Custom Buy Menus** – traitors and detectives get access to powerful tools  
- ☁️ **Dynamic Weather** – fog, rain, time of day, all configurable  
- 🚁 **Airdrops** – periodic random supply drops to spice up gameplay  
- 🎵 **Intro Music** – loading screen music (configurable in `description.ext`)  
- 🧠 **Full parameter integration** – round length, role chance, game modifiers

---

## Installation

1. Download this repo release.
2. Copy the mission folder into your Arma 3 missions directory
3. Launch in Multiplayer

---

## Configuration

### Editable Parameters (via Lobby Menu):

| Group | Parameters |
|-------|-----------|
| **Round** | Base length, bonus per player, traitor bonus, time per death, warmup |
| **Roles** | Traitor % lower/upper bound, **min / max traitors**, detective on/off, **detective min players**, jester on/off, **jester always**, jester chance |
| **Gameplay** | **Karma system on/off**, **starting shop credits (base)** |
| **Airdrop / Loot** | Airdrops on/off, base + random timer, loadouts per drop, max mag ammo, **loot power** (low / balanced / anything) |
| **Environment** | Allow rain + chance, allow fog + chance, **Time of Day** (Random / Dawn / Day / Dusk / Night) |
| **Arena** | **Arena size** (small / normal / large) |
| **Testing** | Enable Testing Mode (unlocks the solo dev/test harness) |

Boolean toggles use a `{0,1}` value read numerically, so they actually respond to
the lobby (a `{False,True}` value with a boolean default is silently ignored by
the engine — that bug is fixed here).

### Equipment (fully dynamic — no modpacks)

There are **no modpack files**. Weapons, ammo, gear, loot, airdrops and clothing
are all discovered at runtime by `Waldo_fnc_buildArsenal`, which scans whatever
mods are loaded and picks gear **by intent**:

- **low-powered weapons** for ground loot (close-quarters TTT),
- stronger weapons for airdrops,
- the highest-damage sniper and a launcher for the traitor shop,
- a suppressed sidearm, a heavy vest, a frag grenade, night vision and
  binoculars for the shop gear,
- available uniforms / vests / headgear for spawns and the detective.

It works on **any** mod loadout with zero curation. Built-in **vanilla
classnames are the fallback** for any category a total-conversion happens not to
provide, so nothing is ever unset. To switch "modpacks", just change the mods you
launch Arma with — the mission adapts automatically.

Optional tuning (power thresholds) lives in `config.sqf`; you never *need* to
touch it.

---

## Testing / Dev Mode

Set **Enable Testing Mode** to *Yes* in the lobby to test the whole game solo
without breaking normal flow. It echoes init phase markers to chat and stops the
"Traitors win" ending from kicking out a lone tester. Once in-round, press **`\`**
to open the **Dev / Test Menu** — an extensible, category-grouped console that
lets one player:

- switch their own role on the fly — via the menu or by pressing **`]`** to cycle
  Innocent → Traitor → Detective → Jester instantly (each switch is complete and
  reversible: loadout, shop access and the Jester fire-block all reconcile),
- grant credits, open either shop, or apply every shop item at once,
- fire each role ability (radars, warp smoke, flower power, health station,
  suicide bomb, holster) directly,
- spawn captive **test dummies** (deaths run through the real kill handler, so
  kill-credit, the Jester win and karma can be verified alone) or an armed hostile,
- spawn **simulated players** that count toward the win conditions, so every
  ending (Innocents / Traitors / Jester / Time Up) can be built and verified solo,
- skip warmup, freeze the clock, add/subtract time, or force any ending,
- rebuild/reselect the arena, repopulate loot, and set weather / time of day,
- **simulate a lobby size** to test arena scaling, traitor counts and credit
  scaling solo,
- godmode, heal, refill ammo, infinite stamina, teleport, kill self, and dump
  game state to chat / clipboard.

Everything is gated on the parameter, so with Testing Mode off the key, the
server dispatch and the simulated player count all do nothing and a normal match
is unaffected. The menu is driven by a **registry**, so new tools are added with a
single `Waldo_debugRegister` call (see `functions/README.md`) — no UI edits.

---

## Dependencies

- Arma 3
- CBA_A3

ACE isn't officially supported but can work if you disable the medical or uncon rule for fair play.

---

## License

This project is released associated with [Waldo’s Mission Pack](https://github.com/AdamWaldie/WaldosMissionPack) and is released under the MIT License.  
You are free to fork, extend, and contribute.

The music used by default is A Typical Ride Out by Noir Et Blanc Vie, it is royalty free and offered as part of youtubes audio library.

---

## Credits

Developed by [AdamWaldie](https://github.com/AdamWaldie)  
Design inspiration from GMod’s original TTT mode and its community.

---

> “Innocents win... or do they?”  


