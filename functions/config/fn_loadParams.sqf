//////////////////////////////////////////////////////////////////
// Waldo_fnc_loadParams
// SERVER: loads the equipment modpack synchronously, reads the mission
// parameters, publishes everything to missionNamespace, then raises the
// Waldo_configReady flag so clients can safely read the config.
//
// Loading the modpack synchronously (instead of the old fire-and-forget
// execVM) fixes the replay race where consumers ran before the modpack's
// globals/configs existed (nil -> aborted scripts).
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

diag_log "[Waldo][server] loadParams: begin";

// --- Equipment modpack (synchronous) ---
private _modpack = if (isNil "Waldo_modpack") then { "modpacks\Vanilla.sqf" } else { Waldo_modpack };
call compile preprocessFileLineNumbers _modpack;
diag_log ("[Waldo][server] loadParams: modpack loaded -> " + _modpack);

// --- Round options ---
missionNamespace setVariable ["roundBaseLength",    param [0, 180], true];
missionNamespace setVariable ["roundPlayerLength",  param [1, 30],  true];
missionNamespace setVariable ["roundTraitorLength", param [2, 45],  true];
missionNamespace setVariable ["roundDeadLength",    param [3, 30],  true];
missionNamespace setVariable ["roundWarmupLength",  param [4, 20],  true];

// --- Airdrop options ---
missionNamespace setVariable ["airdrop",               param [5, true], true];
missionNamespace setVariable ["airdropBaseTimer",      param [6, 75],   true];
missionNamespace setVariable ["airdropRandomTimer",    param [7, 75],   true];
missionNamespace setVariable ["airdropLoadoutsAmount", param [8, 1],    true];
missionNamespace setVariable ["lootMaxBullets",        param [9, 50],   true];

// --- Weather options (chances stored as 0..1 fractions) ---
missionNamespace setVariable ["allowRain",  param [10, true],          true];
missionNamespace setVariable ["chanceRain", (param [11, 40]) / 100,    true];
missionNamespace setVariable ["allowFog",   param [12, true],          true];
missionNamespace setVariable ["chanceFog",  (param [13, 20]) / 100,    true];
missionNamespace setVariable ["timeFrom",   param [14, 5],             true];
missionNamespace setVariable ["timeTo",     param [15, 19],            true];

// --- Game options ---
missionNamespace setVariable ["JesterEnabled",                      param [16, false],        true];
missionNamespace setVariable ["JesterPercentagechance",            (param [17, 30]) / 100,    true];
missionNamespace setVariable ["TraitorPercentageChanceLowerBound", (param [18, 25]) / 100,    true];
missionNamespace setVariable ["TraitorPercentageChanceHigherBound",(param [19, 45]) / 100,    true];

// --- Testing ---
missionNamespace setVariable ["TestingFlag", param [20, false], true];

missionNamespace setVariable ["Waldo_configReady", true, true];
diag_log "[Waldo][server] loadParams: configReady";
