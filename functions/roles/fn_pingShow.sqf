//////////////////////////////////////////////////////////////////
// Waldo_fnc_pingShow
// CLIENT: displays a traitor coordination ping (from Waldo_fnc_traitorPing) for
// ~15 seconds. Only ever remote-executed onto Traitor machines.
//
// params: [_from, _kind, _where]
//   _kind  : "location" (a static point, red dot) | "target" (tracks a living
//            unit live, orange marker, labelled TARGET).
//   _where : a position (location) or the targeted unit (target).
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
params ["_from", "_kind", "_where"];

private _isTarget = _kind == "target";

[_from, _isTarget, _where] spawn {
	params ["_from", "_isTarget", "_where"];
	private _sender = name _from;
	private _color  = if (_isTarget) then { [1, 0.55, 0.05, 1] } else { [0.85, 0.2, 0.2, 1] };
	private _icon   = if (_isTarget) then { "\A3\ui_f\data\map\markers\military\destroy_ca.paa" } else { "\A3\ui_f\data\map\markers\military\dot_ca.paa" };

	private _mk = format ["ttt_ping_%1_%2", _sender, round (diag_tickTime * 100)];

	private _eh = addMissionEventHandler ["Draw3D", {
		_thisArgs params ["_isTarget", "_where", "_color", "_icon", "_sender", "_mk"];
		private _valid = if (_isTarget) then { !isNull _where && {alive _where} } else { true };
		if (_valid) then {
			private _p = if (_isTarget) then { (getPosATL _where) vectorAdd [0,0,2] } else { _where };
			private _tag = if (_isTarget) then { format ["TARGET (%1)", _sender] } else { _sender };
			drawIcon3D [_icon, _color, _p, 1, 1, 0, _tag, 1, 0.04, "PuristaBold"];
			// A target ping is meant to track a moving person, not just the spot
			// they were standing in when pinged - keep the map marker glued to
			// them every frame, same as the 3D world icon already does.
			if (_isTarget) then { _mk setMarkerPosLocal (getPosATL _where); };
		};
	}, [_isTarget, _where, _color, _icon, _sender, _mk]];

	private _mkPos = if (_isTarget) then { getPosATL _where } else { _where };
	createMarkerLocal [_mk, _mkPos];
	_mk setMarkerTypeLocal (["mil_dot", "mil_destroy"] select _isTarget);
	_mk setMarkerColorLocal (["ColorRed", "ColorOrange"] select _isTarget);
	_mk setMarkerTextLocal ([format ["Ping: %1", _sender], format ["Target ping: %1", _sender]] select _isTarget);

	sleep 15;

	removeMissionEventHandler ["Draw3D", _eh];
	deleteMarkerLocal _mk;
};
