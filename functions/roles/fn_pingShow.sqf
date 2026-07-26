//////////////////////////////////////////////////////////////////
// Waldo_fnc_pingShow
// CLIENT: displays a traitor coordination ping (from Waldo_fnc_traitorPing) for
// ~15 seconds - a red 3D beacon labelled with the sender's name, plus a local
// map marker. Only ever remote-executed onto Traitor machines.
//
// params: [_from, _pos]
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
params ["_from", "_pos"];

[_from, _pos] spawn {
	params ["_from", "_pos"];
	private _label = format ["%1", name _from];
	private _p = +_pos;
	_p set [2, (_p select 2) + 1];

	private _eh = addMissionEventHandler ["Draw3D", {
		_thisArgs params ["_dp", "_dl"];
		drawIcon3D [
			"\A3\ui_f\data\map\markers\military\dot_ca.paa",
			[0.85, 0.2, 0.2, 1], _dp, 0.9, 0.9, 0, _dl, 1, 0.04, "PuristaBold"
		];
	}, [_p, _label]];

	private _mk = format ["ttt_ping_%1_%2", _label, round (diag_tickTime * 100)];
	createMarkerLocal [_mk, _pos];
	_mk setMarkerTypeLocal "mil_dot";
	_mk setMarkerColorLocal "ColorRed";
	_mk setMarkerTextLocal ("Ping: " + _label);

	sleep 15;

	removeMissionEventHandler ["Draw3D", _eh];
	deleteMarkerLocal _mk;
};
