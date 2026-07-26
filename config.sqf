//////////////////////////////////////////////////////////////////
// Game Config — OPTIONAL TUNING
//
// Equipment is fully DYNAMIC. Waldo_fnc_buildArsenal scans whatever mods are
// loaded and picks appropriate weapons, ammo, gear and uniforms by intent, with
// built-in vanilla classnames as fallbacks. There are no modpack preset files
// and nothing here needs setting — the mission runs on any mod loadout as-is.
//
// This file only exists for OPTIONAL tuning of the dynamic arsenal. It is
// compiled before the arsenal is built, so any variable set here is picked up.
// Everything below is commented out (defaults shown).
//////////////////////////////////////////////////////////////////

// -- Weapon power thresholds (default-magazine ammo `hit`) -- //
// Raise/lower these if a modpack's damage values classify weapons oddly.
//Waldo_arsenalLowMaxHit    = 8;    // <= this hit  -> low-powered primary (ground loot)
//Waldo_arsenalSniperMinHit = 12;   // >= this hit (+ small mag) -> sniper (traitor shop)
//Waldo_arsenalLmgMinRounds = 100;  // magazine >= this many rounds -> LMG (airdrop only)

// -- Dev/test spawn unit classes (used only in Testing Mode) -- //
// Validated + fall back to base-game classes, so normally leave these alone.
//Waldo_debugCivUnit   = "C_man_1";      // dummies + simulated players
//Waldo_debugEnemyUnit = "O_Soldier_F";  // hostile combat dummy
