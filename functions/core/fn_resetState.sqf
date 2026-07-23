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
missionNamespace setVariable ["timelimit",       0,       true];
missionNamespace setVariable ["Waldo_startTime", 0,       true];
missionNamespace setVariable ["JESTERCLEANKILL", false,   true];
missionNamespace setVariable ["TraitorList",     [],      true];
missionNamespace setVariable ["DetectiveList",   [],      true];
missionNamespace setVariable ["JesterList",      [],      true];

diag_log "[Waldo][server] resetState: done";
