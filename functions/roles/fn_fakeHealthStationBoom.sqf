//////////////////////////////////////////////////////////////////
// Waldo_fnc_fakeHealthStationBoom
// SERVER: detonates a fake health station (Waldo_fnc_fakeHealthStation) -
// triggered when anyone but its owner uses its "Health Station" addAction.
//
// params: [_station]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_station"];
if (isNull _station) exitWith {};

private _pos = getPosATL _station;
private _owner = _station getVariable ["Waldo_fakeOwner", objNull];
deleteVehicle _station;
private _bomb = createVehicle ["Bo_Mk82", _pos, [], 0, "NONE"];
// Same attribution fix as fn_c4Charge.sqf's charge - without this, the trap's
// owner never gets credited (or karma-penalized, if it catches a teammate) for
// the kill, and the corpse carries no DNA at all.
if (!isNull _owner) then { _bomb setShotParents [_owner, _owner]; };
