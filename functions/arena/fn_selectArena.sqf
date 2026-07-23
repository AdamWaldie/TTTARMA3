//////////////////////////////////////////////////////////////////
// Waldo_fnc_selectArena
// SERVER: choose the arena centre and radius. Scores candidate positions by
// how many ENTERABLE (loot-bearing) buildings sit inside the radius and picks
// the best one, so we never centre on an empty field / non-enterable cluster
// where no ground loot can spawn. Prefers named towns, then a random search,
// and always falls back to the best-scoring spot found. Sets mapPos/mapRadius.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _playerCount = (count allPlayers) max 1;
private _radius = 50 + (_playerCount * 7.5);
missionNamespace setVariable ["mapRadius", _radius, true];

// Count buildings within the radius that actually have interior loot positions.
private _lootableCount = {
	params ["_p"];
	private _buildings = nearestTerrainObjects [_p, ["Building", "House"], _radius];
	{ count ([_x] call BIS_fnc_buildingPositions) > 0 } count _buildings
};

// Aim for a decent minimum of enterable buildings regardless of lobby size.
private _target = _playerCount max 6;

private _bestPos = [];
private _bestScore = -1;

// Consider a candidate position, keeping the best-scoring one seen so far.
private _consider = {
	params ["_cand"];
	if (surfaceIsWater _cand) exitWith {};
	private _score = [_cand] call _lootableCount;
	if (_score > _bestScore) then { _bestScore = _score; _bestPos = _cand; };
};

// --- Preferred: named towns (scan a shuffled, capped set) ---
private _towns = (nearestLocations [[0,0,0], ["NameVillage", "NameCity", "NameCityCapital"], 50000]) call BIS_fnc_arrayShuffle;
if (count _towns > 40) then { _towns resize 40; };
{ [locationPosition _x] call _consider; } forEach _towns;

// --- Random search if towns didn't reach the target ---
if (_bestScore < _target) then {
	private _attempts = 0;
	while { _bestScore < _target && _attempts < 300 } do {
		_attempts = _attempts + 1;
		[[nil, ["water"]] call BIS_fnc_randomPos] call _consider;
	};
};

// --- Last resort: never hang (only if literally nothing lootable was found) ---
if (_bestScore <= 0 || {_bestPos isEqualTo []}) then {
	_bestPos = [nil, ["water"]] call BIS_fnc_randomPos;
	diag_log "[Waldo][server] selectArena: last-resort position (no lootable buildings found)";
};

private _empty = _bestPos findEmptyPosition [0, 15];
if !(_empty isEqualTo []) then { _bestPos = _empty; };

missionNamespace setVariable ["mapPos", _bestPos, true];
diag_log format ["[Waldo][server] selectArena: pos=%1 radius=%2 lootableBuildings=%3 (target %4)",
	_bestPos, _radius, _bestScore, _target];
_bestScore >= _target
