//////////////////////////////////////////////////////////////////
// Waldo_fnc_mvpCelebrate
// CLIENT: plays the round-end MVP celebration (broadcast from
// Waldo_fnc_roundMVP): replays the intro music, pops a short fireworks-style
// display over the arena, and banners the round's top scorer - or just a plain
// "Round Complete" if nobody scored a kill this round.
//
// params: [_name, _role, _kills]  - _name == "" means no MVP this round.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
params [["_name", ""], ["_role", ""], ["_kills", 0]];

playMusic ["TTTIntroMusic", 20];

// Fireworks: a handful of coloured smoke shells launched up and out over the
// arena centre, popping in a loose sequence for a celebratory feel.
private _center = missionNamespace getVariable ["mapPos", getPosATL player];
[_center] spawn {
	params ["_center"];
	private _colors = ["SmokeShellGreen", "SmokeShellRed", "SmokeShellYellow", "SmokeShellBlue", "SmokeShellPurple", "SmokeShellOrange"];
	for "_i" from 1 to 8 do {
		private _p = _center vectorAdd [-15 + random 30, -15 + random 30, 40 + random 20];
		private _s = (selectRandom _colors) createVehicle _p;
		_s setVelocity [-2 + random 4, -2 + random 4, -6 - random 4];
		sleep 0.35;
	};
};

private _txt = if (_name != "") then {
	format [
		"<t align='center' size='1.6' color='#ffd23f' shadow='1'>ROUND MVP</t><br/><t align='center' size='1.3'>%1</t><br/><t align='center' size='0.9' color='#9a9a9a'>%2 - %3 kill%4</t>",
		_name, _role, _kills, (["", "s"] select (_kills != 1))
	]
} else {
	"<t align='center' size='1.4' color='#ffd23f' shadow='1'>Round Complete</t>"
};

hintSilent parseText _txt;
sleep 6;
hintSilent "";
