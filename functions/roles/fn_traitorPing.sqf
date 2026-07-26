//////////////////////////////////////////////////////////////////
// Waldo_fnc_traitorPing
// CLIENT: traitors-only silent coordination. Bound to T. The ping TYPE is
// auto-detected from what you're aiming at (no extra keybind needed):
//   - aiming at a living player -> a TARGET ping (tracks that person live,
//     for calling out a kill target or a threat).
//   - aiming anywhere else -> a LOCATION ping (a static point, for marking a
//     spot to regroup or move to).
// Relayed to every fellow Traitor's machine (TraitorList is broadcast), so
// traitors can sync targets and moves without voice/text innocents could
// overhear.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
if ((player getVariable ["role", ""]) != "Traitor") exitWith {};

private _ct = cursorTarget;
private _isTarget = !isNull _ct && {_ct isKindOf "CAManBase"} && {alive _ct} && {(player distance _ct) < 300};

private _kind  = ["location", "target"] select _isTarget;
private _where = if (_isTarget) then { _ct } else { screenToWorld [0.5, 0.5] };

if (!_isTarget && {_where isEqualTo [0,0,0]}) exitWith {};

{
	if (!isNull _x) then { [player, _kind, _where] remoteExec ["Waldo_fnc_pingShow", _x]; };
} forEach (missionNamespace getVariable ["TraitorList", []]);
