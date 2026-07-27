//////////////////////////////////////////////////////////////////
// Waldo_fnc_initHud
// CLIENT: shows the role badge (bottom-right) tinted by role, and a live
// credits readout for Traitors/Detectives.
//////////////////////////////////////////////////////////////////

disableSerialization;

titleRsc ["TTTHud", "PLAIN", 1, false];
waitUntil { !isNull (uiNamespace getVariable ["TTTHud", displayNull]) };
private _display = uiNamespace getVariable "TTTHud";

// The ping picker's controls live inside this same resource (see TTTHud in
// ui/TTTHud.hpp), which is created fresh for EVERY player at round start
// regardless of role - nothing ever defaulted it to hidden, so it sat there
// visible and empty for everyone until their first T hold. Waldo_fnc_pingWheelOpen
// is the only thing that should ever show it again after this.
(_display displayCtrl 3520) ctrlShow false;
Waldo_pingWheelOpen = false;

private _role = player getVariable ["role", "Innocent"];
private _color = [_role] call Waldo_roleColor;

// GMod-style role crest: tint the circular badge and centre the role's letter
// (T / D / I / J) in it.
(_display displayCtrl 1000) ctrlSetTextColor _color;
private _badge = _display displayCtrl 1001;
_badge ctrlSetTextColor _color;
_badge ctrlSetStructuredText parseText (toUpper (_role select [0, 1]));

// Credits pill (badge nameplate): only Traitor/Detective have credits at all,
// so the whole pill - not just its text - is hidden for everyone else instead
// of sitting there as an empty black bar with nothing to show.
private _hasCredits = _role in ["Traitor", "Detective"];
{ (_display displayCtrl _x) ctrlShow _hasCredits; } forEach [1002, 1003, 1004, 1005];

if (_hasCredits) then {
	// Accent line under the credits pill, tinted to match (same treatment as
	// the shop panel's accent bar).
	(_display displayCtrl 1003) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];

	private _credits = _display displayCtrl 1002;
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
	_hints pushBack "<t color='#9a2ecc'>[</t>  Dev Menu";
	_hints pushBack "<t color='#9a2ecc'>]</t>  Cycle Role";
};
private _hintBody = "";
{ _hintBody = _hintBody + _x + "<br/>"; } forEach _hints;

// Size the panel to how many lines actually apply (5 normally, up to 7 under
// Testing Mode) instead of a fixed box sized for the worst case and mostly
// empty the rest of the time - it's anchored by its bottom edge, so it grows
// upward as lines are added rather than shifting its corner on screen.
//
// _lineH is the per-line height BUDGET for sizing this box - it does not
// control actual on-screen line spacing (that's the font's own metric, driven
// by keyHintText's size), so it has to be measured against that font size, not
// guessed independently. keyHintText's size resolves to a fixed 0.024*safezoneH
// on any normal (>=1.2 aspect) display (the formula's `min 1.2` clause caps it
// there in practice), and real line pitch for readable text runs meaningfully
// taller than the bare glyph size - sizing the box any tighter than that
// clips the last line(s) instead of just leaving extra room.
private _lineH = 0.032 * safezoneH;
private _padV = 0.007 * safezoneH;
private _panelW = 0.13 * safezoneW;   // wide enough that "T (hold)  Ping" (the
                                       // longest line) can't wrap - a structured-
                                       // text control wraps instead of clipping,
                                       // which would silently break this same
                                       // per-line height assumption.
private _panelH = (_padV * 2) + ((count _hints) * _lineH);
private _panelX = safezoneX + (0.012 * safezoneW);
private _panelY = (safezoneH + safezoneY) - _panelH;

private _shadowCtrl = _display displayCtrl 1012;
_shadowCtrl ctrlSetPosition [
	_panelX - (0.004 * safezoneH), _panelY - (0.004 * safezoneH),
	_panelW + (0.008 * safezoneH), _panelH + (0.008 * safezoneH)
];
_shadowCtrl ctrlCommit 0;

private _bgCtrl = _display displayCtrl 1013;
_bgCtrl ctrlSetPosition [_panelX, _panelY, _panelW, _panelH];
_bgCtrl ctrlCommit 0;

private _textCtrl = _display displayCtrl 1010;
_textCtrl ctrlSetPosition [
	_panelX + (0.008 * safezoneW), _panelY + _padV,
	_panelW - (0.016 * safezoneW), _panelH - (_padV * 2)
];
_textCtrl ctrlCommit 0;
_textCtrl ctrlSetStructuredText parseText _hintBody;

// Visible and easy to read for a few seconds after every (re)draw - a fresh
// round start or a role change is exactly when this is actually worth
// glancing at - then fades to a small, unobtrusive corner reference rather
// than sitting fully opaque for the whole round. ctrlCommit with a duration
// (not 0) animates the transition instead of snapping to it.
_shadowCtrl ctrlSetBackgroundColor [0, 0, 0, 0.55];
_shadowCtrl ctrlCommit 0;
_bgCtrl ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0.85];
_bgCtrl ctrlCommit 0;
[_shadowCtrl, _bgCtrl] spawn {
	params ["_shadowCtrl", "_bgCtrl"];
	sleep 6;
	if (isNull _shadowCtrl || {isNull _bgCtrl}) exitWith {};
	_shadowCtrl ctrlSetBackgroundColor [0, 0, 0, 0.18];
	_shadowCtrl ctrlCommit 2;
	_bgCtrl ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0.28];
	_bgCtrl ctrlCommit 2;
};
