# Trouble In Armaville

Trouble In Terrorist Town, rebuilt in Arma 3. Hidden roles, a round timer, a credit shop, and a DNA forensics loop that makes investigation an actual risk instead of a free look.

This wiki is split by audience. Pick the section that matches what you're trying to do.

## Playing or hosting

Everything here is written from the player's or host's chair, no code required.

- **[Roles and Win Conditions](Player-Roles-and-Win-Conditions)** - the four roles, how a round ends, and the priority order endings resolve in.
- **[Shops and Items](Player-Shops-and-Items)** - the Traitor and Detective catalogs, how buying and activation items work.
- **[Investigation Mechanics](Player-Investigation-Mechanics)** - DNA forensics, contamination, Identify Body, Dead Ringer, False Flag.
- **[Lobby Parameters](Player-Lobby-Parameters)** - every host-configurable setting, grouped and explained.

## Contributing

Everything here is for anyone reading or changing the SQF itself.

- **[Architecture](Dev-Architecture)** - the function library layout, the per-round state model, and why respawn needs special handling.
- **[Equipment System](Dev-Equipment-System)** - the dynamic, mod-independent arsenal discovery that replaces hand-curated modpacks.
- **[Dev and Test Mode](Dev-Test-Mode)** - the solo testing framework: the registry-driven menu, simulated players, and how to exercise every ending alone.
- **[Code Standards](Dev-Code-Standards)** - naming, structure, and the patterns a pull request against this repo is expected to follow.

## Quick facts

- Built for Arma 3, requires CBA_A3. ACE is not officially supported.
- Every round is a full mission restart (`BIS_fnc_endMissionServer`), so state is rebuilt from scratch each time rather than carried over in memory.
- There are no modpack preset files. Equipment is discovered from whatever mods are loaded at mission start.
- Released under the MIT License. See [LICENSE](https://github.com/AdamWaldie/TTTARMA3/blob/main/LICENSE) in the repo.

For installation, start with the repo [README](https://github.com/AdamWaldie/TTTARMA3/blob/main/README.md).
