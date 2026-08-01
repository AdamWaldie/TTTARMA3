//////////////////////////////////////////////////////////////////
// Waldo_fnc_showRoleCard
// CLIENT: round-start notification wrapper around Waldo_fnc_roleBriefingText.
// remoteExec'd once per player from Waldo_fnc_assignRoles, with data already
// redacted server-side for exactly this viewer - fires the instant
// TraitorList/DetectiveList/JesterList are broadcast, tight enough on timing
// that a fresh remoteExec sent directly to this one player is safer than
// trusting those public variables have already replicated here.
//
// Replaces the old "There is a Detective/Jester this round" broadcasts (sent
// to literally everyone, un-tailored) and the Traitor-only team card - one
// personalised card per player. The same content is also re-viewable any
// time from the scoreboard's "Your Briefing" panel (Waldo_fnc_scoreboard),
// which calls Waldo_fnc_roleBriefingText itself rather than this wrapper.
//
// params: [_role, _teammateNames, _detectiveName, _jesterExists, _jesterName]
//   (see Waldo_fnc_roleBriefingText for what each means)
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
params ["_role", "_teammateNames", "_detectiveName", "_jesterExists", "_jesterName"];

private _body = [_role, _teammateNames, _detectiveName, _jesterExists, _jesterName] call Waldo_fnc_roleBriefingText;

[
	"ROUND BRIEFING", _body,
	"INFO", 20, "TOP_RIGHT", "ROLECARD", toUpper _role
] call Waldo_fnc_ShowUiNotification;
