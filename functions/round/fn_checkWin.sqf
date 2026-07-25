//////////////////////////////////////////////////////////////////
// Waldo_fnc_checkWin
// SERVER: evaluates win conditions in priority order and returns the ending id
// ("END1".."END4") or "" if the round continues.
//
// Priority (Jester first so a clean Jester kill always resolves as such):
//   END4 Jester    - a non-Traitor killed the Jester
//   END1 Innocents - a Traitor side existed and all of them are dead
//   END2 Traitors  - a Traitor side existed, non-Traitors existed, and none are
//                    left alive (a live Jester counts as a non-Traitor, so it
//                    blocks this until it is dead)
//   END3 Time up   - timer reached the limit (>= so it can't be skipped)
//
// Roster: real players always. Under Testing Mode, alive simulated players
// (Waldo_debugSimPlayers, spawned from the dev menu) are added so endings can be
// constructed and verified solo — traitor sims are already in TraitorList, so
// they count for END1 too. With Testing Mode off the roster is exactly
// allPlayers and every gate below matches the original semantics, so live games
// are unaffected.
//
// Strengthening over the old check: every membership test is null-safe, END1
// and END2 both require a Traitor side to have existed, and END2 additionally
// requires that non-Traitors existed this round (Waldo_hadNonTraitors) so an
// all-Traitor lobby can no longer insta-win and a lone tester never ends
// themselves.
//
// params: [_timer, _timelimit]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith { "" };
params ["_timer", "_timelimit"];

private _traitors = missionNamespace getVariable ["TraitorList", []];
private _testing  = missionNamespace getVariable ["TestingFlag", false];
private _result = "";

// --- Roster of combatants to weigh for END2 (real players + sim players). ---
private _roster = +allPlayers;
if (_testing) then {
	{
		if (!isNull _x && {alive _x}) then { _roster pushBackUnique _x; };
	} forEach (missionNamespace getVariable ["Waldo_debugSimPlayers", []]);
};

private _aliveTraitors    = _traitors findIf { !isNull _x && {alive _x} };
private _aliveNonTraitors = _roster   findIf { !isNull _x && {alive _x} && {!(_x in _traitors)} };
private _hadNonTraitors   = missionNamespace getVariable ["Waldo_hadNonTraitors", true];

// END4 - Jester killed cleanly (highest priority)
if (missionNamespace getVariable ["JESTERCLEANKILL", false]) then { _result = "END4"; };

// END1 - a Traitor side existed and all Traitors are dead
if (_result == "" && {count _traitors > 0} && {_aliveTraitors == -1}) then {
	_result = "END1";
};

// END2 - a Traitor side existed, non-Traitors existed, and none remain alive
if (_result == "" && {count _traitors > 0} && {_hadNonTraitors} && {_aliveNonTraitors == -1}) then {
	_result = "END2";
};

// END3 - time expired
if (_result == "" && {_timer >= _timelimit}) then { _result = "END3"; };

_result
