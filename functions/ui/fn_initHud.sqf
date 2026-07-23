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

(_display displayCtrl 1000) ctrlSetTextColor _color;
private _badge = _display displayCtrl 1001;
_badge ctrlSetTextColor _color;
_badge ctrlSetStructuredText parseText (_role select [0, 1]);

// Live credits readout for shop roles.
if (_role in ["Traitor", "Detective"]) then {
	private _credits = _display displayCtrl 1002;
	_credits ctrlSetTextColor _color;
	[_credits] spawn {
		params ["_credits"];
		while { !isNull ctrlParent _credits && {alive player} } do {
			_credits ctrlSetText format ["Credits: %1", player getVariable ["points", 0]];
			sleep 0.5;
		};
	};
};
