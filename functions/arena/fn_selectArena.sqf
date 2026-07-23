//////////////////////////////////////////////////////////////////
// Waldo_fnc_selectArena
// SERVER: choose the arena centre and radius. Prefers to CENTRE the arena
// on a real named town with enough lootable buildings (the old code picked
// a town then threw it away for a random position — dead code). Falls back
// to a bounded random-position search, then a last-resort position so this
// can never hang. Sets mapPos / mapRadius.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _playerCount = (count allPlayers) max 1;
private _radius = 50 + (_playerCount * 7.5);
missionNamespace setVariable ["mapRadius", _radius, true];

private _lootableCount = {
	// counts buildings near _pos that actually have interior loot positions
	params ["_p"];
	private _buildings = nearestTerrainObjects [_p, ["Building", "House"], _radius];
	{ count ([_x] call BIS_fnc_buildingPositions) > 0 } count _buildings
};

private _pos = [0,0,0];
private _found = false;

// --- Preferred: centre on a named town ---
private _towns = (nearestLocations [[0,0,0], ["NameVillage", "NameCity", "NameCityCapital"], 50000]) call BIS_fnc_arrayShuffle;
private _townIdx = _towns findIf {
	private _c = locationPosition _x;
	!surfaceIsWater _c && {([_c] call _lootableCount) >= _playerCount}
};
if (_townIdx > -1) then {
	_pos = locationPosition (_towns select _townIdx);
	_found = true;
};

// --- Fallback: bounded random-position search on land ---
if (!_found) then {
	private _attempts = 0;
	while { !_found && _attempts < 200 } do {
		_attempts = _attempts + 1;
		private _cand = [nil, ["water"]] call BIS_fnc_randomPos;
		if ((count (nearestTerrainObjects [_cand, ["House"], _radius])) > (5 + _playerCount)) then {
			if (([_cand] call _lootableCount) >= _playerCount) then {
				_pos = _cand;
				_found = true;
			};
		};
	};
};

// --- Last resort: never hang ---
if (!_found) then {
	_pos = [nil, ["water"]] call BIS_fnc_randomPos;
	diag_log "[Waldo][server] selectArena: last-resort position (no ideal town/area found)";
};

private _empty = _pos findEmptyPosition [0, 15];
if !(_empty isEqualTo []) then { _pos = _empty; };

missionNamespace setVariable ["mapPos", _pos, true];
diag_log format ["[Waldo][server] selectArena: pos=%1 radius=%2 townCentred=%3", _pos, _radius, _found];
_found
