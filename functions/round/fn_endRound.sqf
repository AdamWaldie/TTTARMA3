//////////////////////////////////////////////////////////////////
// Waldo_fnc_endRound
// SERVER: ends the round with the given debriefing ending.
// params: [_ending]  ("END1".."END4")
//////////////////////////////////////////////////////////////////

params ["_ending"];
if (!isServer) exitWith {};

missionNamespace setVariable ["gameOn", false, true];
diag_log ("[Waldo][server] endRound: " + _ending);
_ending call BIS_fnc_endMissionServer;
