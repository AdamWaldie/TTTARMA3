//////////////////////////////////////////////////////////////////
// Waldo_fnc_clearArenaPaths
// SERVER: cuts a gate through any wall/fence line that fully blocks a
// straight path across the arena. Waldo_fnc_selectArena only scores
// candidates by lootable-building count, with no awareness of whether the
// interior is actually walkable end to end - a town's own property fence,
// a walled compound, or similar can land running straight across the
// middle of an otherwise good arena, splitting it into two halves players
// can never cross between. This never touches Waldo_fnc_buildArena's own
// OUTER perimeter wall (that's the intended containment fence) - only
// existing MAP terrain objects found strictly inside the arena.
//
// Deliberately a handful of straight-line probes through the centre (6
// diameters, 30 degrees apart - 12 directions of coverage), not a full
// pathability flood-fill: cheap to run during arena setup, and the actual
// reported case (a single fence/wall/property line cutting straight
// across) is exactly what a line probe catches. Only objects inheriting
// from CfgVehicles' "Wall" base class count as a blocker - that covers the
// vast majority of real placeable fences/walls without also sweeping up
// unrelated large objects that happen to sit near the line.
//
// "Cuts a gate" rather than deleting the whole obstruction: only the
// blocking segment plus its immediate neighbours (so the gap is actually
// wide enough to walk through, not just one narrow post-width) are
// removed - the rest of the fence/wall stays standing and reads as a
// normal gap in it, not a fence that mysteriously vanished entirely.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _center = missionNamespace getVariable ["mapPos", [0,0,0]];
private _radius = missionNamespace getVariable ["mapRadius", 50];

// Real ground height at a given XY - same "spawn a throwaway groundweaponholder,
// read its settled Z, delete it" technique Waldo_fnc_buildArena's own perimeter
// scan already uses, rather than trusting getPos's own Z (which isn't
// guaranteed to reflect real terrain height at the offset point).
private _groundZ = {
	params ["_p"];
	private _probe = "groundweaponholder" createVehicle [_p select 0, _p select 1, 0];
	private _z = getPosWorld _probe select 2;
	deleteVehicle _probe;
	_z
};

private _cleared = 0;
for "_i" from 0 to 5 do {
	private _angle = _i * 30;
	private _a = _center getPos [_radius, _angle];
	private _b = _center getPos [_radius, _angle + 180];
	private _aAsl = [_a select 0, _a select 1, ([_a select 0, _a select 1] call _groundZ) + 1];
	private _bAsl = [_b select 0, _b select 1, ([_b select 0, _b select 1] call _groundZ) + 1];

	private _hits = lineIntersectsObjs [_aAsl, _bAsl, objNull, objNull, false];
	{
		private _hitObj = _x;
		if (!isNull _hitObj && {typeOf _hitObj isKindOf "Wall"}) then {
			// Widen the gap to the blocking segment's immediate neighbours too -
			// one segment alone is rarely wide enough to comfortably walk through.
			private _nearby = nearestObjects [getPosATL _hitObj, ["Wall"], 6];
			{
				if (!isNull _x && {typeOf _x isKindOf "Wall"}) then {
					deleteVehicle _x;
					_cleared = _cleared + 1;
				};
			} forEach (_nearby + [_hitObj]);
		};
	} forEach _hits;
};

diag_log format ["[Waldo][server] clearArenaPaths: probes=6 segments cleared=%1", _cleared];
