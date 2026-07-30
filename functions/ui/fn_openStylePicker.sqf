//////////////////////////////////////////////////////////////////
// Waldo_fnc_openStylePicker
// CLIENT: opens the role crest style picker (H key). Shows one preview card
// per style (0 Original .. 8 Stamped Tag), each tinted to the player's own
// role colour and its letter, with the currently-selected style highlighted.
// Clicking a card sets Waldo_roleCrestStylePref in profileNamespace, saves
// it, refreshes the live HUD (Waldo_fnc_initHud), and closes the dialog -
// this replaces the old H-key cycle-through-styles behaviour entirely.
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

private _borderIdcs  = [1600, 1601, 1602, 1603, 1604, 1605, 1606, 1607, 1608];
private _previewIdcs = [1620, 1621, 1622, 1623, 1624, 1625, 1626, 1627, 1628];
private _btnIdcs     = [1640, 1641, 1642, 1643, 1644, 1645, 1646, 1647, 1648];

{
	private _i = _forEachIndex;
	// Every preview is a flat RscText swatch now, not RscPicture - the
	// RscPicture version never rendered (see the "color[] vs color ="
	// syntax bug fixed on the Rank Disc), and even fixed, a 52px texture
	// read as nothing useful. Styles 0-7 are a small dark-casing/gold-accent
	// concentric pair (echoing the real Rank Disc) with a small accent mark
	// unique to that style; style 8 is its own flat square. All just need
	// colorBackground.
	(_display displayCtrl (_previewIdcs select _i)) ctrlSetBackgroundColor _color;

	(_display displayCtrl (_borderIdcs select _i)) ctrlSetBackgroundColor (
		if (_i == _current) then { [_color select 0, _color select 1, _color select 2, 1] } else { [0.105, 0.11, 0.095, 0.96] }
	);
} forEach _previewIdcs;

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
// preview/border tint pass the initial run above did, rather than trying to
// share state across that boundary.
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
		(_display2 displayCtrl ([1620,1621,1622,1623,1624,1625,1626,1627,1628] select _i2)) ctrlSetBackgroundColor _color2;
		(_display2 displayCtrl ([1600,1601,1602,1603,1604,1605,1606,1607,1608] select _i2)) ctrlSetBackgroundColor (
			if (_i2 == _current2) then { [_color2 select 0, _color2 select 1, _color2 select 2, 1] } else { [0.105, 0.11, 0.095, 0.96] }
		);
	} forEach [0,1,2,3,4,5,6,7,8];
}];
