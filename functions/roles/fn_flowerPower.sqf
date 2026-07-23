//////////////////////////////////////////////////////////////////
// Waldo_fnc_flowerPower
// CLIENT: novelty - a managed Fired handler that spawns a flower bouquet
// travelling with each bullet's velocity.
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_flowerEH", -1];
if (_old >= 0) then { player removeEventHandler ["Fired", _old]; };

private _eh = player addEventHandler ["Fired", {
	private _bullet = _this select 6;
	private _velocity = velocity _bullet;
	[_bullet, _velocity] spawn {
		params ["_bullet", "_velocity"];
		private _newPos = getPos _bullet;
		private _flower = createVehicle ["FlowerBouquet_02_F", _newPos, [], 0, "NONE"];
		_flower setVelocity _velocity;
	};
}];
player setVariable ["Waldo_flowerEH", _eh];
