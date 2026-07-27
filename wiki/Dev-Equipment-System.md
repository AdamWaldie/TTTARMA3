# Equipment System

There are no `modpacks/*.sqf` preset files in this mission. All weapons, ammo, gear, loot, airdrops, and clothing come from `Waldo_fnc_buildArsenal`, which runs once (server-side, during `loadParams`, before anything else reads equipment globals) and scans whatever `CfgWeapons` the loaded mods actually provide.

## How classification works

A single pass over `CfgWeapons` sorts everything it finds:

- **Weapons** are bucketed by config inheritance (`isKindOf` against `Pistol` / `Launcher` / `Rifle`), so a mod's weapons get picked up automatically as long as they inherit from the base classes the way Arma's own content does. Rifle-family primaries are then split by their default magazine's ammo `hit` value and round count into low-powered (ground loot), standard (airdrops/Detective), sniper (the Traitor shop's "Long Rifle"), or LMG (airdrops only).
- **Clothing** is bucketed by `ItemInfo` type: uniform, vest, headgear. Backpacks are a separate scan over `CfgVehicles` (they inherit `Bag_Base` there, not `CfgWeapons` like everything else here).
- **Optics** are scanned for thermal vision modes and blacklisted from ground loot if found.
- **Gear** discovery covers NVGs (`ItemInfo` type 617), plain binoculars (excluding rangefinders/designators, which carry a battery magazine and get classified as weapons instead), the highest-armour vest found that still has some cargo capacity (picking by armour alone can land on a heavy plate-carrier variant with none), and the first explosive throwable found among the `Throw` weapon's muzzles.

Every bucket has a vanilla classname as a fallback, so a total-conversion mod that happens not to add pistols, say, never leaves a shop slot or loot table empty. Ground loot honors the lobby's "Loot Power" setting (low / balanced / anything), which controls whether standard rifles get mixed in with the low-powered pool or not.

## What gets published

`buildArsenal` writes its results straight to `missionNamespace` as globals the rest of the mission reads directly: `lootPriWeapons` / `lootSecWeapons` / `lootAttachments` (ground loot), `airdropLoadouts`, `TraitorRifle`/`*Mag`/`*Optics`, `TraitorLauncher`/`*Mag`, `ShopPistol`/`*Mag`/`*Suppressor`, `ShopArmorVest`, `ShopFrag`, `ShopNVG`, `ShopBinocular`, `uniformsConfig` / `headgearsConfig` / `vestsConfig` / `backpacksConfig`, and `detectiveConfig`.

`vestsConfig` and `backpacksConfig` are deliberately not just spawn-loadout pools: `Waldo_fnc_populateLoot` also draws from them to place better armour and backpacks as ground loot, on top of the one starting vest everyone spawns with. Neither is ever handed out for free beyond that - both are things a player finds, the same way a better weapon is.

## Changing "modpacks"

There isn't a modpack switch. Changing what's available means changing what mods you launch Arma with; the next mission start rescans and adapts. The only optional tuning is the power thresholds in `config.sqf` (`Waldo_arsenalLowMaxHit`, `Waldo_arsenalSniperMinHit`, `Waldo_arsenalLmgMinRounds`), useful if a particular mod's damage values classify its weapons oddly against the vanilla-tuned defaults. Nothing there needs to be touched to run the mission on a fresh mod list.
