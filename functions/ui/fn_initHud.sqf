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

// ============================================================================
// Selectable role crest style - entirely a per-player preference, not a
// server/lobby setting (there is no RoleCrestStyle mission param).
//
// 0 = Original: the roleShadow/roleTextBG*/roleCredits* block in TTTHud.hpp,
//     grandfathered and untouched - the classic GMod-TTT homage, textures and
//     all. It is the ONLY style that uses the badge ring (idc 999/1000/1001
//     and its roleShadow, 1272).
// 1-7 = seven self-contained crests, each with its own footprint and theme
//     (Rank Bar, Stencil Column, Service Pips, Punch Card, Bracket Sight,
//     Layered Chip, Ledger Slip - see the big comment block above them in
//     TTTHud.hpp). These used to be decorations hung around style 0's ring,
//     which made them seven variations on one silhouette; they now each own
//     their own shadow/border/plate instead, and the shared "Rank Disc"
//     backing that existed only to serve that old arrangement is gone.
// 8 = Stamped Tag, the design the other seven take their shared recipe from.
//
// What every style 1-8 has in common, deliberately: a black drop shadow, a
// role-coloured border (or backing plate, style 6), a near-black casing
// plate, amber accent marks that are NEVER role-tinted, and the role's letter
// role-tinted over the plate. The role colour is what varies between roles;
// the amber is what ties the styles to each other.
//
// Waldo_roleCrestStylePref lives in THIS client's own profileNamespace (set
// via the H key -> Waldo_fnc_openStylePicker, functions/ui/fn_openStylePicker.sqf),
// so it's saved across sessions/servers and never broadcast or read from
// anywhere else.
// ============================================================================
private _style = profileNamespace getVariable ["Waldo_roleCrestStylePref", 0];
private _usesRing = (_style == 0);

{ (_display displayCtrl _x) ctrlShow _usesRing; } forEach [1272, 999, 1000, 1001];

if (_usesRing) then {
	// GMod-style role crest: tint the circular badge and centre the role's
	// letter (T / D / I / J) in it.
	(_display displayCtrl 1000) ctrlSetTextColor _color;
	private _badge = _display displayCtrl 1001;
	_badge ctrlSetTextColor _color;
	_badge ctrlSetText toUpper (_role select [0, 1]);

	// Style 0's own originally-tuned letter size, set explicitly rather than
	// left to the hpp's sizeEx: this control used to be shared with styles 1-7
	// (which wanted a bigger letter on the Rank Disc's larger medallion), so
	// the size was style-dependent. Styles 1-8 have their own letter controls
	// now and this one is style 0's alone, but the explicit call stays because
	// ctrlTextHeight below only reports a height for the size actually in
	// effect - leaving it implicit would make the centring depend on whether
	// some earlier call had changed it.
	_badge ctrlSetFontHeight (0.088 * safezoneH);

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
};

// Only Traitor/Detective have credits at all, so every style's credit-only
// controls (not just their text) are hidden for everyone else instead of
// sitting there empty.
private _hasCredits = _role in ["Traitor", "Detective"];

// _styleAlways/_styleCredits are idc's grouped by style index (0..8). Every
// control across every style is shown/hidden exactly once per call: the first
// pass hides every style except the selected one, the second then re-hides the
// selected style's credit-only controls if this role has none.
//
// Nothing in _styleCredits is a bordered sub-panel or an inset pocket - each
// entry is either transparent text sitting over a plate the style already
// fills, or (styles 1 and 2) an amber divider/rule whose whole job is to split
// off the balance's half of the composition. That's what makes the credits
// omittable without notice: hide them and the plate is simply plain, with no
// hole where a panel used to be.
private _styleAlways = [
	[],                                                              // 0 - Original: badge ring above, nothing else
	[1300, 1301, 1302, 1303],                                        // 1 - Rank Bar
	[1310, 1311, 1312, 1313],                                        // 2 - Stencil Column
	[1320, 1321, 1322, 1324, 1325, 1326, 1323],                      // 3 - Service Pips (+ 3 pips)
	[1330, 1331, 1332, 1334, 1335, 1336, 1337, 1338, 1333],          // 4 - Punch Card (+ 5 punches)
	[1340, 1341, 1342, 1344, 1345, 1346, 1347, 1348, 1349, 1350, 1351, 1343],   // 5 - Bracket Sight (+ 8 arms)
	[1360, 1361, 1362, 1363, 1364],                                  // 6 - Layered Chip
	[1370, 1371, 1372, 1373, 1374, 1375, 1376],                      // 7 - Ledger Slip
	[1280, 1281, 1282, 1287, 1283, 1284, 1285]                       // 8 - Stamped Tag
];
private _styleCredits = [
	[1002, 1003, 1004, 1005],   // 0 - full credits pill (shadow/bg/accent/text)
	[1304, 1305],                // 1 - amber divider + balance in the right cell
	[1314, 1315],                // 2 - amber rule + balance under it
	[1327],                      // 3 - balance in the corner opposite the pips
	[1339],                      // 4 - balance stamped along the bottom
	[1352],                      // 5 - balance in the plate's lower band
	[1365],                      // 6 - balance in the front plate's lower band
	[1377],                      // 7 - balance on the last ruled line
	[1286]                       // 8 - credits strip
];

{
	private _isActiveStyle = (_forEachIndex == _style);
	{ (_display displayCtrl _x) ctrlShow _isActiveStyle; } forEach _x;
} forEach _styleAlways;
{
	private _show = (_forEachIndex == _style) && _hasCredits;
	{ (_display displayCtrl _x) ctrlShow _show; } forEach _x;
} forEach _styleCredits;

// The role-coloured parts of the active style, by idc. WALDO_ACCENT gold is
// only the hpp default/placeholder for these - they're retinted here on every
// redraw, the same way the shop panel's own accent bar is.
//
// Every other coloured mark in styles 1-8 (pips, punches, bracket arms, the
// dividers, the bevel, the ledger rule) is deliberately absent from this list:
// those stay fixed amber on every role. That's the point of them - the amber is
// the constant that makes eight different silhouettes read as one family, and
// the role colour is the single variable on top of it. Tinting the accents too
// would leave each crest a flat monochrome shape.
private _styleTinted = [
	[1003],               // 0 - the pill's own accent line (original behaviour)
	[1301],               // 1 - border
	[1311],               // 2 - border
	[1321],               // 3 - border
	[1331],               // 4 - border
	[1341],               // 5 - border
	[1361],               // 6 - the back plate itself, not a border
	[1371],               // 7 - border
	[1281, 1283, 1284]    // 8 - border, divider, corner flash
];
{
	(_display displayCtrl _x) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];
} forEach (_styleTinted select _style);

// Styles 1-8's letter: same treatment as style 0's above (role tint, role's
// initial, real measured vertical centring) but on that style's own control
// inside its own plate, since none of them share the ring any more.
//
// The box is per style because the compositions genuinely differ - a landscape
// bar centres its letter in a left-hand cell, the ledger slip centres it in a
// body column right of the margin rule, and so on. Styles 1 and 2 are the two
// whose layout actually reserves space for the balance, so they get a second,
// wider/taller box used when this role has no credits: the letter re-centres
// over the whole plate instead of leaving the balance's half sitting empty.
// Every other style's balance is a thin band the letter already clears, so one
// box covers both cases and there's nothing to reflow.
if (_style > 0) then {
	// [letter idc, xOff, yOff, w, h, sizeEx] - all offsets/sizes in safezoneH,
	// measured from the same badge anchor the hpp block uses.
	private _letterBox = switch (_style) do {
		case 1: { if (_hasCredits) then { [1303, -0.035, 0.089, 0.080, 0.086, 0.062] } else { [1303, -0.035, 0.089, 0.200, 0.086, 0.062] } };
		case 2: { if (_hasCredits) then { [1313,  0.075, 0.022, 0.090, 0.100, 0.062] } else { [1313,  0.075, 0.022, 0.090, 0.150, 0.062] } };
		case 3: { [1323,  0.015, 0.022, 0.150, 0.150, 0.090] };
		case 4: { [1333,  0.015, 0.032, 0.150, 0.140, 0.090] };
		case 5: { [1343,  0.017, 0.027, 0.140, 0.140, 0.088] };
		case 6: { [1364,  0.014, 0.024, 0.145, 0.145, 0.090] };
		case 7: { [1376,  0.051, 0.022, 0.108, 0.130, 0.088] };
		default { [1285, -0.020, -0.044, 0.170, 0.170, 0.098] };   // 8 - Stamped Tag
	};
	_letterBox params ["_lIdc", "_lX", "_lY", "_lW", "_lH", "_lSize"];

	private _letter = _display displayCtrl _lIdc;
	_letter ctrlSetTextColor _color;
	_letter ctrlSetText toUpper (_role select [0, 1]);
	// Before ctrlTextHeight, always - that command reports the height of the
	// text at whatever size is actually in effect, so measuring first would
	// centre against the wrong size.
	_letter ctrlSetFontHeight (_lSize * safezoneH);
	private _lTextH = ctrlTextHeight _letter;
	// Same eyeballed optical nudge style 0 needs: J's hook-shaped tail sits
	// toward the bottom-right of its bounding box, so a geometrically centred J
	// still reads as drifted right. There's no engine measurement for optical
	// glyph weight the way there is for height, so this stays a small constant
	// specific to that one letter rather than a formula.
	private _lNudge = if (_role == "Jester") then { -0.003 * safezoneH } else { 0 };
	_letter ctrlSetPosition [
		((safezoneW + safezoneX) - (0.175 * safezoneH)) + (_lX * safezoneH) + _lNudge,
		((safezoneH + safezoneY) - (0.185 * safezoneH)) + (_lY * safezoneH) + (((_lH * safezoneH) - _lTextH) / 2),
		_lW * safezoneH,
		_lTextH
	];
	_letter ctrlCommit 0;
};

// Credits text/tint per style - only runs for roles that actually have
// credits (_hasCredits), matching the idc's shown by the pass above.
if (_hasCredits) then {
	// idc of the control that actually displays the balance for the active
	// style, plus the box it should be centred in (offsets in safezoneH from
	// the badge anchor, matching that style's hpp geometry) and the format its
	// width can actually fit.
	//
	// NEVER tinted to the role colour - every role colour is a fairly dark,
	// saturated tone, and every one of these sits on a near-black plate, so
	// role-tinted credit text was low-contrast (worst on Traitor red, but
	// Detective/Jester weren't much better) no matter which style. They keep
	// their hpp-declared cream instead, which is high-contrast on near-black
	// regardless of role. This is the one deliberate deviation from Original's
	// exact original behaviour (which did tint 1002), kept because it's a real
	// contrast fix rather than a style change.
	//
	// Styles 1-8's controls are all ST_CENTER with no ST_VCENTER (that flag is
	// a vertical/rotated TEXT ORIENTATION mode, not "centre vertically" - see
	// the long comment above roleText in TTTHud.hpp), so they need the same
	// real ctrlTextHeight centring the letters get, redone every tick since the
	// text's rendered height changes as the number grows. Style 0's pill is
	// left exactly as it always was.
	private _creditBox = switch (_style) do {
		case 1: { [1305,  0.054, 0.089, 0.111, 0.086, "%1 CR"] };
		case 2: { [1315,  0.075, 0.132, 0.090, 0.028, "%1 CR"] };
		case 3: { [1327,  0.025, 0.140, 0.070, 0.022, "%1 CR"] };
		case 4: { [1339,  0.015, 0.144, 0.150, 0.020, "%1 CREDITS"] };
		case 5: { [1352,  0.017, 0.139, 0.140, 0.020, "%1 CREDITS"] };
		case 6: { [1365,  0.014, 0.142, 0.145, 0.020, "%1 CREDITS"] };
		case 7: { [1377,  0.051, 0.144, 0.108, 0.020, "%1 CR"] };
		case 8: { [1286, -0.020, 0.129, 0.170, 0.020, "%1 CR"] };
		default { [1002, 0, 0, 0, 0, "%1 credits"] };   // 0 - Original's pill, positioned by the hpp alone
	};
	_creditBox params ["_creditTextIdc", "_cX", "_cY", "_cW", "_cBoxH", "_cFormat"];
	private _credits = _display displayCtrl _creditTextIdc;

	// Token-guarded the same way the keybind-hint fade below is (and for the
	// same reason): this function re-runs on every respawn and every debug
	// role switch, and this spawn had no guard at all - each call stacked
	// another concurrent 0.5s polling loop on top of whatever earlier ones
	// hadn't exited yet (they only exit once ctrlParent is null or the
	// player is dead), so rapid role cycling piled up redundant loops all
	// fighting to set the same control's text.
	private _creditsTickerToken = (_display getVariable ["Waldo_creditsTickerToken", 0]) + 1;
	_display setVariable ["Waldo_creditsTickerToken", _creditsTickerToken];

	private _needsVCenter = (_style > 0);
	private _vX = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (_cX * safezoneH);
	private _vY = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (_cY * safezoneH);
	private _vW = _cW * safezoneH;
	private _vBoxH = _cBoxH * safezoneH;

	[_credits, _cFormat, _display, _creditsTickerToken, _needsVCenter, _vX, _vY, _vW, _vBoxH] spawn {
		params ["_credits", "_format", "_display", "_token", "_needsVCenter", "_vX", "_vY", "_vW", "_vBoxH"];
		while {
			!isNull ctrlParent _credits
			&& {alive player}
			&& {(_display getVariable ["Waldo_creditsTickerToken", 0]) == _token}
		} do {
			_credits ctrlSetText format [_format, player getVariable ["points", 0]];
			if (_needsVCenter) then {
				private _h = ctrlTextHeight _credits;
				_credits ctrlSetPosition [_vX, _vY + ((_vBoxH - _h) / 2), _vW, _h];
				_credits ctrlCommit 0;
			};
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
