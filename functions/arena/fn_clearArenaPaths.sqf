//////////////////////////////////////////////////////////////////
// Waldo_fnc_clearArenaPaths
// SERVER: cuts a gate through any wall/fence line that genuinely divides
// the arena into two halves players can't cross between.
//
// Waldo_fnc_selectArena only scores candidates by lootable-building count -
// it has no idea whether the interior is actually walkable end to end. A
// town's own property fence, walled compound, or similar terrain object can
// land running across an otherwise good arena. This never touches
// Waldo_fnc_buildArena's own OUTER perimeter wall (the intended containment
// fence) - only existing map terrain found inside the arena.
//
// PARALLEL CHORD SWEEPS, not just diameters through the centre: 3 sweep
// angles (0/60/120 degrees), each generating a full bank of parallel chords
// spanning the ENTIRE arena width - catches an obstruction that seals off a
// corner or any other off-centre chunk, not only ones passing near the
// exact middle.
//
// URBAN FALSE POSITIVES: an arena worth playing on is, almost by
// definition, in or near a town, and towns are full of small, perfectly
// walkable-around yard/garden fences a single probe line will legitimately
// cross without that fence being any kind of real problem. Treating any one
// blocked chord as "the arena is split" would false-positive constantly and
// start deleting ordinary property fencing all over the map. Instead, a
// chord only counts as part of a real divider once it's in a RUN of at
// least 3 CONSECUTIVE blocked chords in the same sweep - meaning the
// obstruction spans a real stretch of the arena's width, not one localised
// fence a player could just step around. Only the middle chord of each such
// run gets a gate cut through it.
//
// HILLY TERRAIN: each chord is walked in ~25m sub-segments, not one
// straight line from edge to edge, with ground height resampled at every
// step - a hill or dip partway along a long chord can't make the probe
// silently pass over (or under) a fence sitting on it.
//
// BAILS TO A RESELECT rather than carving up a hopelessly fragmented
// arena: if more than 2 separate dividing runs are found across every sweep
// combined, this returns false without clearing anything, and
// Waldo_fnc_initServer re-rolls the whole arena (bounded retries) instead
// of turning one location into Swiss cheese. _force skips this bail (used
// as the last-resort fallback once retries are exhausted - clearing
// everything found is still better than leaving the round genuinely
// uncrossable).
//
// Only objects inheriting from CfgVehicles' "Wall" base class count as a
// blocker - covers the vast majority of real placeable fences/walls
// without also sweeping up unrelated large objects nearby.
//
// params: [_force] (default false)
// returns: BOOL - true if the arena is fine as-is (0-2 gates cut, or none
// needed, or _force was set), false if it was too fragmented and nothing
// was cleared - Waldo_fnc_initServer should reselect and try again.
//////////////////////////////////////////////////////////////////

params [["_force", false]];
if (!isServer) exitWith { true };

private _center = missionNamespace getVariable ["mapPos", [0,0,0]];
private _radius = missionNamespace getVariable ["mapRadius", 50];

private _groundZ = {
	params ["_p"];
	private _probe = "groundweaponholder" createVehicle [_p select 0, _p select 1, 0];
	private _z = getPosWorld _probe select 2;
	deleteVehicle _probe;
	_z
};

// Walks _p1 -> _p2 in ~25m ground-hugging sub-segments, stopping the moment
// any one hits a Wall-class object. Returns [_blocked, _hitObj].
private _testChord = {
	params ["_p1", "_p2"];
	private _segLen = 25;
	private _fullDist = _p1 distance2D _p2;
	private _steps = ceil (_fullDist / _segLen) max 1;
	private _blocked = false;
	private _hitObj = objNull;
	private _prevXY = _p1;
	private _prevZ = ([_p1 select 0, _p1 select 1] call _groundZ) + 1;
	private _s = 1;
	while { !_blocked && {_s <= _steps} } do {
		private _t = _s / _steps;
		private _nextXY = [
			(_p1 select 0) + (((_p2 select 0) - (_p1 select 0)) * _t),
			(_p1 select 1) + (((_p2 select 1) - (_p1 select 1)) * _t)
		];
		private _nextZ = ([_nextXY select 0, _nextXY select 1] call _groundZ) + 1;
		private _hits = lineIntersectsObjs [
			[_prevXY select 0, _prevXY select 1, _prevZ],
			[_nextXY select 0, _nextXY select 1, _nextZ],
			objNull, objNull, false
		];
		{
			if (!_blocked && {!isNull _x} && {typeOf _x isKindOf "Wall"}) then {
				_blocked = true;
				_hitObj = _x;
			};
		} forEach _hits;
		_prevXY = _nextXY;
		_prevZ = _nextZ;
		_s = _s + 1;
	};
	[_blocked, _hitObj]
};

// Deletes the blocking object plus its immediate neighbours (widening a
// single segment into an actually-walkable gap), returns how many were removed.
private _cutGate = {
	params ["_hitObj"];
	private _cleared = 0;
	if (!isNull _hitObj) then {
		private _nearby = nearestObjects [getPosATL _hitObj, ["Wall"], 8];
		{
			if (!isNull _x && {typeOf _x isKindOf "Wall"}) then {
				deleteVehicle _x;
				_cleared = _cleared + 1;
			};
		} forEach (_nearby + [_hitObj]);
	};
	_cleared
};

// ~20 chords per sweep regardless of arena size, floored so a small arena
// doesn't get an excessive number of tiny, near-redundant chords.
private _step = ((2 * _radius) / 20) max 8;
private _totalRuns = 0;
private _pendingGates = [];   // hitObj per confirmed dividing run - collected before any deletion, so clearing one run can't disturb another run's own scan mid-sweep

{
	private _sweepAngle = _x;
	private _perpAngle = _sweepAngle + 90;
	private _chords = [];   // [_blocked, _hitObj] per chord, in offset order

	private _offset = -_radius + (_step / 2);
	while { _offset < _radius } do {
		private _halfLen = sqrt (((_radius ^ 2) - (_offset ^ 2)) max 0);
		if (_halfLen > 1) then {
			// getPos's distance is only ever passed non-negative here (flip the
			// angle 180 instead of trusting a negative distance to behave) -
			// avoids relying on undocumented behaviour for a value that's
			// negative for exactly half of every sweep's offsets.
			private _mid = if (_offset >= 0) then {
				_center getPos [_offset, _perpAngle]
			} else {
				_center getPos [-_offset, _perpAngle + 180]
			};
			private _p1 = _mid getPos [_halfLen, _sweepAngle];
			private _p2 = _mid getPos [_halfLen, _sweepAngle + 180];
			([_p1, _p2] call _testChord) params ["_blocked", "_hitObj"];
			_chords pushBack [_blocked, _hitObj];
		};
		_offset = _offset + _step;
	};

	// Scan for runs of >= 3 consecutive blocked chords; only the middle
	// chord of each qualifying run is queued for an actual gate cut.
	private _runStart = -1;
	private _queueRun = {
		params ["_chords", "_runStart", "_runEnd"];
		private _runLen = _runEnd - _runStart;
		if (_runLen >= 3) then {
			private _midIdx = _runStart + floor (_runLen / 2);
			[true, (_chords select _midIdx) select 1]
		} else {
			[false, objNull]
		};
	};
	for "_i" from 0 to (count _chords - 1) do {
		if ((_chords select _i) select 0) then {
			if (_runStart < 0) then { _runStart = _i; };
		} else {
			if (_runStart >= 0) then {
				([_chords, _runStart, _i] call _queueRun) params ["_qualifies", "_hitObj"];
				if (_qualifies) then { _totalRuns = _totalRuns + 1; _pendingGates pushBack _hitObj; };
				_runStart = -1;
			};
		};
	};
	if (_runStart >= 0) then {
		([_chords, _runStart, count _chords] call _queueRun) params ["_qualifies", "_hitObj"];
		if (_qualifies) then { _totalRuns = _totalRuns + 1; _pendingGates pushBack _hitObj; };
	};
} forEach [0, 60, 120];

if (_totalRuns > 2 && !_force) exitWith {
	diag_log format ["[Waldo][server] clearArenaPaths: %1 dividing runs found - too fragmented, recommending reselect", _totalRuns];
	false
};

private _totalCleared = 0;
{ _totalCleared = _totalCleared + ([_x] call _cutGate); } forEach _pendingGates;

diag_log format ["[Waldo][server] clearArenaPaths: dividing runs=%1 segments cleared=%2 forced=%3", _totalRuns, _totalCleared, _force];
true
