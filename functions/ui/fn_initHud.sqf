//////////////////////////////////////////////////////////////////
// Waldo_fnc_initHud
// CLIENT: shows the role badge (bottom-right) tinted by role, and a live
// credits readout for Traitors/Detectives.
//////////////////////////////////////////////////////////////////

disableSerialization;

titleRsc ["TTTHud", "PLAIN", 1, false];
waitUntil { !isNull (uiNamespace getVariable ["TTTHud", displayNull]) };
private _display = uiNamespace getVariable "TTTHud";

private _role = player getVariable ["role", "Innocent"];
private _color = [_role] call Waldo_roleColor;

// GMod-style role crest: tint the circular badge and centre the role's letter
// (T / D / I / J) in it.
(_display displayCtrl 1000) ctrlSetTextColor _color;
private _badge = _display displayCtrl 1001;
_badge ctrlSetTextColor _color;
_badge ctrlSetStructuredText parseText (toUpper (_role select [0, 1]));

// Accent line under the credits pill, tinted to match (same treatment as the
// shop panel's accent bar).
(_display displayCtrl 1003) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];

// Live credits readout for shop roles (blank for the others).
private _creditsCtrl = _display displayCtrl 1002;
_creditsCtrl ctrlSetText "";
if (_role in ["Traitor", "Detective"]) then {
	private _credits = _creditsCtrl;
	_credits ctrlSetTextColor _color;
	[_credits] spawn {
		params ["_credits"];
		while { !isNull ctrlParent _credits && {alive player} } do {
			_credits ctrlSetText format ["%1 credits", player getVariable ["points", 0]];
			sleep 0.5;
		};
	};
};
