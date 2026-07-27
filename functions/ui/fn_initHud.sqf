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
_badge ctrlSetText toUpper (_role select [0, 1]);

// Real measured vertical centring, not a guessed offset: ST_VCENTER does NOT
// mean "centre vertically" despite the name - BIKI documents it (with
// ST_UP/ST_DOWN) as a vertical/rotated TEXT ORIENTATION mode that "should
// not be mixed with any other styles", which is exactly what this control
// used to do (ST_CENTER + ST_VCENTER) and almost certainly why the letter
// rendered badly off-position rather than just high/low by a few pixels.
// ctrlTextHeight reads back the engine's own actual rendered height for the
// text just set, so this centres correctly regardless of the font's real
// metrics instead of assuming a line-height ratio.
private _badgeX = (safezoneW + safezoneX) - (0.175 * safezoneH);
private _badgeY = (safezoneH + safezoneY) - (0.185 * safezoneH);
private _badgeSize = 0.15 * safezoneH;
private _textH = ctrlTextHeight _badge;

// J's hook-shaped tail sits toward the bottom-right of its bounding box, so a
// geometrically-centred J still reads as drifted right - unlike vertical
// centring above, there's no engine measurement for "optical" glyph weight,
// so this is a small eyeballed nudge specific to that one letter, not a
// general formula.
private _opticalNudgeX = if (_role == "Jester") then { -0.006 * safezoneH } else { 0 };

_badge ctrlSetPosition [_badgeX + _opticalNudgeX, _badgeY + ((_badgeSize - _textH) / 2), _badgeSize, _textH];
_badge ctrlCommit 0;

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

// Top bar keybind row: a normal game gives no other indication of what's
// bound, so list whatever's actually relevant to this role (Waldo_keyHintsFor,
// shared with the scoreboard's own keybind panel). This re-runs on every
// debug role switch / respawn (same as the badge above), so it never shows a
// stale role's binds - each redraw also restarts the fade-out from fully
// visible, below.
//
// Deliberately plain RscText (ctrlSetText), not structured text with coloured
// <t> spans: this row needs precise single-line centring via ctrlTextHeight
// (same fix as roleText above), and structured text was never actually
// verified to interact correctly with that command - safer to keep the two
// concerns (colour vs. precise centring) apart than risk a repeat of the
// CT_STRUCTURED_TEXT/ST_VCENTER surprises already hit this session.
private _hintsList = [_role] call Waldo_keyHintsFor;
private _hintRow = "";
{ _x params ["_key", "_label"]; _hintRow = _hintRow + format ["[%1] %2     ", _key, _label]; } forEach _hintsList;
private _hintTextCtrl = _display displayCtrl 3612;
_hintTextCtrl ctrlSetText _hintRow;

private _hintBoxX = (safezoneX + (0.5 * safezoneW)) - (0.15 * safezoneW);
private _hintBoxY = (safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH);
private _hintBoxW = 0.30 * safezoneW;
private _hintBoxH = 0.045 * safezoneH;
private _hintTextH = ctrlTextHeight _hintTextCtrl;
_hintTextCtrl ctrlSetPosition [_hintBoxX, _hintBoxY + ((_hintBoxH - _hintTextH) / 2), _hintBoxW, _hintTextH];
_hintTextCtrl ctrlCommit 0;

// Visible for a few seconds after every (re)draw - a fresh round start or a
// role change is exactly when this is worth glancing at - then fades out
// COMPLETELY (box and text alike, not just dimmed to a resting alpha): this
// is a one-time reminder, not a permanent reference (that's what the
// scoreboard's own keybind panel is for). A token guard (same idiom as
// WaldosMissionPack's SafeStart countdown, Waldo_SafeStart_TimerToken) stops
// an in-flight fade from a PREVIOUS redraw from clobbering a fresh one if
// this function re-runs again (rapid role changes / quick respawns) before
// the last fade finished.
private _hintShadowCtrl = _display displayCtrl 3610;
private _hintBgCtrl = _display displayCtrl 3611;
_hintShadowCtrl ctrlSetBackgroundColor [0, 0, 0, 0.55];
_hintShadowCtrl ctrlCommit 0;
_hintBgCtrl ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0.85];
_hintBgCtrl ctrlCommit 0;
_hintTextCtrl ctrlSetTextColor [0.95, 0.93, 0.86, 1];
_hintTextCtrl ctrlCommit 0;

private _hintFadeToken = (_display getVariable ["Waldo_hintFadeToken", 0]) + 1;
_display setVariable ["Waldo_hintFadeToken", _hintFadeToken];
[_hintShadowCtrl, _hintBgCtrl, _hintTextCtrl, _display, _hintFadeToken] spawn {
	params ["_shadowCtrl", "_bgCtrl", "_textCtrl", "_display", "_token"];
	sleep 8;
	if (isNull _shadowCtrl || {isNull _bgCtrl} || {isNull _textCtrl}) exitWith {};
	if ((_display getVariable ["Waldo_hintFadeToken", 0]) != _token) exitWith {};   // superseded by a newer redraw
	_shadowCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
	_shadowCtrl ctrlCommit 3;
	_bgCtrl ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0];
	_bgCtrl ctrlCommit 3;
	_textCtrl ctrlSetTextColor [0.95, 0.93, 0.86, 0];
	_textCtrl ctrlCommit 3;
};
