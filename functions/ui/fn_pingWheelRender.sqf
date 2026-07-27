//////////////////////////////////////////////////////////////////
// Waldo_fnc_pingWheelRender
// CLIENT: redraws the 5 ping-picker rows, highlighting Waldo_pingWheelIndex.
// Called on open and every mouse-wheel step (Waldo_fnc_pingWheelOpen).
//////////////////////////////////////////////////////////////////

disableSerialization;
private _display = uiNamespace getVariable ["TTTPingWheel", displayNull];
if (isNull _display) exitWith {};

private _options = missionNamespace getVariable ["Waldo_pingWheelOptions", []];
private _sel = missionNamespace getVariable ["Waldo_pingWheelIndex", 0];
private _color = ["Traitor"] call Waldo_roleColor;

{
	_x params ["_label", "_desc"];
	private _ctrl = _display displayCtrl (3510 + _forEachIndex);
	private _isSel = _forEachIndex == _sel;
	_ctrl ctrlSetText (if (_isSel) then { format [">  %1  -  %2", _label, _desc] } else { format ["   %1", _label] });
	_ctrl ctrlSetTextColor (if (_isSel) then { _color } else { [0.75, 0.73, 0.68, 1] });
	_ctrl ctrlSetBackgroundColor (if (_isSel) then { [_color select 0, _color select 1, _color select 2, 0.18] } else { [0, 0, 0, 0] });
} forEach _options;
