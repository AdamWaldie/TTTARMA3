//////////////////////////////////////////////////////////////////
// Waldo_fnc_loadParams
// SERVER: builds the dynamic equipment arsenal synchronously, reads the mission
// parameters, publishes everything to missionNamespace, then raises the
// Waldo_configReady flag so clients can safely read the config.
//
// Building the arsenal synchronously (instead of the old fire-and-forget
// execVM modpack load) fixes the replay race where consumers ran before the
// equipment globals existed (nil -> aborted scripts).
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

diag_log "[Waldo][server] loadParams: begin";

// Read + publish the lobby parameters. Indices MUST match the class order in
// description.ext's `class Params` (see the note there - reorganised into
// logical groups 2026-08-01, so these indices no longer match any older
// saved lobby preset). Boolean toggles use a {0,1} value read numerically
// ((param) != 0) - a bool default silently ignores the lobby selection.

// --- Round ---
missionNamespace setVariable ["roundBaseLength",    param [0, 180], true];
missionNamespace setVariable ["roundPlayerLength",  param [1, 30],  true];
missionNamespace setVariable ["roundTraitorLength", param [2, 45],  true];
missionNamespace setVariable ["roundDeadLength",    param [3, 30],  true];
missionNamespace setVariable ["roundWarmupLength",  param [4, 20],  true];

// --- Roles ---
missionNamespace setVariable ["TraitorPercentageChanceLowerBound", (param [5, 25]) / 100, true];
missionNamespace setVariable ["TraitorPercentageChanceHigherBound",(param [6, 45]) / 100, true];
missionNamespace setVariable ["Waldo_minTraitors",       param [7, 1], true];
missionNamespace setVariable ["Waldo_maxTraitors",       param [8, 0], true];   // 0 = unlimited
missionNamespace setVariable ["DetectiveEnabled",       (param [9, 1]) != 0, true];
missionNamespace setVariable ["DetectiveMinPlayers",     param [10, 5], true];
missionNamespace setVariable ["JesterEnabled",          (param [11, 1]) != 0, true];
missionNamespace setVariable ["JesterMinPlayers",        param [12, 10], true];
missionNamespace setVariable ["JesterAlways",           (param [13, 0]) != 0, true];
missionNamespace setVariable ["JesterPercentagechance", (param [14, 30]) / 100, true];
missionNamespace setVariable ["Waldo_spectatorsSeeAllRoles", (param [15, 0]) != 0, true];

// --- Gameplay / economy ---
missionNamespace setVariable ["KarmaEnabled",           (param [16, 1]) != 0, true];
missionNamespace setVariable ["Waldo_startCreditsBase",  param [17, 1], true];
missionNamespace setVariable ["Waldo_startCreditsPerNPlayers", param [18, 8], true];
missionNamespace setVariable ["Waldo_killReward",        param [19, 1], true];
missionNamespace setVariable ["Waldo_civKillBonusEvery",  param [20, 5], true];

// --- Airdrop / loot ---
missionNamespace setVariable ["airdrop",               (param [21, 1]) != 0, true];
missionNamespace setVariable ["airdropBaseTimer",       param [22, 75], true];
missionNamespace setVariable ["airdropRandomTimer",     param [23, 75], true];
missionNamespace setVariable ["airdropLoadoutsAmount",  param [24, 1],  true];
missionNamespace setVariable ["lootMaxBullets",         param [25, 50], true];
missionNamespace setVariable ["Waldo_lootPower",        param [26, 1],  true];

// --- Environment ---
missionNamespace setVariable ["allowRain",  (param [27, 1]) != 0,   true];
missionNamespace setVariable ["chanceRain", (param [28, 40]) / 100, true];
missionNamespace setVariable ["allowFog",   (param [29, 1]) != 0,   true];
missionNamespace setVariable ["chanceFog",  (param [30, 20]) / 100, true];
missionNamespace setVariable ["timeOfDay",   param [31, 2],         true];

// --- Arena ---
missionNamespace setVariable ["Waldo_arenaScale", param [32, 100], true];

// --- Testing ---
missionNamespace setVariable ["TestingFlag", (param [33, 0]) != 0, true];

// --- Penalties ---
missionNamespace setVariable ["Waldo_jesterKillPenalty",       param [34, 8], true];
missionNamespace setVariable ["Waldo_traitorTeamkillPenalty",  param [35, 2], true];

// No HUD/role-crest-style param - that's a per-player preference now
// (Waldo_roleCrestStylePref in each client's own profileNamespace, set via
// the H key), not something read from the lobby here.

// --- Equipment (synchronous) ---
// The SOLE equipment source is dynamic, intent-aware discovery. Built AFTER the
// params above so it can honour Waldo_lootPower; it publishes loot/airdrop/shop/
// clothing gear for whatever mods are loaded, with vanilla fallbacks so nothing
// is ever unset. There are no per-modpack preset files.
[] call Waldo_fnc_buildArsenal;

missionNamespace setVariable ["Waldo_configReady", true, true];
diag_log "[Waldo][server] loadParams: configReady";
