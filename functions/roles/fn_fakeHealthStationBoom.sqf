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
deleteVehicle _station;
createVehicle ["Bo_Mk82", _pos, [], 0, "NONE"];
