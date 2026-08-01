//////////////////////////////////////////////////////////////////
// Waldo_fnc_detectiveRadar
// CLIENT: like the traitor radar but shows all units AND corpses as neutral
// green pulses (position only, not role), recharging every 45s. Both the
// Draw3D handler and its recharge loop replace rather than stack if called
// again (e.g. the shop item is bought more than once).
//
// Recharge prefers CBA_fnc_addPerFrameHandler when CBA is loaded, falling
// back to a plain spawn/sleep loop otherwise - CBA is no longer treated as
// a hard requirement. See Waldo_fnc_traitorRadar for the same pattern.
//////////////////////////////////////////////////////////////////

private _old = player getVariable ["Waldo_radarEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["Draw3D", _old]; };

private _useCBA = !(isNil "CBA_fnc_addPerFrameHandler");

if (_useCBA) then {
	private _oldPfh = player getVariable ["Waldo_radarPFH", -1];
	if (_oldPfh >= 0) then { [_oldPfh] call CBA_fnc_removePerFrameHandler; };
} else {
	player setVariable ["Waldo_radarToken", (player getVariable ["Waldo_radarToken", 0]) + 1];
};

player setVariable ["radar", 1];
player setVariable ["Waldo_radarNextPing", time + 45];

// Same ping-icon redesign as Waldo_fnc_traitorRadar - see there for why
// it's looked up from CfgMarkers rather than a hardcoded texture path.
missionNamespace setVariable ["Waldo_radarPingIcon", getText (configFile >> "CfgMarkers" >> "mil_dot" >> "icon")];

private _eh = addMissionEventHandler ["Draw3D", {
	private _radar = player getVariable ["radar", 0];
	private _icon = missionNamespace getVariable ["Waldo_radarPingIcon", ""];
	{
		private _distance = player distance _x;
		// Was a hardcoded RGB literal - correct colour, but it bypassed
		// Waldo_roleColor entirely, so this pip never respected the
		// colourblind-safe Okabe-Ito palette (Waldo_accessibilityMode) the way
		// every OTHER role/position indicator in this HUD does. Routed through
		// Waldo_roleColor now, always with "Innocent" - the Detective radar is
		// position-only by design (see the file header), so every unit
		// renders in the same neutral colour regardless of actual role; only
		// the exact shade now follows the player's own accessibility setting.
		private _base = ["Innocent"] call Waldo_roleColor;
		private _color = [_base select 0, _base select 1, _base select 2, _radar];
		// See Waldo_fnc_traitorRadar - drawIcon3D's icon width/height needs
		// the icon-appropriate 1-24 range, not the text-size range the old
		// glyph's number was carried over at (almost certainly why the ping
		// wasn't visibly rendering at all). Real ring icon instead of a
		// character, mild expand-as-it-fades ping feel.
		private _base_size = (1.9 - (_distance / 80)) max 0.55;
		private _size = _base_size * (1 + ((1 - _radar) * 0.5));
		drawIcon3D [_icon, _color, getPosATL _x, _size, _size, 0, "", 0, 1, "PuristaMedium", "center"];
	} forEach (allUnits + allDeadMen);
	// See Waldo_fnc_traitorRadar - diag_deltaTime keeps the fade frame-rate
	// independent instead of shrinking as FPS rises.
	player setVariable ["radar", (_radar - (0.1 * diag_deltaTime))];
}];
player setVariable ["Waldo_radarEH", _eh];

if (_useCBA) then {
	private _pfh = [{
		params ["_args", "_handle"];
		if (!alive player) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
		player setVariable ["radar", 1];
		player setVariable ["Waldo_radarNextPing", time + 45];
	}, 45] call CBA_fnc_addPerFrameHandler;
	player setVariable ["Waldo_radarPFH", _pfh];
} else {
	private _token = player getVariable ["Waldo_radarToken", 0];
	[_token] spawn {
		params ["_token"];
		while { alive player && {(player getVariable ["Waldo_radarToken", 0]) == _token} } do {
			sleep 45;
			if ((player getVariable ["Waldo_radarToken", 0]) == _token) then {
				player setVariable ["radar", 1];
				player setVariable ["Waldo_radarNextPing", time + 45];
			};
		};
	};
};

[45] call Waldo_fnc_radarCountdown;
