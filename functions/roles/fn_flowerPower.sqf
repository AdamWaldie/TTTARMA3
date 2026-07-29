//////////////////////////////////////////////////////////////////
// Waldo_fnc_flowerPower
// CLIENT: novelty - a managed Fired handler that spawns a flower bouquet
// travelling with each bullet's velocity.
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_flowerEH", -1];
if (_old >= 0) then { player removeEventHandler ["Fired", _old]; };

// The actual createVehicle happens server-side (Waldo_fnc_flowerSpawn) - a
// client-created object is local to that client only and never replicates
// to anyone else on a real dedicated server, so this used to be invisible
// to everyone but the shooter there (a listen-server host doesn't show the
// bug: the host's own client IS the server, so a client-local createVehicle
// there happens to already have server locality).
private _eh = player addEventHandler ["Fired", {
	private _bullet = _this select 6;
	private _velocity = velocity _bullet;
	[_bullet, _velocity] spawn {
		params ["_bullet", "_velocity"];
		private _newPos = getPos _bullet;
		[_newPos, _velocity] remoteExec ["Waldo_fnc_flowerSpawn", 2];
	};
}];
player setVariable ["Waldo_flowerEH", _eh];
