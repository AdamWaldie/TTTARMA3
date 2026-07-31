//////////////////////////////////////////////////////////////////
// Waldo_fnc_fakeHealthStationBoom
// SERVER: detonates a fake health station (Waldo_fnc_fakeHealthStation) -
// triggered whenever anyone (including its own owner) uses its "Health
// Station" addAction.
//
// params: [_station]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_station"];
if (isNull _station) exitWith {};

private _pos = getPosATL _station;
private _owner = _station getVariable ["Waldo_fakeOwner", objNull];
deleteVehicle _station;
// Back to Bo_Mk82 - see fn_c4Charge.sqf, which shares this same blast and
// has the full reasoning (explicitly confirmed wanting the original full
// 500lb blast back, not a medium option).
private _bomb = createVehicle ["Bo_Mk82", _pos, [], 0, "NONE"];
// Same attribution fix as fn_c4Charge.sqf's charge - without this, the trap's
// owner never gets credited (or karma-penalized, if it catches a teammate) for
// the kill, and the corpse carries no DNA at all.
if (!isNull _owner) then { _bomb setShotParents [_owner, _owner]; };
// The scripted charge only detonates when damaged - this is what actually
// triggers the blast.
_bomb setDamage 1;
