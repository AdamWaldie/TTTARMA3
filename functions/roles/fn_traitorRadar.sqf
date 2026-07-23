//////////////////////////////////////////////////////////////////
// Waldo_fnc_traitorRadar
// CLIENT: reveals every unit's position as a fading role-coloured pulse
// that recharges every 30s. Uses ONE managed Draw3D handler (replaces any
// previous one) plus a CBA per-frame handler for the recharge, instead of
// the old stacking handler + while{true} loop.
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_radarEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

player setVariable ["radar", 1];

private _eh = addMissionEventHandler ["Draw3D", {
	private _radar = player getVariable ["radar", 0];
	{
		private _role = _x getVariable ["role", "Innocent"];
		private _base = [_role] call Waldo_roleColor;
		private _color = [_base select 0, _base select 1, _base select 2, _radar];
		private _distance = player distance _x;
		drawIcon3D ["", _color, getPosATL _x, 1, 0, 0, "O", 2,
			0.10 - (_distance / 2500), "PuristaMedium", "center"];
	} forEach allUnits;
	player setVariable ["radar", (_radar - 0.002)];
}];
player setVariable ["Waldo_radarEH", _eh];

// Recharge the pulse periodically until the player dies.
[{
	params ["_args", "_handle"];
	if (!alive player) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
	player setVariable ["radar", 1];
}, 30] call CBA_fnc_addPerFrameHandler;
