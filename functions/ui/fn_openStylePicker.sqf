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
	// Every preview (both the RscPicture badge swatches for styles 0-7 and
	// style 8's flat RscText swatch) tints the same way: ctrlSetTextColor
	// for the picture (styles 0-7 also get a white rolebg.paa backing disc,
	// same recipe as the real badge - the ring texture alone at this size
	// read as nothing without it), colorBackground for the flat rect.
	private _prev = _display displayCtrl (_previewIdcs select _i);
	if (_i == 8) then { _prev ctrlSetBackgroundColor _color; } else { _prev ctrlSetTextColor _color; };

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
