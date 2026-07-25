//////////////////////////////////////////////////////////////////
// Waldo_fnc_checkWin
// SERVER: evaluates win conditions in priority order and returns the
// ending id ("END1".."END4") or "" if the round continues.
//
// Priority (Jester first so a clean Jester kill always resolves as such):
//   END4 Jester    - a non-Traitor killed the Jester
//   END1 Innocents - all Traitors dead
//   END2 Traitors  - all non-Traitors dead (disabled under TestingFlag)
//   END3 Time up   - timer reached the limit (>= so it can't be skipped)
//
// params: [_timer, _timelimit]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith { "" };
params ["_timer", "_timelimit"];

private _traitors = missionNamespace getVariable ["TraitorList", []];
private _testing = missionNamespace getVariable ["TestingFlag", false];
private _result = "";

// END4 - Jester killed cleanly (highest priority)
if (missionNamespace getVariable ["JESTERCLEANKILL", false]) then { _result = "END4"; };

// END1 - all Traitors eliminated
if (_result == "" && {count _traitors > 0} && {(_traitors findIf { alive _x }) == -1}) then {
	_result = "END1";
};

// END2 - all non-Traitors eliminated (a live Jester also blocks this)
if (_result == "" && {!_testing} && {(allPlayers findIf { alive _x && {!(_x in _traitors)} }) == -1}) then {
	_result = "END2";
};

// END3 - time expired
if (_result == "" && {_timer >= _timelimit}) then { _result = "END3"; };

_result
