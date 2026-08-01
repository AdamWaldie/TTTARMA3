# Trouble In Armaville

Trouble In Terrorist Town, rebuilt in Arma 3. Same hidden-role deduction loop as the GMod original, played out with real ballistics, real vehicles, and a sandbox big enough to hide a body in.

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/ui/TroubleInArmaville.jpg?raw=true" alt="Trouble In Armaville Logo" width="512">
</p>

---

## Four roles, one deduction game

Each round, players are assigned one of four roles and dropped into a town-sized arena the mission builds and walls off on the fly, a different one every round, on any of five stock terrains.

- **Innocent.** The majority. No powers, no information. Wins when every Traitor is dead.
- **Traitor.** A hidden minority who know each other, share a credit shop, and win by killing everyone who isn't one of them.
- **Detective.** A publicly known Innocent with an investigation shop: testing, DNA forensics, radar. Wins alongside the Innocents.
- **Jester.** Deals no damage and can't win the normal way. Traitors are told who the Jester is. If a non-Traitor kills them, the Jester wins instead, and nobody else does.

The round ends when the Innocents wipe out the Traitors, the Traitors wipe out everyone else, time runs out, or the Jester gets themselves killed by the wrong person. A body has to be identified before its role becomes public knowledge, which is where the investigation side of the game actually lives.

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/wiki/Images/RoleTraitor.jpg?raw=true" alt="Traitor HUD" width="49%">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/wiki/Images/BuyMenuTraitor.jpg?raw=true" alt="Traitor shop" width="49%">
</p>

For mechanics in more depth than fits here, see the [wiki](https://github.com/AdamWaldie/TTTARMA3/wiki): win-condition priority, the full shop catalogs, DNA contamination math, the dynamic arsenal, every lobby parameter, and the dev/test framework.

---

## What's in it

**Arena generation.** The server scores candidate town locations by how many enterable, loot-bearing buildings sit inside the play radius, and picks the best one it finds rather than centering on an empty field. A circular wall goes up around it, measured at runtime against the actual wall asset so it doesn't develop gaps as the radius grows, and anyone who wanders too close to the edge gets warned back in. If the town itself has a fence or compound wall cutting the play area in half, the server sweeps for it and cuts a gate through, favoring a reroll over carving up a good location for anything short of a genuine dead end.

**Investigation and counter-investigation.** DNA left at a kill can be sampled and tracked, but the trace decays with age, and every different player who walks near the scene raises the odds the reading points at an innocent bystander instead of the real killer. A Detective's Enhanced Scanner passive cuts that risk in half and adds forensic detail: time of death, weapon used. Traitors get their own answers to it. Dead Ringer fakes a death outright, a ragdoll, a decoy corpse, twenty seconds face-down before getting back up. False Flag redirects a kill's DNA onto a random bystander instead of the Traitor who pulled the trigger. Disguiser goes further still, copying a living player's loadout for sixty seconds so both your appearance and anything you leave behind point at them, not you. Calling in a body confirms the death to everyone, but only a Detective's identification reveals who they were.

**Shops.** Traitors get eighteen items, Detectives fourteen, split between weapons, passives, and one-press activation items: defibrillator, C4, body removal, the DNA scanner itself. Pricing tracks how much an item disrupts the other side's investigation, not just raw firepower, so the cheap items (radar, a medkit) never compete with the round's real decisions. A Purchased panel keeps a running log of what you've bought and how to use it, so you're never stuck trying to remember what an item does three purchases later.

**Traitor coordination.** A silent ping tells every fellow Traitor where to look, no chat or voice an Innocent could overhear. Aim at a living player and it's a tracked target marker. Aim at anything else and it's a static location pin.

**Airdrops.** Regular supply crates drop on a timer built from the lobby settings, plus a rare golden variant in three flavors (weapons, medical, ammo) that gets announced to the whole server the moment it's in the air.

**Revive.** Both shops carry a defibrillator. A Traitor's revives the target onto the Traitor team. A Detective's brings them back as whatever they were. Arma has no real "undo death," so a revive is a forced early respawn under the hood: the mission rebuilds the player's role, credits, kill count, and kit onto the new unit the moment it exists.

**Karma.** Killing your own side is remembered across rounds, stored per player rather than per mission, since the mission itself restarts every round. Low karma scales down next round's starting credits rather than zeroing them outright, and decays back toward neutral the longer you play clean. Killing the Jester or a fellow Traitor carries its own separate, smaller penalty on top.

**Round MVP.** Whoever has the most kills gets a short celebration at round end: the intro music again, a burst of colored smoke over the arena, a banner with their name on it.

**Onboarding.** A "How To Play" page in the map screen's diary covers the rules for anyone who's never played TTT before, and every round opens with a private card naming your role, your win condition, and whoever you're actually supposed to know about, colored to match a colorblind-safe palette throughout the HUD. The same briefing is one keypress away all round on the scoreboard, for whenever you forget.

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/wiki/Images/Scoreboard.jpg?raw=true" alt="In-round scoreboard" width="70%">
</p>

---

## Installation

1. Subscribe on the Steam Workshop, or grab a release from this repo instead. Each GitHub release ships one zip per terrain (Altis, Tanoa, Stratis, Livonia, Malden), named `TroubleInArmaville_<version>.<Terrain>`, since Arma needs the folder name to match the terrain to list it correctly. Livonia's is `.Enoch`, that's Livonia's actual internal terrain classname. Pick the one matching the map you want to run.
2. A Workshop subscription places the mission automatically. A manual zip needs unzipping into your Arma 3 missions directory yourself.
3. Host it or launch it in multiplayer.

The mission doesn't hardcode anything to a specific map: the arena, its loot, and where players start are all picked at runtime, not read from fixed positions. Any of the five terrains above works the same way.

---

## One server setting you must change

Turn **Kill Messages** off in your server's difficulty settings before your first round. Every player slot in this mission is `side="Civilian"`, so as far as the engine is concerned every Traitor, Detective, or Innocent kill is just one civilian killing another civilian on the "same side." With Kill Messages on, Arma broadcasts who killed whom to everyone's system chat the instant it happens, naming the killer in plain text and ending the round's entire premise on the spot.

This lives in Arma's own difficulty settings, not in this mission's `description.ext` or its lobby parameters, so nothing here can switch it off for you. If you're hosting yourself, it's in the Difficulty panel on the Host screen under the Custom preset, set it once and it sticks for future sessions on that machine. If someone else runs the server, ask them to check before your first round together.

---

## Lobby parameters

| Group | What you can set |
|---|---|
| Round | Base length, bonus time per player, Traitor bonus time, time added per death, warmup length |
| Roles | Traitor chance range, min/max Traitor count, Detective on/off + minimum players, Jester on/off + always-appears + chance, whether spectators see every living role or just what their own role would grant them |
| Gameplay | Karma on/off, starting shop credits (base + per-player scaling), kill reward credits, Traitor bonus credits per civilians killed |
| Penalties | Credits a Traitor is left with after killing the Jester, credit penalty for a Traitor killing a teammate |
| Airdrop / loot | Airdrops on/off, base + random timer, loadouts per drop, max ammo per magazine, loot power (low / balanced / anything) |
| Environment | Rain on/off + chance, fog on/off + chance, time of day (random / dawn / day / dusk / night) |
| Arena | Size (small / normal / large) |
| Testing | Enable Testing Mode, which unlocks the dev/test menu below |

<p align="center">
  <img src="https://github.com/AdamWaldie/TTTARMA3/blob/main/wiki/Images/parameters.jpg?raw=true" alt="Lobby parameters screen" width="70%">
</p>

The boolean toggles read as a numeric `{0,1}` value rather than a `{False,True}` one, because the engine silently ignores a bool-typed lobby parameter with a bool default. That was a real bug in an earlier version of this mission and it's fixed now.

---

## Equipment: no modpacks, no curated lists

There are no `modpacks/*.sqf` files anywhere in this repo. On mission start, the server scans whatever `CfgWeapons` the loaded mods actually provide and sorts it by config inheritance and stopping power: low-damage primaries and pistols go to ground loot, snipers and LMGs go to airdrops, the single highest-damage sniper and any launcher found become the Traitor shop's "Long Rifle" and "Rocket Launcher," and clothing gets bucketed by type for spawns and the Detective's loadout. Thermal optics are detected and kept out of ground loot.

Every category has a vanilla classname as a fallback, so a total-conversion mod that happens not to add pistols, say, never leaves a shop slot broken. Changing "modpacks" is just changing what you launch Arma with. Optional power thresholds live in `config.sqf` if a mod's damage values need retuning, but nothing there needs to be touched to run the mission.

---

## Keys

| Key | Does |
|---|---|
| B | Open your buy menu (Traitor / Detective only) |
| Y / U / J | Use the activation item bound to slot 1 / 2 / 3 (assign items to a slot from the Purchased panel in the buy menu) |
| L | Holster / lower weapon |
| K | Toggle the in-round scoreboard, including your role briefing |
| H | Cycle your role crest style, including a colorblind-safe palette |
| T | Hold to pick a ping type (Target / Location / Danger / Regroup Here / Enemy Spotted), release to send it (Traitors only) |
| [ | Open the dev/test menu (Testing Mode only) |
| ] | Instantly cycle your own role (Testing Mode only) |

---

## Testing / dev mode

Turn on **Enable Testing Mode** in the lobby to run the whole game solo. It stops the Traitors-win ending from kicking out a lone tester, echoes init progress to chat, and unlocks the dev/test menu (`[`) once you're in-round.

The menu is built from a registry rather than hardcoded, so anything running at preInit can add a tool with a single `Waldo_debugRegister` call and no UI edits. As shipped, it covers instant role switching (or press `]` for a no-menu cycle), every shop item and role ability fired directly, captive test dummies whose deaths run through the real kill handler, and simulated players that actually count toward the win conditions, so you can build a roster and watch Innocents win, Traitors win, time run out, or the Jester's ending resolve, all without a second person in the server. There's also a simulated lobby-size override for testing how the arena, Traitor count, and starting credits scale, plus the usual godmode/heal/teleport/dump-state utilities.

Everything here is gated on the Testing Mode parameter. With it off, the key does nothing, the server refuses to dispatch anything, and a live game behaves exactly as if none of this existed.

---

## Dependencies

Arma 3, and nothing else. CBA_A3, ACE3, ACRE2, and TFAR are all optional: the mission checks for each at runtime and uses the modded version when it's loaded (ACE Medical's full-heal call, ACE Advanced Throwing compatibility on the Teleport Grenade, ACRE2/TFAR radios instead of vanilla) but falls back to a plain-vanilla equivalent when it isn't. Nothing here ever gets bolted onto your modlist as a requirement.

---

## License

Released alongside [Waldo's Mission Pack](https://github.com/AdamWaldie/WaldosMissionPack) under the MIT License. Fork it, extend it, send a pull request.

The default intro music is "A Typical Ride Out" by Noir et Blanc Vie, royalty-free via YouTube's audio library.

---

## Credits

Built by [AdamWaldie](https://github.com/AdamWaldie). Design owes everything to GMod's original TTT and the community that kept it alive for two decades.

> "Innocents win... or do they?"
