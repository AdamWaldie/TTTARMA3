//////////////////////////////////////////////////////////////////
// Waldo_fnc_flowerSpawn
// SERVER: creates one flower bouquet at the given position, travelling at
// the given velocity. Split out of Waldo_fnc_flowerPower's Fired handler so
// the actual createVehicle runs with server locality - a client-created
// object is local to that client only and never replicates to anyone else
// on a true dedicated server (same class of bug fn_healthStation.sqf and
// fn_fakeHealthStation.sqf already guard against; a listen-server host
// masks it because the host's own client happens to BE the server).
//
// params: [_pos, _velocity]
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};
params ["_pos", "_velocity"];

private _flower = createVehicle ["FlowerBouquet_02_F", _pos, [], 0, "NONE"];
_flower setVelocity _velocity;
