# Trouble In Armaville

Trouble In Terrorist Town, rebuilt in Arma 3. Hidden roles, a round timer, a credit shop, and a DNA forensics loop that makes investigation an actual risk instead of a free look.

This wiki covers how the mission works under the hood. For installation and lobby setup, start with the repo [README](https://github.com/AdamWaldie/TTTARMA3/blob/main/README.md); come here for the mechanics in more depth than a README can hold.

## Pages

- **[Roles and Win Conditions](Roles-and-Win-Conditions)** - the four roles, how a round ends, and the priority order endings resolve in.
- **[Shops and Items](Shops-and-Items)** - the Traitor and Detective catalogs, how buying and activation items work.
- **[Investigation Mechanics](Investigation-Mechanics)** - DNA forensics, contamination, Identify Body, Dead Ringer, False Flag.
- **[Equipment System](Equipment-System)** - the dynamic, mod-independent arsenal discovery that replaces hand-curated modpacks.
- **[Lobby Parameters](Lobby-Parameters)** - every host-configurable setting, grouped and explained.
- **[Dev and Test Mode](Dev-and-Test-Mode)** - the solo testing framework: the registry-driven menu, simulated players, and how to exercise every ending alone.
- **[Architecture](Architecture)** - the function library layout, the per-round state model, and why respawn needs special handling.

## Quick facts

- Built for Arma 3, requires CBA_A3. ACE is not officially supported.
- Every round is a full mission restart (`BIS_fnc_endMissionServer`), so state is rebuilt from scratch each time rather than carried over in memory.
- There are no modpack preset files. Equipment is discovered from whatever mods are loaded at mission start.
