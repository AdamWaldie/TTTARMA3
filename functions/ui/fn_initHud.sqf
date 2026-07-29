//////////////////////////////////////////////////////////////////
// Waldo_fnc_initHud
// CLIENT: shows the role badge (bottom-right) tinted by role, and a live
// credits readout for Traitors/Detectives.
//////////////////////////////////////////////////////////////////

disableSerialization;

// titleRsc recreates the display (a NEW object) every time it's called for
// the same class, rather than reusing whatever's already showing - and this
// function re-runs on every respawn and every debug role switch. Calling it
// unconditionally meant every one of those re-runs silently orphaned the
// PREVIOUS display: this function itself re-fetches _display fresh each time
// so its own controls (badge/credits/keybind row) kept working, but anything
// that captured a reference ONCE and kept it across time - the top bar's
// timer loop (Waldo_fnc_topBarTimer), started once and never re-fetching -
// was left writing to an orphaned, invisible display while the real one sat
// at its blank .hpp default forever. Only ever calling titleRsc when the
// resource doesn't already exist keeps the SAME display alive for the whole
// round, so every control reference taken anywhere stays valid.
if (isNull (uiNamespace getVariable ["TTTHud", displayNull])) then {
	titleRsc ["TTTHud", "PLAIN", 1, false];
};
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
// general formula. Confirmed live that the first attempt (-0.006) overshot
// and put it too far left - halved rather than re-guessed from scratch.
private _opticalNudgeX = if (_role == "Jester") then { -0.003 * safezoneH } else { 0 };

_badge ctrlSetPosition [_badgeX + _opticalNudgeX, _badgeY + ((_badgeSize - _textH) / 2), _badgeSize, _textH];
_badge ctrlCommit 0;

// Only Traitor/Detective have credits at all, so every style's credit-only
// controls (not just their text) are hidden for everyone else instead of
// sitting there empty.
private _hasCredits = _role in ["Traitor", "Detective"];

// ============================================================================
// Selectable role crest style (RoleCrestStyle mission param). Style 0 is the
// shipped default (roleShadow/roleTextBG*/roleCredits* in TTTHud.hpp,
// untouched); styles 1-7 are the alternate treatments added around the same
// badge ring (see the big comment block above s1TickN in TTTHud.hpp).
//
// _styleAlways/_styleCredits are idc's grouped by style index (0..7). Every
// control across every style is shown/hidden exactly once per call: first
// pass hides every style except the selected one, second pass then re-hides
// the selected style's credit-only controls if this role has none.
//
// A server value of 8 ("Player Choice") hands the decision to each player
// individually - Waldo_roleCrestStylePref lives in THIS client's own
// profileNamespace (set via the H key, functions/core/fn_initClient.sqf),
// so it's saved across sessions and never broadcast. Any other server value
// always wins over that saved preference, on every redraw - a server admin
// forcing a style is meant to actually stick, not just be a default.
// ============================================================================
private _serverCrestStyle = missionNamespace getVariable ["Waldo_roleCrestStyle", 0];
private _style = if (_serverCrestStyle == 8) then {
	profileNamespace getVariable ["Waldo_roleCrestStylePref", 0]
} else {
	_serverCrestStyle
};

private _styleAlways = [
	[],                                             // 0 - original: nothing beyond the credits pill below
	[1200, 1201, 1202, 1203],                       // 1 - Signal Ring: compass ticks
	[1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217],// 2 - Corner Bracket Frame
	[1220, 1221, 1222, 1223],                        // 3 - Fused Tag: tab + role name
	[1230, 1231, 1232],                              // 4 - Wallet Chip: chip + role name
	[],                                              // 5 - Satellite Chip: nothing beyond the pill below
	[1250, 1251, 1252, 1253, 1254, 1255, 1256, 1257],// 6 - IFF Transponder: ticks
	[1260, 1261]                                     // 7 - Contact Blip: pulse rings
];
private _styleCredits = [
	[1002, 1003, 1004, 1005],   // 0 - full credits pill (shadow/bg/accent/text)
	[1204, 1205],                // 1 - Signal Ring tag
	[1218],                      // 2 - Corner Bracket credit text
	[1224],                      // 3 - Fused Tag credits line
	[1233],                      // 4 - Wallet Chip credits line
	[1240, 1241],                // 5 - Satellite Chip pill
	[1258, 1259],                // 6 - IFF Transponder squawk tab
	[1262]                       // 7 - Contact Blip coord text
];

{
	private _isActiveStyle = (_forEachIndex == _style);
	{ (_display displayCtrl _x) ctrlShow _isActiveStyle; } forEach _x;
} forEach _styleAlways;
{
	private _show = (_forEachIndex == _style) && _hasCredits;
	{ (_display displayCtrl _x) ctrlShow _show; } forEach _x;
} forEach _styleCredits;

// Elements that always need the role tint regardless of credits, per style
// (the badge ring itself is already tinted above and is common to every
// style). Contact Blip's two pulse rings are RscPicture, so they're retinted
// with ctrlSetTextColor like the badge ring, not ctrlSetBackgroundColor.
switch (_style) do {
	case 3: {   // Fused Tag: accent strip along the top of the tab
		(_display displayCtrl 1222) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];
	};
	case 7: {   // Contact Blip: both pulse rings, low alpha so they read as a glow, not a solid disc
		(_display displayCtrl 1260) ctrlSetTextColor [_color select 0, _color select 1, _color select 2, 0.22];
		(_display displayCtrl 1261) ctrlSetTextColor [_color select 0, _color select 1, _color select 2, 0.4];
	};
};

// Credits text/tint per style - only runs for roles that actually have
// credits (_hasCredits), matching the idc's shown by the pass above.
if (_hasCredits) then {
	// idc of the control that actually displays "<n> credits" text for the
	// active style, and whether that text itself gets tinted to the role
	// colour (some styles keep it neutral ink instead, per the mockups).
	private _creditTextIdc = [1002, 1205, 1218, 1224, 1233, 1241, 1259, 1262] select _style;
	private _tintCreditText = [true, true, false, true, true, false, false, false] select _style;

	private _credits = _display displayCtrl _creditTextIdc;
	if (_tintCreditText) then { _credits ctrlSetTextColor _color; };

	// Style 0's pill also has its own accent line, tinted the same way it
	// always was.
	if (_style == 0) then {
		(_display displayCtrl 1003) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];
	};

	// Token-guarded the same way the keybind-hint fade below is (and for the
	// same reason): this function re-runs on every respawn and every debug
	// role switch, and this spawn had no guard at all - each call stacked
	// another concurrent 0.5s polling loop on top of whatever earlier ones
	// hadn't exited yet (they only exit once ctrlParent is null or the
	// player is dead), so rapid role cycling piled up redundant loops all
	// fighting to set the same control's text.
	private _creditsTickerToken = (_display getVariable ["Waldo_creditsTickerToken", 0]) + 1;
	_display setVariable ["Waldo_creditsTickerToken", _creditsTickerToken];
	[_credits, _style, _display, _creditsTickerToken] spawn {
		params ["_credits", "_style", "_display", "_token"];
		while {
			!isNull ctrlParent _credits
			&& {alive player}
			&& {(_display getVariable ["Waldo_creditsTickerToken", 0]) == _token}
		} do {
			private _pts = player getVariable ["points", 0];
			private _text = switch (_style) do {
				case 1: { format ["%1 cr", _pts] };        // Signal Ring tag
				case 6: { format ["%1", _pts] };            // IFF squawk code
				case 7: { format ["%1 CR", _pts] };          // Contact Blip coord readout
				default { format ["%1 credits", _pts] };
			};
			_credits ctrlSetText _text;
			sleep 0.5;
		};
	};
};

// Style 3/4 always show the role's name (identity, not shop status) - set
// once here since it never changes for the lifetime of this HUD instance.
if (_style == 3) then { (_display displayCtrl 1223) ctrlSetText _role; };
if (_style == 4) then { (_display displayCtrl 1232) ctrlSetText _role; };

// Top bar keybind row: a normal game gives no other indication of what's
// bound, so list whatever's actually relevant to this role (Waldo_keyHintsFor,
// shared with the scoreboard's own keybind panel). This re-runs on every
// debug role switch / respawn (same as the badge above), so it never shows a
// stale role's binds - each redraw also restarts the fade-out from fully
// visible, below.
//
// "%1: %2" (not "[%1] %2"): the dev keys ARE literally "[" and "]", so
// bracket-wrapping them produced the nonsensical "[[] Dev Menu" / "[]] Cycle
// Role" - a colon separator has no such collision with any key label.
//
// Two lines, not one: CT_STATIC never wraps (just cuts overflow), and 7 items
// under Testing Mode never fit one line at a readable size - split evenly
// across topBarHintText/topBarHintText2 (idc 3612/3613).
//
// Deliberately plain RscText (ctrlSetText) for both, not structured text with
// coloured <t> spans: needs precise centring via ctrlTextHeight (same fix as
// roleText above), and structured text was never verified to interact
// correctly with that command - safer to keep "needs colour" and "needs
// precise centring" apart than risk a repeat of this session's
// CT_STRUCTURED_TEXT/ST_VCENTER surprises.
private _hintsList = [_role] call Waldo_keyHintsFor;
private _half = ceil ((count _hintsList) / 2);
private _line1 = "";
private _line2 = "";
{
	_x params ["_key", "_label"];
	private _entry = format ["%1: %2     ", _key, _label];
	if (_forEachIndex < _half) then { _line1 = _line1 + _entry; } else { _line2 = _line2 + _entry; };
} forEach _hintsList;

private _hintBoxX = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) + (0.015 * safezoneW);
private _hintBoxW = (0.36 * safezoneW) - (0.030 * safezoneW);
private _hintRowH = 0.0375 * safezoneH;
private _hintRow1Y = (safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH);
private _hintRow2Y = _hintRow1Y + _hintRowH;

private _hintTextCtrl = _display displayCtrl 3612;
private _hintText2Ctrl = _display displayCtrl 3613;
_hintTextCtrl ctrlSetText _line1;
_hintText2Ctrl ctrlSetText _line2;

{
	_x params ["_ctrl", "_rowY"];
	private _h = ctrlTextHeight _ctrl;
	_ctrl ctrlSetPosition [_hintBoxX, _rowY + ((_hintRowH - _h) / 2), _hintBoxW, _h];
	_ctrl ctrlCommit 0;
} forEach [[_hintTextCtrl, _hintRow1Y], [_hintText2Ctrl, _hintRow2Y]];

// Visible for a few seconds after every (re)draw - a fresh round start or a
// role change is exactly when this is worth glancing at - then fades out
// COMPLETELY (box and both text lines alike, not just dimmed to a resting
// alpha): this is a one-time reminder, not a permanent reference (that's what
// the scoreboard's own keybind panel is for). A token guard (same idiom as
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
_hintText2Ctrl ctrlSetTextColor [0.95, 0.93, 0.86, 1];
_hintText2Ctrl ctrlCommit 0;

private _hintFadeToken = (_display getVariable ["Waldo_hintFadeToken", 0]) + 1;
_display setVariable ["Waldo_hintFadeToken", _hintFadeToken];
[_hintShadowCtrl, _hintBgCtrl, _hintTextCtrl, _hintText2Ctrl, _display, _hintFadeToken] spawn {
	params ["_shadowCtrl", "_bgCtrl", "_textCtrl", "_text2Ctrl", "_display", "_token"];
	sleep 8;
	if (isNull _shadowCtrl || {isNull _bgCtrl} || {isNull _textCtrl} || {isNull _text2Ctrl}) exitWith {};
	if ((_display getVariable ["Waldo_hintFadeToken", 0]) != _token) exitWith {};   // superseded by a newer redraw
	_shadowCtrl ctrlSetBackgroundColor [0, 0, 0, 0];
	_shadowCtrl ctrlCommit 3;
	_bgCtrl ctrlSetBackgroundColor [0.105, 0.11, 0.095, 0];
	_bgCtrl ctrlCommit 3;
	_textCtrl ctrlSetTextColor [0.95, 0.93, 0.86, 0];
	_textCtrl ctrlCommit 3;
	_text2Ctrl ctrlSetTextColor [0.95, 0.93, 0.86, 0];
	_text2Ctrl ctrlCommit 3;
};
