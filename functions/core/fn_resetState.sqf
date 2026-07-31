//////////////////////////////////////////////////////////////////
// Waldo_fnc_resetState
// SERVER: idempotent (re)initialisation of ALL per-round state to known
// defaults. Each round is a full mission restart, but we never assume a
// clean slate — this guarantees consistent state on every replay.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

missionNamespace setVariable ["mapDone",         false,   true];
missionNamespace setVariable ["gameOn",          false,   true];
missionNamespace setVariable ["mapPos",          [0,0,0], true];
missionNamespace setVariable ["mapRadius",       50,      true];
missionNamespace setVariable ["Waldo_holdingPos", [],     true];
missionNamespace setVariable ["timelimit",       0,       true];
missionNamespace setVariable ["Waldo_startTime", 0,       true];
missionNamespace setVariable ["Waldo_roundLiveAt", 0,     true];
missionNamespace setVariable ["Waldo_deathBonusTotal", 0, true];
missionNamespace setVariable ["Waldo_detectiveRewardPaid", false, true];
missionNamespace setVariable ["Waldo_civKillTally", 0, true];
missionNamespace setVariable ["JESTERCLEANKILL", false,   true];
missionNamespace setVariable ["TraitorList",     [],      true];
missionNamespace setVariable ["DetectiveList",   [],      true];
missionNamespace setVariable ["JesterList",      [],      true];
// Whether a non-Traitor side exists (checkWin gates the Traitors-win ending on
// it). Safe default; assignRoles sets the authoritative value each round.
missionNamespace setVariable ["Waldo_hadNonTraitors", true, true];

// Dev/test: per-round flags always start cleared (the simulated player count,
// Waldo_debugPlayerCount, is intentionally left as the dev set it).
missionNamespace setVariable ["Waldo_debugSkipWarmup", false, true];
missionNamespace setVariable ["Waldo_debugFreeze",     false, true];
missionNamespace setVariable ["Waldo_debugDummies",    [],    true];
missionNamespace setVariable ["Waldo_debugSimPlayers", [],    true];

diag_log "[Waldo][server] resetState: done";
