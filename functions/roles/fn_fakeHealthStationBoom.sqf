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
// Two stacked SatchelCharge_Remote_Ammo_Scripted - see fn_c4Charge.sqf,
// which shares this same blast and has the full reasoning ("a little more
// power than the satchel" without gambling on a fourth unverified ammo
// class after Bo_Mk82/Sh_82_HE both failed).
private _bomb1 = createVehicle ["SatchelCharge_Remote_Ammo_Scripted", _pos, [], 0, "NONE"];
private _bomb2 = createVehicle ["SatchelCharge_Remote_Ammo_Scripted", _pos, [], 0, "NONE"];
// Same attribution fix as fn_c4Charge.sqf's charge - without this, the trap's
// owner never gets credited (or karma-penalized, if it catches a teammate) for
// the kill, and the corpse carries no DNA at all.
if (!isNull _owner) then { _bomb1 setShotParents [_owner, _owner]; _bomb2 setShotParents [_owner, _owner]; };
// The scripted charge only detonates when damaged - this is what actually
// triggers the blast.
_bomb1 setDamage 1;
_bomb2 setDamage 1;
