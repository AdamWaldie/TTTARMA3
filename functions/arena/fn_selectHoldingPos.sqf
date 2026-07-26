//////////////////////////////////////////////////////////////////
// Waldo_fnc_selectHoldingPos
// SERVER: picks one safe, non-water position for players to stand at while
// they wait for the real arena (Waldo_fnc_selectArena runs later and can
// take a few seconds to score candidate towns). mission.sqm's placed player
// positions are only ever valid on the one terrain a mission was saved on;
// this is found at runtime instead, so the same mission works on Altis,
// Tanoa, Stratis, Livonia, or any other terrain with no per-terrain data.
// Fast by design (no building/loot scoring, just a land check) so it's
// ready almost immediately, well before the real arena is.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _pos = [];
private _attempts = 0;
while { _pos isEqualTo [] && {_attempts < 200} } do {
	_attempts = _attempts + 1;
	private _cand = [nil, ["water"]] call BIS_fnc_randomPos;
	if (!surfaceIsWater _cand) then { _pos = _cand; };
};

// Never hang: if literally nothing came back land-side in 200 tries, [0,0,0]
// is used as-is. Every client's own findEmptyPosition call still keeps them
// spread apart even in that case.
if (_pos isEqualTo []) then { _pos = [0, 0, 0]; };

missionNamespace setVariable ["Waldo_holdingPos", _pos, true];
diag_log format ["[Waldo][server] selectHoldingPos: %1 (attempts=%2)", _pos, _attempts];
