//////////////////////////////////////////////////////////////////
// Waldo_fnc_detectiveRadar
// CLIENT: like the traitor radar but shows all units AND corpses as neutral
// green pulses (position only, not role), recharging every 45s. Single
// managed handler + CBA per-frame recharge.
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_radarEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

player setVariable ["radar", 1];

private _eh = addMissionEventHandler ["Draw3D", {
	private _radar = player getVariable ["radar", 0];
	{
		private _distance = player distance _x;
		private _color = [0.12549, 0.72941, 0.09412, _radar];
		drawIcon3D ["", _color, getPosATL _x, 1, 0, 0, "O", 2,
			0.10 - (_distance / 2500), "PuristaMedium", "center"];
	} forEach (allUnits + allDeadMen);
	player setVariable ["radar", (_radar - 0.002)];
}];
player setVariable ["Waldo_radarEH", _eh];

[{
	params ["_args", "_handle"];
	if (!alive player) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
	player setVariable ["radar", 1];
}, 45] call CBA_fnc_addPerFrameHandler;
