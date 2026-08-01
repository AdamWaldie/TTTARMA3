//////////////////////////////////////////////////////////////////
// Waldo_fnc_roleBriefingText
// CLIENT: builds the "who you are and who you're actually supposed to know
// about" briefing body, as ready-to-render structured text. Shared by the
// round-start notification (Waldo_fnc_showRoleCard) and the in-round
// scoreboard's "Your Briefing" panel (Waldo_fnc_scoreboard), so the
// wording lives in exactly one place instead of drifting between the two.
//
// Colour spans use Waldo_roleColorHex, which reads the VIEWING player's own
// accessibility setting (profileNamespace) - this is why it's a client
// function taking already-decided data as params, not something that could
// be pre-rendered once on the server (a colourblind palette preference is
// per-player, and the server has no meaningful one of its own).
//
// This function does NOT re-derive or double-check "is this viewer allowed
// to know this" - every name passed in is trusted as-is. That judgement call
// already happened at the call site: Waldo_fnc_showRoleCard receives
// already-redacted params computed server-side in Waldo_fnc_assignRoles
// (never leaked to a client not entitled to it), and Waldo_fnc_scoreboard
// applies the exact same redaction rule its own player-list rendering
// already uses before calling this. Pass "" / false for anything unknown or
// not applicable - this renders cleanly around a gap rather than guessing.
//
// params: [_role, _teammateNames, _detectiveName, _jesterExists, _jesterName]
//   _role           - the viewer's own role
//   _teammateNames  - fellow Traitor names; expected [] unless _role == "Traitor"
//   _detectiveName  - "" if no Detective this round, their name otherwise -
//                     public to every role (Waldo_fnc_scoreboard's own
//                     _reveal rule: (_role == "Detective") always reveals)
//   _jesterExists   - true/false, accurate regardless of the viewer's role
//   _jesterName     - "" unless the viewer is a Traitor - only Traitors are
//                     ever told who the Jester is (Waldo_fnc_drawRoleIcons)
// returns: STRING, ready for ctrlSetStructuredText/parseText
//////////////////////////////////////////////////////////////////

params ["_role", ["_teammateNames", []], ["_detectiveName", ""], ["_jesterExists", false], ["_jesterName", ""]];

private _tag = { params ["_r", "_txt"]; format ["<t color='%1'>%2</t>", [_r] call Waldo_roleColorHex, _txt] };

private _headline = "";
private _intent = "";
switch (_role) do {
	case "Traitor": {
		_headline = "TRAITOR";
		_intent = "Kill everyone who isn't one of you, before they work out who you are.";
	};
	case "Detective": {
		_headline = "DETECTIVE";
		_intent = "Investigate the dead, find the Traitors, and survive long enough to do it.";
	};
	case "Jester": {
		_headline = "JESTER";
		_intent = "You can't fight back. Get an Innocent or the Detective to kill you and YOU win instead.";
	};
	default {
		_headline = "INNOCENT";
		_intent = "Survive, and help work out who the Traitors are before they work out you.";
	};
};

private _lines = [format ["You are the %1. %2", [_role, _headline] call _tag, _intent]];

if (_role == "Traitor") then {
	private _matesTxt = if (count _teammateNames > 0) then {
		(_teammateNames apply { ["Traitor", _x] call _tag }) joinString ", "
	} else { "no one - you're on your own this round" };
	_lines pushBack format ["Fellow Traitors: %1", _matesTxt];
	if (_jesterExists && {_jesterName != ""}) then {
		_lines pushBack format [
			"The Jester is %1 - killing them wins your team NOTHING and costs you credits. Leave them be.",
			["Jester", _jesterName] call _tag
		];
	};
} else {
	if (_jesterExists) then {
		_lines pushBack format [
			"There is a %1 this round. Don't get tricked into killing them - that's exactly what they want.",
			["Jester", "Jester"] call _tag
		];
	};
};

if (_detectiveName != "" && {_role != "Detective"}) then {
	_lines pushBack format [
		"The Detective is %1 - they can test/scan for Traitors. Worth staying on their good side.",
		["Detective", _detectiveName] call _tag
	];
};

private _body = _lines select 0;
for "_i" from 1 to (count _lines - 1) do { _body = _body + "<br/><br/>" + (_lines select _i); };
_body
