//////////////////////////////////////////////////////////////////
// Waldo_fnc_dnaContaminate
// SERVER: watches one piece of evidence (a body, a dropped weapon, a placed
// charge) for a bounded window and counts how many DIFFERENT players come
// close to it. Each new "witness" contaminates the scene a little more, which
// Waldo_fnc_dnaScanner uses to chance a misdirected trace - so a detective can't
// just shoot someone and scan risk-free: a busy scene (a firefight, looters, a
// crowd of curious players) makes the reading less trustworthy.
//
// params: [_evidence, _excluded]  - _excluded (the victim/owner) never counts.
//////////////////////////////////////////////////////////////////

params ["_evidence", ["_excluded", objNull]];
if (!isServer) exitWith {};
if (isNull _evidence) exitWith {};

_evidence setVariable ["Waldo_dnaContamination", 0, true];

[_evidence, _excluded] spawn {
	params ["_evidence", "_excluded"];
	private _seen = [];
	private _endAt = time + 90;   // the scene "goes cold" (stops accumulating) after this
	while { time < _endAt && {!isNull _evidence} } do {
		{
			if (_x != _excluded && {!(_x in _seen)} && {_evidence distance _x < 3}) then {
				_seen pushBack _x;
				_evidence setVariable ["Waldo_dnaContamination", count _seen, true];
			};
		} forEach allPlayers;
		sleep 3;
	};
};
