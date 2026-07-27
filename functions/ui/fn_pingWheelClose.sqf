//////////////////////////////////////////////////////////////////
// Waldo_fnc_pingWheelClose
// CLIENT: called on T KeyUp. Hides the picker, tears down the mouse-wheel
// handler, and fires whichever option is currently highlighted via
// Waldo_fnc_traitorPing.
//////////////////////////////////////////////////////////////////

if !(missionNamespace getVariable ["Waldo_pingWheelOpen", false]) exitWith {};
Waldo_pingWheelOpen = false;

if (!isNil "Waldo_pingWheelEH") then {
	(findDisplay 46) displayRemoveEventHandler ["MouseZChanged", Waldo_pingWheelEH];
	Waldo_pingWheelEH = nil;
};

disableSerialization;
private _display = uiNamespace getVariable ["TTTHud", displayNull];
if !(isNull _display) then { (_display displayCtrl 3520) ctrlShow false; };

private _options = missionNamespace getVariable ["Waldo_pingWheelOptions", []];
private _idx = missionNamespace getVariable ["Waldo_pingWheelIndex", 0];
if (_idx >= 0 && {_idx < count _options}) then {
	private _kind = (_options select _idx) select 0;
	[_kind] call Waldo_fnc_traitorPing;
};
