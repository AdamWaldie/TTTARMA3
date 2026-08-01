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
// definition, in or near a town - the best arenas are the densest, most
// interesting ones, and those are exactly the ones with the most ordinary
// clutter (yard fences, garden walls, buildings built flush against each
// other) for a probe line to legitimately cross without any of it being a
// real problem. An early version of this required only 3 consecutive
// blocked chords, which turned out to still trip constantly in exactly the
// good, dense towns worth playing on - normal fence density there is
// enough to blocked-chord several nearby, entirely UNRELATED small fences
// in a row, which isn't the same thing as one continuous dividing wall at
// all. Deliberately conservative now instead: a run only qualifies once it
// spans at least 55% of that sweep's FULL width in consecutive blocked
// chords - a bar ordinary town clutter essentially never clears, that only
// an obstruction dominating almost the entire arena in one direction can
// meet. Some genuine but smaller/off-axis splits may go uncaught as the
// cost of that; see the header note on why that trade was made deliberately.
//
// Buildings are NEVER treated as a blocker (only CfgVehicles' "Wall" base
// class counts - see below) for the same reason: a solid row of buildings
// built against each other is completely normal, desirable town layout,
// not a problem to flag.
//
// HILLY TERRAIN: each chord is walked in ~25m sub-segments, not one
// straight line from edge to edge, with ground height resampled at every
// step - a hill or dip partway along a long chord can't make the probe
// silently pass over (or under) a fence sitting on it.
//
// PREFERS A RESELECT over gate-cutting: finding even ONE run under this
// much stricter bar is now a strong signal of a genuinely bad location, not
// routine clutter - so by default this returns false and clears NOTHING as
// soon as any run qualifies, letting Waldo_fnc_initServer re-roll the whole
// arena (bounded retries) instead. _force skips this bail entirely and
// clears every run found instead - used only as the last-resort fallback
// once retries are exhausted, since a round with a gate cut through it is
// still better than one that's genuinely uncrossable.
//
// Only objects inheriting from CfgVehicles' "Wall" base class count as a
// blocker - covers the vast majority of real placeable fences/walls
// without also sweeping up unrelated large objects nearby.
//
// params: [_force] (default false)
// returns: BOOL - true if the arena is fine as-is (no qualifying run found,
// or _force was set and everything found got cleared), false if a
// dominating obstruction was found and nothing was cleared -
// Waldo_fnc_initServer should reselect and try again.
//////////////////////////////////////////////////////////////////

params [["_force", false]];
if (!isServer) exitWith { true };

private _center = missionNamespace getVariable ["mapPos", [0,0,0]];
private _radius = missionNamespace getVariable ["mapRadius", 50];

// Takes X/Y as two separate args, not a position array - every call site
// passes [_p1 select 0, _p1 select 1] call _groundZ, which hands this
// _this = [x, y] (two numbers), not a single [x,y] array wrapped as one
// arg. A single "_p" param name was only ever binding to the first of the
// two (the X value alone, a Number) - confirmed via RPT ("Type Number,
// expected Array" on "_p select 0", the instant this was first exercised
// live), so the signature has to actually match two arguments instead of
// pretending they arrive pre-wrapped.
private _groundZ = {
	params ["_x", "_y"];
	private _probe = "groundweaponholder" createVehicle [_x, _y, 0];
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

	// Scan for a run of consecutive blocked chords spanning at least 55% of
	// this sweep's chord count (see the header note on why this bar is
	// deliberately this high) - the middle chord of each qualifying run is
	// what a forced clear (see below) would actually cut a gate through.
	private _minRunLen = ceil (0.55 * (count _chords));
	private _runStart = -1;
	private _queueRun = {
		params ["_chords", "_runStart", "_runEnd", "_minRunLen"];
		private _runLen = _runEnd - _runStart;
		if (_runLen >= _minRunLen) then {
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
				([_chords, _runStart, _i, _minRunLen] call _queueRun) params ["_qualifies", "_hitObj"];
				if (_qualifies) then { _totalRuns = _totalRuns + 1; _pendingGates pushBack _hitObj; };
				_runStart = -1;
			};
		};
	};
	if (_runStart >= 0) then {
		([_chords, _runStart, count _chords, _minRunLen] call _queueRun) params ["_qualifies", "_hitObj"];
		if (_qualifies) then { _totalRuns = _totalRuns + 1; _pendingGates pushBack _hitObj; };
	};
} forEach [0, 60, 120];

if (_totalRuns > 0 && !_force) exitWith {
	diag_log format ["[Waldo][server] clearArenaPaths: %1 dominating run(s) found - recommending reselect", _totalRuns];
	false
};

private _totalCleared = 0;
{ _totalCleared = _totalCleared + ([_x] call _cutGate); } forEach _pendingGates;

diag_log format ["[Waldo][server] clearArenaPaths: dividing runs=%1 segments cleared=%2 forced=%3", _totalRuns, _totalCleared, _force];
true
