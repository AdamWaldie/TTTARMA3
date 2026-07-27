//////////////////////////////////////////////////////////////////
// Waldo_fnc_traitorPing
// CLIENT: traitors-only silent coordination. Fired by Waldo_fnc_pingWheelClose
// once T is released with a kind highlighted (see Waldo_fnc_pingWheelOpen):
//   - "Target": tracks whoever you're aiming at live (must be a living player;
//     silently dropped if you released without one in your sights).
//   - "Location" / "Danger" / "Regroup Here" / "Enemy Spotted": a static point
//     where you're looking, differing only in colour/label (Waldo_fnc_pingShow).
// Relayed to every fellow Traitor's machine (TraitorList is broadcast), so
// traitors can sync targets and moves without voice/text innocents could
// overhear.
//
// params: [_kind]
//////////////////////////////////////////////////////////////////

params [["_kind", "Location"]];

if (!hasInterface) exitWith {};
if ((player getVariable ["role", ""]) != "Traitor") exitWith {};

private _isTarget = _kind == "Target";
private _ct = cursorTarget;
private _aimingPlayer = !isNull _ct && {_ct isKindOf "CAManBase"} && {alive _ct} && {(player distance _ct) < 300};

if (_isTarget && {!_aimingPlayer}) exitWith {};   // asked to track a person, but not aiming at one

private _where = if (_isTarget) then { _ct } else { screenToWorld [0.5, 0.5] };
if (!_isTarget && {_where isEqualTo [0,0,0]}) exitWith {};

{
	if (!isNull _x) then { [player, _kind, _where] remoteExec ["Waldo_fnc_pingShow", _x]; };
} forEach (missionNamespace getVariable ["TraitorList", []]);
