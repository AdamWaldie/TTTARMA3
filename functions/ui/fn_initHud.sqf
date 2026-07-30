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
// Each style is its OWN construction system - not one recipe restyled nine
// ways. An earlier pass built every style from Style 8's shadow/border/plate/
// amber recipe with only the silhouette varying, which produced variations
// rather than designs. What differs now is how each crest is BUILT:
//
//   0 Original       - circular medallion + full-width pill. Grandfathered;
//                      structurally as shipped, with a light polish pass only.
//   1 Field Medallion- medallion + nameplate. The one style that extends
//                      Original, reusing its exact badge ring and textures.
//   2 Stencil Column - banded: role bands at head and foot, no outline.
//   3 Service Pips   - outline only: no plate, terrain shows through a wash.
//   4 Punch Card     - solid role field, letter knocked out in cream.
//   5 Bracket Sight  - frameless: amber marks and outlined text, no panel.
//   6 Layered Chip   - offset stack: the role plate sits behind, not around.
//   7 Ledger Slip    - paper: pale slip, ink balance, bound role margin.
//   8 Stamped Tag    - bordered plate; the only style that frames itself.
//
// Amber (WALDO_ACCENT) is never role-tinted anywhere. It's the one constant
// across nine otherwise unrelated constructions, which is what keeps them
// reading as the same game's UI. The role colour is what varies.
//
// Waldo_roleCrestStylePref lives in THIS client's own profileNamespace (set
// via the H key -> Waldo_fnc_openStylePicker, functions/ui/fn_openStylePicker.sqf),
// so it's saved across sessions/servers and never broadcast or read from
// anywhere else.
// ============================================================================
private _style = profileNamespace getVariable ["Waldo_roleCrestStylePref", 0];
// Styles 0 and 1 both use the badge ring - style 1's whole idea is to build on
// Original, so it inherits the same medallion (textures and tuned position
// included) and changes only what sits under it. Every other style replaces the
// medallion outright.
private _usesRing = (_style in [0, 1]);

{ (_display displayCtrl _x) ctrlShow _usesRing; } forEach [1272, 999, 1000, 1001];

if (_usesRing) then {
	// GMod-style role crest: tint the circular badge and centre the role's
	// letter (T / D / I / J) in it.
	(_display displayCtrl 1000) ctrlSetTextColor _color;
	private _badge = _display displayCtrl 1001;
	_badge ctrlSetTextColor _color;
	_badge ctrlSetText toUpper (_role select [0, 1]);

	// Set explicitly rather than left to the hpp's sizeEx. Styles 0 and 1 share
	// this one control, and ctrlTextHeight below only reports a height for the
	// size actually in effect - leaving it implicit would make the centring
	// depend on whether some earlier call had changed it.
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
	[1300, 1301, 1302, 1303],                                        // 1 - Field Medallion: nameplate under the ring
	[1310, 1311, 1312, 1313, 1314, 1315, 1316],                      // 2 - Stencil Column
	[1320, 1321, 1322, 1323, 1324, 1325, 1326, 1327, 1328],          // 3 - Service Pips
	[1330, 1331, 1332, 1333, 1334, 1335, 1336, 1337],                // 4 - Punch Card
	[1340, 1341, 1342, 1343, 1344, 1345, 1346, 1347, 1348],          // 5 - Bracket Sight
	[1360, 1361, 1362, 1363, 1364],                                  // 6 - Layered Chip
	[1370, 1371, 1372, 1373, 1374, 1375, 1376],                      // 7 - Ledger Slip
	[1280, 1281, 1282, 1287, 1284, 1283, 1285]                       // 8 - Stamped Tag
];
private _styleCredits = [
	[1002, 1003, 1004, 1005, 1006],   // 0 - the whole pill (shadow/bg/highlight/accent/text)
	[1304, 1305],                      // 1 - amber tick + balance in the nameplate's right half
	[1317],                            // 2 - balance above the foot band
	[1329],                            // 3 - balance inside the frame's lower band
	[1338],                            // 4 - balance stamped across the role field
	[1349],                            // 5 - balance under the letter, no panel behind it
	[1365],                            // 6 - balance in the front plate's lower band
	[1377],                            // 7 - balance on the last ruled line
	[1286]                             // 8 - balance above the foot divider
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
// What actually carries the role colour differs per style, which is the point:
// style 2's head and foot bands, style 3's four frame edges, style 4's entire
// plate, style 6's rear plate, style 7's bound margin, style 8's border. Style 5
// has no entry at all - it's frameless, so its letter is the only role-coloured
// thing on screen.
//
// Every amber mark is deliberately absent from this list and stays fixed on
// every role. Tinting the accents too would collapse each crest to a single hue.
private _styleTinted = [
	[1003],                           // 0 - the pill's own accent line
	[1302],                           // 1 - the nameplate's top accent line
	[1312, 1313],                     // 2 - head and foot bands
	[1321, 1322, 1323, 1324],         // 3 - all four frame edges
	[1331],                           // 4 - the whole plate
	[],                               // 5 - frameless; the letter is the only role colour
	[1361],                           // 6 - the rear plate, not a border
	[1372],                           // 7 - the bound margin
	[1281]                            // 8 - the border
];
{
	(_display displayCtrl _x) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];
} forEach (_styleTinted select _style);

// Styles 2-8's letter: same treatment as style 0's above (role tint, role's
// initial, real measured vertical centring) but on that style's own control
// inside its own construction. Style 1 is absent because it shares the badge
// ring's letter, handled in the _usesRing block above.
//
// The box is per style because the constructions genuinely differ - a banded
// column centres its letter between its two bands, the ledger slip centres it in
// the body column right of the bound margin, and so on.
if (_style >= 2) then {
	// [letter idc, xOff, yOff, w, h, sizeEx] - offsets/sizes in safezoneH,
	// measured from the same badge anchor the hpp block uses.
	private _letterBox = switch (_style) do {
		case 2: { [1316, 0.075, 0.036, 0.090, 0.100, 0.062] };
		case 3: { [1328, 0.015, 0.022, 0.150, 0.150, 0.090] };
		case 4: { [1337, 0.015, 0.032, 0.150, 0.140, 0.090] };
		case 5: { [1348, 0.017, 0.027, 0.140, 0.140, 0.088] };
		case 6: { [1364, 0.014, 0.024, 0.145, 0.145, 0.090] };
		case 7: { [1376, 0.037, 0.022, 0.122, 0.130, 0.088] };
		default { [1285, 0.079, 0.020, 0.086, 0.126, 0.070] };   // 8 - Stamped Tag
	};
	_letterBox params ["_lIdc", "_lX", "_lY", "_lW", "_lH", "_lSize"];

	// Style 2's column reserves its lower half for the balance, so with no
	// credits the letter re-centres over the whole column instead of sitting high
	// in a half-empty plate. Nothing else needs this - every other style's
	// balance is a thin band its letter already clears.
	if (_style == 2 && {!_hasCredits}) then { _lH = 0.122; };

	private _letter = _display displayCtrl _lIdc;
	// Style 4 is the one style whose letter is NOT role-tinted: its plate is the
	// role colour at full opacity and the letter is knocked out of it in cream.
	// Tinting it here would paint the letter the same colour as the field it sits
	// on and erase it entirely.
	if (_style != 4) then { _letter ctrlSetTextColor _color; };
	_letter ctrlSetText toUpper (_role select [0, 1]);
	// Before ctrlTextHeight, always - that command reports the height of the text
	// at whatever size is in effect, so measuring first would centre against the
	// wrong size.
	_letter ctrlSetFontHeight (_lSize * safezoneH);
	private _lTextH = ctrlTextHeight _letter;
	// Same eyeballed optical nudge style 0 needs: J's hook-shaped tail sits toward
	// the bottom-right of its bounding box, so a geometrically centred J still
	// reads as drifted right. There's no engine measurement for optical glyph
	// weight the way there is for height, so this stays a small constant specific
	// to that one letter rather than a formula.
	private _lNudge = if (_role == "Jester") then { -0.003 * safezoneH } else { 0 };
	_letter ctrlSetPosition [
		((safezoneW + safezoneX) - (0.175 * safezoneH)) + (_lX * safezoneH) + _lNudge,
		((safezoneH + safezoneY) - (0.185 * safezoneH)) + (_lY * safezoneH) + (((_lH * safezoneH) - _lTextH) / 2),
		_lW * safezoneH,
		_lTextH
	];
	_letter ctrlCommit 0;
};

// Style 1's nameplate carries the role's NAME, not its initial - the medallion
// above it already shows the letter, so repeating it would waste the bar. Set
// once here since it never changes for this HUD instance. Its box shrinks to the
// bar's left half when there's a balance to sit beside, and takes the whole bar
// when there isn't, so the plate never reads as half-empty.
if (_style == 1) then {
	private _name = _display displayCtrl 1303;
	_name ctrlSetText toUpper _role;
	private _nH = ctrlTextHeight _name;
	private _nX = if (_hasCredits) then { 0.004 } else { 0 };
	private _nW = if (_hasCredits) then { 0.080 } else { 0.150 };
	_name ctrlSetPosition [
		((safezoneW + safezoneX) - (0.175 * safezoneH)) + (_nX * safezoneH),
		((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.152 * safezoneH) + (((0.026 * safezoneH) - _nH) / 2),
		_nW * safezoneH,
		_nH
	];
	_name ctrlCommit 0;
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
	// Every one of these controls is ST_CENTER with no ST_VCENTER (that flag is
	// a vertical/rotated TEXT ORIENTATION mode, not "centre vertically" - see
	// the long comment above roleText in TTTHud.hpp), so they need the same real
	// ctrlTextHeight centring the letters get, redone every tick since the
	// text's rendered height changes as the number grows.
	//
	// Style 0 included. ST_CENTER only ever centred it horizontally, so its
	// balance had always rendered against the top of a 0.03H pill with all the
	// slack below it - visibly high in its own casing. Nothing about Original's
	// design intended that; it's the same measure-don't-guess fix the rest of
	// this HUD already had, applied to the one control that never got it.
	private _creditBox = switch (_style) do {
		case 1: { [1305, 0.086, 0.152, 0.060, 0.026, "%1 CR"] };
		case 2: { [1317, 0.075, 0.136, 0.090, 0.022, "%1 CR"] };
		case 3: { [1329, 0.023, 0.144, 0.134, 0.022, "%1 CREDITS"] };
		case 4: { [1338, 0.015, 0.144, 0.150, 0.020, "%1 CREDITS"] };
		case 5: { [1349, 0.017, 0.139, 0.140, 0.020, "%1 CREDITS"] };
		case 6: { [1365, 0.014, 0.142, 0.145, 0.020, "%1 CREDITS"] };
		// Lowercase, alone among styles 1-8: this one is a bookkeeper's paper
		// slip, and shouting CREDITS at it would break the conceit.
		case 7: { [1377, 0.037, 0.144, 0.122, 0.020, "%1 credits"] };
		case 8: { [1286, 0.079, 0.153, 0.086, 0.019, "%1 CR"] };
		// 0 - Original. Keeps its own lowercase "%1 credits" wording rather than
		// being normalised to the other styles' CR/CREDITS - the full-width pill
		// has room for it, and it's part of what the style is.
		default { [1002, 0, -0.040, 0.150, 0.030, "%1 credits"] };
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

	private _vX = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (_cX * safezoneH);
	private _vY = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (_cY * safezoneH);
	private _vW = _cW * safezoneH;
	private _vBoxH = _cBoxH * safezoneH;

	[_credits, _cFormat, _display, _creditsTickerToken, _vX, _vY, _vW, _vBoxH] spawn {
		params ["_credits", "_format", "_display", "_token", "_vX", "_vY", "_vW", "_vBoxH"];
		while {
			!isNull ctrlParent _credits
			&& {alive player}
			&& {(_display getVariable ["Waldo_creditsTickerToken", 0]) == _token}
		} do {
			_credits ctrlSetText format [_format, player getVariable ["points", 0]];
			private _h = ctrlTextHeight _credits;
			_credits ctrlSetPosition [_vX, _vY + ((_vBoxH - _h) / 2), _vW, _h];
			_credits ctrlCommit 0;
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
