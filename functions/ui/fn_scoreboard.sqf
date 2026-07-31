//////////////////////////////////////////////////////////////////
// Waldo_fnc_scoreboard
// CLIENT: toggles an IN-ROUND scoreboard (bound to K). Lists every player with
// their alive/dead status, whether their body has been FOUND, kills THIS round,
// and their role — but role is shown only where the viewer is allowed to know
// it: own role; any player once a Detective has identified their body
// (Waldo_roleRevealed - publicly "confirmed"); the public Detective; Traitors
// see fellow Traitors + the Jester (never the reverse - the Jester does not
// see Traitors here, matching Waldo_fnc_drawRoleIcons); and a dead viewer
// (out of the round) sees everything. Nothing is tracked between rounds.
//
// Being dead alone no longer reveals a role - identification does (see
// Waldo_fnc_identifyBody), matching the Detective-only role-reveal design.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
disableSerialization;

// Toggle closed if already open.
if !(isNull (uiNamespace getVariable ["WaldoScore", displayNull])) exitWith { closeDialog 1; };

private _myRole    = player getVariable ["role", "Innocent"];
// Dead players only see everything when the lobby's "Spectators See All
// Roles" param is on (off by default) - same gate as Waldo_fnc_drawRoleIcons,
// so the on-demand scoreboard and the always-on 3D tags never disagree.
// With it off, _reveal below still falls through on its own per-role terms
// (own role, Detective, Traitor-sees-Traitor/Jester), which is what keeps a
// dead Traitor seeing their team here too.
private _viewerOut = !alive player && {missionNamespace getVariable ["Waldo_spectatorsSeeAllRoles", false]};
private _traitors  = missionNamespace getVariable ["TraitorList", []];

private _hexOf = {
	params ["_r"];
	switch (_r) do {
		case "Traitor":   { "#bf3636" };
		case "Detective": { "#02b3ff" };
		case "Jester":    { "#9a2ecc" };
		case "Innocent":  { "#26bf1e" };
		default           { "#9EA290" };
	};
};

private _rowFor = {
	params ["_p"];
	private _role     = _p getVariable ["role", "Innocent"];
	private _alive    = alive _p;
	private _kills    = _p getVariable ["Waldo_roundKills", 0];
	private _found    = _p getVariable ["Waldo_identified", false];
	private _revealed = _p getVariable ["Waldo_roleRevealed", false];   // Detective-confirmed -> public knowledge

	private _reveal = (_p == player)
		|| _viewerOut
		|| _revealed
		|| (_role == "Detective")
		|| {_myRole == "Traitor" && {(_p in _traitors) || {_role == "Jester"}}};

	private _roleTxt = if (_reveal) then { toUpper (_role + (["", " (confirmed)"] select _revealed)) } else { "UNKNOWN" };
	private _hex     = if (_reveal) then { [_role] call _hexOf } else { "#9EA290" };
	private _status  = if (_alive) then {
		"<t color='#6FCB74'>ALIVE</t>"
	} else {
		if (_found) then { "<t color='#F2BE55'>FOUND</t>" } else { "<t color='#9EA290'>MISSING</t>" };
	};

	format [
		"<t size='1.05' color='#F2EFE3'>%1</t>    %2    <t color='%3'>%4</t>    <t color='#F2BE55'>%5</t> kills<br/>",
		name _p, _status, _hex, _roleTxt, _kills
	]
};

// Living first, then the dead.
private _live = allPlayers select { alive _x };
private _dead = allPlayers select { !alive _x };
private _body = "";
{ _body = _body + ([_x] call _rowFor); } forEach (_live + _dead);
if (_body == "") then { _body = "<t color='#9EA290'>No players.</t>"; };

createDialog "WaldoScore";
waitUntil { !isNull (uiNamespace getVariable ["WaldoScore", displayNull]) };
private _display = uiNamespace getVariable "WaldoScore";

// Let K close it too (the main handler can't fire while a dialog is focused).
_display displayAddEventHandler ["KeyDown", { if ((_this select 1) == 37) then { closeDialog 1; true } else { false } }];

// "Confirmed" here means called-in (Waldo_identified), matching the wiki's own
// wording - identifying a body "always confirms the death to the whole
// server" regardless of who calls it in. Waldo_roleRevealed is a stricter,
// Detective-only flag; keying the header count on that instead meant a
// regular player's call-in updated the per-row FOUND status but never moved
// this count, reading as "the scoreboard does nothing for it."
private _confirmedDead = { !alive _x && {_x getVariable ["Waldo_identified", false]} } count allPlayers;
(_display displayCtrl 3301) ctrlSetText format [
	"ROUND SCOREBOARD    -    %1 ALIVE / %2 TOTAL    -    %3 CONFIRMED DEAD",
	count _live, count allPlayers, _confirmedDead
];
(_display displayCtrl 3300) ctrlSetStructuredText parseText _body;

// Keybind reference panel (attached to the right edge, idc 3320) - same
// per-role list the top bar shows (Waldo_keyHintsFor), just stacked vertically
// here since this panel is tall and narrow rather than wide and short.
private _kbList = [_myRole] call Waldo_keyHintsFor;
private _kbBody = "";
// Colon separator, not bracket-wrapped: the dev keys ARE literally "[" and
// "]", and wrapping them ("[%1]") produces the same "[[]"/"[]]" collision
// fixed in the top bar's own keybind row (fn_initHud.sqf) - a colon has no
// such collision with any key label.
{ _x params ["_key", "_label"]; _kbBody = _kbBody + format ["<t color='#F2BE55'>%1:</t> %2<br/>", _key, _label]; } forEach _kbList;
(_display displayCtrl 3320) ctrlSetStructuredText parseText _kbBody;
