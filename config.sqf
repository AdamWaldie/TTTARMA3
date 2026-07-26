//////////////////////////////////////////////////////////////////
// Game Config — USER-FACING KNOBS
//
// SWITCHING EQUIPMENT / MODPACKS is done from the LOBBY now: the host picks the
// "Equipment Source" parameter on the lobby screen —
//     Dynamic  - auto-detect appropriate gear from whatever mods are loaded
//     Vanilla  - the modpacks\Vanilla.sqf preset
//     WW2      - the modpacks\WW2.sqf preset (run with WW2 mods)
//     Custom   - the modpacks\Custom.sqf preset (your own edits)
// Dynamic is the default and needs no configuration.
//
// This file is only for ADVANCED / automated setups. Uncommenting a line below
// hard-pins that preset in code and OVERRIDES the lobby choice (useful for a
// dedicated server that must always run one loadout). Leave it all commented to
// let the lobby decide.
//////////////////////////////////////////////////////////////////

// -- Forced equipment preset (overrides the lobby "Equipment Source") -- //

//Waldo_modpack = "modpacks\Vanilla.sqf";
//Waldo_modpack = "modpacks\WW2.sqf";
//Waldo_modpack = "modpacks\Custom.sqf";
