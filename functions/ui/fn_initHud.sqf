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

// Key-hints panel: a normal game gives no other indication of what's bound,
// so list whatever's actually relevant to this role. Dev-only binds are even
// less discoverable than gameplay ones, so they're appended too, but only
// when Testing Mode is actually on - this re-runs on every debug role switch
// (Waldo_debugSetRole), so it never shows a stale role's binds.
private _hints = ["<t color='#F2BE55'>L</t>  Holster", "<t color='#F2BE55'>K</t>  Scoreboard"];
if (_role in ["Traitor", "Detective"]) then {
	_hints pushBack "<t color='#F2BE55'>B</t>  Buy Menu";
	_hints pushBack "<t color='#F2BE55'>Y</t>  Use Item";
};
if (_role == "Traitor") then {
	_hints pushBack "<t color='#F2BE55'>T</t> (hold)  Ping";
};
if (missionNamespace getVariable ["TestingFlag", false]) then {
	_hints pushBack "<t color='#9a2ecc'>\</t>  Dev Menu";
	_hints pushBack "<t color='#9a2ecc'>]</t>  Cycle Role";
};
private _hintBody = "";
{ _hintBody = _hintBody + _x + "<br/>"; } forEach _hints;
(_display displayCtrl 1010) ctrlSetStructuredText parseText _hintBody;
