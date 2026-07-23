//////////////////////////////////////////////////////////////////
// Game Config — USER-FACING KNOBS
//
// The heavy lifting (reading mission parameters, loading the modpack,
// publishing everything) is done by Waldo_fnc_loadParams. This file just
// picks which equipment modpack to use so it is easy to change.
//////////////////////////////////////////////////////////////////

// -- Equipment Options -- //
// Choose ONE modpack below. Custom.sqf is for your own personal changes.
// Modpack files live in the modpacks\ folder.

// Vanilla + DLC (NO CDLC)
Waldo_modpack = "modpacks\Vanilla.sqf";

// WW2 - Northern Fronts + JMs Second Assault
//Waldo_modpack = "modpacks\WW2.sqf";

// Custom (your edits, by default a copy of Vanilla)
//Waldo_modpack = "modpacks\Custom.sqf";
