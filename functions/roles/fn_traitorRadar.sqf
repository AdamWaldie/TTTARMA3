//////////////////////////////////////////////////////////////////
// Waldo_fnc_traitorRadar
// CLIENT: reveals every unit's position as a fading role-coloured pulse
// that recharges every 30s. Uses ONE managed Draw3D handler (replaces any
// previous one) plus ONE managed recharge loop - both replace rather than
// stack if called again (e.g. the shop item is bought more than once, or
// fired again from the dev menu).
//
// Recharge prefers CBA_fnc_addPerFrameHandler when CBA is loaded (cheaper,
// frame-driven), falling back to a plain spawn/sleep loop otherwise - CBA is
// no longer treated as a hard requirement. The vanilla fallback uses a
// token (same idiom as Waldo_hintFadeToken/Waldo_announceToken elsewhere)
// instead of a removable handle, since a spawned loop has no handle to
// remove the way CBA's PFH does.
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
player setVariable ["Waldo_radarNextPing", time + 30];

// "Doesn't ping with spawned dummies" reported - static review found no
// obvious reason (debug dummies/sims are real createUnit AI with a real
// role variable set, and allUnits doesn't filter by AI vs player or by
// side). One-shot diagnostic instead of guessing: logs exactly who
// allUnits sees at the moment the radar fires, so the next .rpt confirms
// whether a dummy is even in that list at all.
diag_log format ["[Waldo][client] traitorRadar fired: allUnits=%1", allUnits apply { [_x, name _x, _x getVariable ["role", "Innocent"], isPlayer _x] }];

// A real ring icon instead of a drawn "O" character - looked up from the
// engine's own standard NATO "mil_dot" map marker rather than a hardcoded
// texture path (avoids guessing at exact case/folder names, which differ
// between Windows and case-sensitive Linux dedicated servers): if it's
// ever missing for any reason, getText just returns "" and drawIcon3D
// silently draws nothing, rather than throwing. Was "hd_dot" (the
// hand-drawn doodle marker) - confirmed via .rpt spam ("Obsolete, sizeH
// and sizeW calculation missing", once per frame) that it's missing size
// metadata drawIcon3D needs for a real icon render. The "mil_" family is
// the actual scalable tactical marker set (built to be resized for
// unit/group size indicators), which is exactly this use case.
missionNamespace setVariable ["Waldo_radarPingIcon", getText (configFile >> "CfgMarkers" >> "mil_dot" >> "icon")];

private _eh = addMissionEventHandler ["Draw3D", {
	private _radar = player getVariable ["radar", 0];
	private _icon = missionNamespace getVariable ["Waldo_radarPingIcon", ""];
	{
		private _role = _x getVariable ["role", "Innocent"];
		private _base = [_role] call Waldo_roleColor;
		private _color = [_base select 0, _base select 1, _base select 2, _radar];
		private _distance = player distance _x;
		// drawIcon3D's ICON width/height is a completely different scale to
		// its TEXT size parameter - BI's own docs give 1-24 as the typical
		// range for icon width/height, not the 0.03-0.16 range every text
		// label in this HUD uses. The old text-glyph size (~0.10) carried
		// straight over here was roughly 10-100x too small for an ICON,
		// which is almost certainly why the ping wasn't visibly rendering at
		// all rather than just being small. Rescaled onto the icon-appropriate
		// range: ~1.4 close up, shrinking with distance, floored so it never
		// vanishes to nothing at range. Still grows slightly as it fades
		// (radar 1 -> 0) for the expanding-ping feel.
		private _base_size = (1.4 - (_distance / 60)) max 0.35;
		private _size = _base_size * (1 + ((1 - _radar) * 0.5));
		drawIcon3D [_icon, _color, getPosATL _x, _size, _size, 0, "", 0, 1, "PuristaMedium", "center"];
	} forEach allUnits;
	// diag_deltaTime (real seconds since the last frame), not a flat
	// per-frame decrement - the old -0.002/frame decay was frame-RATE
	// dependent, not frame-TIME dependent, so the pulse's actually-visible
	// window shrank as FPS rose (twice the frame rate halved how long it
	// stayed up). 0.1/s is a flat ~10s fade regardless of FPS.
	player setVariable ["radar", (_radar - (0.1 * diag_deltaTime))];
}];
player setVariable ["Waldo_radarEH", _eh];

// Recharge the pulse periodically until the player dies.
if (_useCBA) then {
	private _pfh = [{
		params ["_args", "_handle"];
		if (!alive player) exitWith { [_handle] call CBA_fnc_removePerFrameHandler; };
		player setVariable ["radar", 1];
		player setVariable ["Waldo_radarNextPing", time + 30];
	}, 30] call CBA_fnc_addPerFrameHandler;
	player setVariable ["Waldo_radarPFH", _pfh];
} else {
	private _token = player getVariable ["Waldo_radarToken", 0];
	[_token] spawn {
		params ["_token"];
		while { alive player && {(player getVariable ["Waldo_radarToken", 0]) == _token} } do {
			sleep 30;
			if ((player getVariable ["Waldo_radarToken", 0]) == _token) then {
				player setVariable ["radar", 1];
				player setVariable ["Waldo_radarNextPing", time + 30];
			};
		};
	};
};

[30] call Waldo_fnc_radarCountdown;
