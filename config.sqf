//////////////////////////////////////////////////////////////////
// Game Config — USER-FACING KNOBS
//
// Equipment is now DYNAMIC: Waldo_fnc_buildArsenal scans whatever mods are
// loaded and picks appropriate gear by intent (low-powered weapons for ground
// loot, snipers/launchers for the traitor shop, clothing for spawns, etc.), so
// the mission works on any modpack with no hand-curated lists.
//
// You normally leave this file alone. The only knob is an OPTIONAL override:
// if you want to force a specific, hand-picked equipment theme (e.g. a strict
// WW2 loadout), point Waldo_modpack at a file in the modpacks\ folder. It is
// loaded AFTER the dynamic pass and overrides whatever it sets.
//////////////////////////////////////////////////////////////////

// -- Optional equipment override (leave commented for fully dynamic gear) -- //

// Vanilla + DLC hand-picked list:
//Waldo_modpack = "modpacks\Vanilla.sqf";

// WW2 - Northern Fronts + JMs Second Assault (recommended when running WW2 mods,
// so modern vanilla weapons are not mixed into the dynamic pool):
//Waldo_modpack = "modpacks\WW2.sqf";

// Custom (your own edits):
//Waldo_modpack = "modpacks\Custom.sqf";
