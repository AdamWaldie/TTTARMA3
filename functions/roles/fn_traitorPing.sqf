//////////////////////////////////////////////////////////////////
// Waldo_fnc_traitorPing
// CLIENT: traitors-only silent coordination. Bound to T. Pings the spot you are
// looking at to every Traitor (a 3D beacon + a map marker for ~15s, tagged with
// your name), so traitors can sync targets and moves without voice/text that
// innocents could overhear.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
if ((player getVariable ["role", ""]) != "Traitor") exitWith {};

// The world point under the screen centre (where you are aiming).
private _pos = screenToWorld [0.5, 0.5];
if (_pos isEqualTo [0,0,0]) exitWith {};

// TraitorList is broadcast, so relay straight to each traitor's machine.
{
	if (!isNull _x) then { [player, _pos] remoteExec ["Waldo_fnc_pingShow", _x]; };
} forEach (missionNamespace getVariable ["TraitorList", []]);
