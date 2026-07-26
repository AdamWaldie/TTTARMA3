//////////////////////////////////////////////////////////////////
// Waldo_fnc_scoreboard
// CLIENT: toggles an IN-ROUND scoreboard (bound to K). Lists every player with
// their alive/dead status, kills THIS round, and their role — but role is shown
// only where the viewer is allowed to know it (own role; any dead player; the
// public Detective; Traitors see fellow Traitors + the Jester; the Jester sees
// Traitors). Nothing is tracked between rounds.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
disableSerialization;

// Toggle closed if already open.
if !(isNull (uiNamespace getVariable ["WaldoScore", displayNull])) exitWith { closeDialog 1; };

private _myRole   = player getVariable ["role", "Innocent"];
private _traitors = missionNamespace getVariable ["TraitorList", []];

private _hexOf = {
	params ["_r"];
	switch (_r) do {
		case "Traitor":   { "#bf3636" };
		case "Detective": { "#02b3ff" };
		case "Jester":    { "#9a2ecc" };
		case "Innocent":  { "#26bf1e" };
		default           { "#9a9a9a" };
	};
};

private _rowFor = {
	params ["_p"];
	private _role  = _p getVariable ["role", "Innocent"];
	private _alive = alive _p;
	private _kills = _p getVariable ["Waldo_roundKills", 0];
	private _reveal = (_p == player)
		|| {!_alive}
		|| {_role == "Detective"}
		|| {_myRole == "Traitor" && {(_p in _traitors) || {_role == "Jester"}}}
		|| {_myRole == "Jester"  && {_p in _traitors}};
	private _roleTxt = if (_reveal) then { _role } else { "Unknown" };
	private _hex     = if (_reveal) then { [_role] call _hexOf } else { "#9a9a9a" };
	private _status  = ["<t color='#ff5a5a'>DEAD</t>", "<t color='#7ddb6f'>ALIVE</t>"] select _alive;
	format [
		"<t size='1.05'>%1</t>    %2    <t color='%3'>%4</t>    <t color='#ffd23f'>%5</t> kills<br/>",
		name _p, _status, _hex, _roleTxt, _kills
	]
};

// Living first, then the dead.
private _live = allPlayers select { alive _x };
private _dead = allPlayers select { !alive _x };
private _body = "";
{ _body = _body + ([_x] call _rowFor); } forEach (_live + _dead);
if (_body == "") then { _body = "<t color='#9a9a9a'>No players.</t>"; };

createDialog "WaldoScore";
waitUntil { !isNull (uiNamespace getVariable ["WaldoScore", displayNull]) };
private _display = uiNamespace getVariable "WaldoScore";

// Let K close it too (the main handler can't fire while a dialog is focused).
_display displayAddEventHandler ["KeyDown", { if ((_this select 1) == 37) then { closeDialog 1; true } else { false } }];

(_display displayCtrl 3301) ctrlSetText format ["Round Scoreboard    -    %1 alive / %2 total", count _live, count allPlayers];
(_display displayCtrl 3300) ctrlSetStructuredText parseText _body;
