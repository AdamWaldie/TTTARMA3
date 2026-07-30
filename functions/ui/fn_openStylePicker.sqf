//////////////////////////////////////////////////////////////////
// Waldo_fnc_openStylePicker
// CLIENT: opens the role crest style picker (H key). Shows one named card
// per style (0 Original .. 8 Stamped Tag), the current one highlighted with
// a role-tinted border. Clicking a card sets Waldo_roleCrestStylePref in
// profileNamespace, saves it, refreshes the live HUD (Waldo_fnc_initHud),
// and closes the dialog - this replaces the old H-key cycle-through-styles
// behaviour entirely.
//////////////////////////////////////////////////////////////////

disableSerialization;

private _role = player getVariable ["role", "Innocent"];
private _color = [_role] call Waldo_roleColor;
private _current = profileNamespace getVariable ["Waldo_roleCrestStylePref", 0];

createDialog "WaldoStylePicker";
waitUntil { !isNull (uiNamespace getVariable ["WaldoStylePicker", displayNull]) };
private _display = uiNamespace getVariable "WaldoStylePicker";

// Real vertical centring, not ST_VCENTER (see the comment above spTitle in
// ui/TTTHud.hpp) - same ctrlTextHeight technique as the badge letter.
private _title = _display displayCtrl 1590;
private _titleH = ctrlTextHeight _title;
private _titlePos = ctrlPosition _title;
_title ctrlSetPosition [_titlePos select 0, (_titlePos select 1) + (((_titlePos select 3) - _titleH) / 2), _titlePos select 2, _titleH];
_title ctrlCommit 0;

private _borderIdcs = [1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608];
private _btnIdcs    = [1640, 1641, 1642, 1643, 1644, 1645, 1646, 1647, 1648];

{
	private _i = _forEachIndex;
	(_display displayCtrl _x) ctrlSetBackgroundColor (
		if (_i == _current) then { [_color select 0, _color select 1, _color select 2, 1] } else { [0.105, 0.11, 0.095, 0.96] }
	);
} forEach _borderIdcs;

{
	private _i = _forEachIndex;
	(_display displayCtrl _x) ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"];
		private _style = _ctrl getVariable "styleIndex";
		profileNamespace setVariable ["Waldo_roleCrestStylePref", _style];
		saveProfileNamespace;
		[] call Waldo_fnc_initHud;
		closeDialog 1;
	}];
	(_display displayCtrl _x) setVariable ["styleIndex", _i];
} forEach _btnIdcs;

// Colourblind-safe palette toggle. ctrlAddEventHandler code runs in its own
// scope with no access to this script's private variables (a real SQF
// footgun, not a style choice), so it's fully self-contained - re-reads
// role/current style fresh from player/profileNamespace and redoes the same
// border-highlight tint pass the initial run above did, rather than trying
// to share state across that boundary.
private _accessBtn = _display displayCtrl 1592;
private _setAccessLabel = { params ["_btn", "_on"]; _btn ctrlSetText (["COLOURBLIND MODE: OFF", "COLOURBLIND MODE: ON"] select _on) };
[_accessBtn, profileNamespace getVariable ["Waldo_accessibilityMode", false]] call _setAccessLabel;
_accessBtn ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"];
	private _on = !(profileNamespace getVariable ["Waldo_accessibilityMode", false]);
	profileNamespace setVariable ["Waldo_accessibilityMode", _on];
	saveProfileNamespace;
	_ctrl ctrlSetText (["COLOURBLIND MODE: OFF", "COLOURBLIND MODE: ON"] select _on);

	[] call Waldo_fnc_initHud;   // live badge picks up the new palette immediately

	private _display2 = ctrlParent _ctrl;
	private _role2 = player getVariable ["role", "Innocent"];
	private _color2 = [_role2] call Waldo_roleColor;
	private _current2 = profileNamespace getVariable ["Waldo_roleCrestStylePref", 0];
	{
		private _i2 = _forEachIndex;
		(_display2 displayCtrl _x) ctrlSetBackgroundColor (
			if (_i2 == _current2) then { [_color2 select 0, _color2 select 1, _color2 select 2, 1] } else { [0.105, 0.11, 0.095, 0.96] }
		);
	} forEach [1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608];
}];
