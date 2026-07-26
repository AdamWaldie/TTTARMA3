//////////////////////////////////////////////////////////////////
// Waldo_fnc_endRound
// SERVER: ends the round with the given debriefing ending.
// params: [_ending]  ("END1".."END4")
//////////////////////////////////////////////////////////////////

params ["_ending"];
if (!isServer) exitWith {};

missionNamespace setVariable ["gameOn", false, true];
diag_log ("[Waldo][server] endRound: " + _ending);

// Announce the round's MVP (opening music + a small celebration) and give it a
// few seconds to play before the mission actually restarts.
[] call Waldo_fnc_roundMVP;

_ending call BIS_fnc_endMissionServer;
