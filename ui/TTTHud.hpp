class RscTitles
{
	class default {
		idd = -3;
		fadeout=0;
		fadein=0;
		duration = 99999;
		onLoad = "";
	};

	// ============================================================================
	// TTTWarmup - "Selecting Roles: N" during the pre-round warmup, in the same
	// centre-top position/casing style as TTTHud's own round-timer bar (not the
	// same titleRsc resource though: TTTHud doesn't exist yet at this point -
	// role isn't assigned, so there's no badge/credits/keybinds to show - and
	// this phase is over well before TTTHud is ever created, so the two never
	// overlap; TTTHud's own titleRsc call simply evicts this one when the round
	// goes live, same single-slot behaviour used deliberately here instead of
	// worked around). Driven by Waldo_fnc_warmupBar.
	// ============================================================================
	class TTTWarmup {
		idd = -1;
		fadeout = 0;
		fadein = 0;
		duration = 99999;
		onLoad = "with uiNamespace do {TTTWarmup = _this select 0}";

		class controlsBackground {
			class twShadow: RscText {
				idc = -1;
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) - (0.004 * safezoneH);
				y = (safezoneY + (0.015 * safezoneH)) - (0.004 * safezoneH);
				w = (0.36 * safezoneW) + (0.008 * safezoneH);
				h = (0.062 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class twBG: RscText {
				idc = -1;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = safezoneY + (0.015 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.062 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class twAccent: RscText {
				idc = -1;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.062 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.006 * safezoneH;
				colorBackground[] = WALDO_ACCENT;
				style = 0;
			};
			class twText: RscText {
				idc = 3630;
				text = "";
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = safezoneY + (0.015 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.062 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95,0.93,0.86,1};
				style = ST_CENTER;   // vertical centring in script via ctrlTextHeight
				font = "PuristaBold";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.35);
				shadow = 1;
			};
		};
	};

	class TTTHud {
		idd = -1;
		fadeout=0;
		fadein=0;
		duration = 99999;
		onLoad = "with uiNamespace do {TTTHud = _this select 0}";

		// GMod-TTT style role crest: a circular badge with the role's letter
		// (T / D / I / J) centred in it, tinted to the role colour. The badge is
		// SQUARE (w == h, both in safezoneH units) so ui\role.paa renders as a
		// true circle and stays fully on-screen — the old height used safezoneW,
		// which stretched it into an off-screen ellipse on widescreen.
		class controlsBackground {
			// Drop shadow behind the whole crest: a dedicated soft Gaussian-blurred
			// disc, not an offset dark-tinted copy of the fill - that old technique
			// produced a hard-edged flat silhouette instead of an actual soft shadow.
			//
			// All three badge images (role/rolebg/roleshadow) are real .paa, not
			// .png. .png first seemed fine (role.png/rolebg.png loaded live while
			// roleshadow.png alone threw "Cannot load texture"), but rolebg.png
			// then failed the exact same way on a later test with no code change
			// in between - so this isn't about any one image's content, it's that
			// this engine build/version doesn't reliably support raw PNG for these
			// controls at all. Converted with a real DXT5 encoder
			// (github.com/woozymasta/paa) rather than a hand-rolled one, since a
			// subtly wrong PAA would just trade one silent load failure for
			// another.
			// "Rank Disc" shared backing for styles 1-7 (style 0 stays exactly as
			// shipped - homage to the original; style 8 doesn't use the ring at
			// all). A dark casing-coloured rim plus a thin gold accent ring
			// behind the existing badge, so it reads as a coin struck in metal
			// instead of a flat sticker. MUST be declared before roleShadow/the
			// rest of the badge below - Arma draws sibling controls in
			// declaration order, later on top of earlier - so this sits BEHIND
			// the badge ring instead of covering the letter. Reuses ui\rolebg.paa
			// (the same filled backing-disc asset the default style already
			// uses for its own white face) rather than a new texture, just
			// scaled up around the same badge centre and tinted flat instead of
			// role-coloured (this is a fixed materials choice, not per-role).
			// Hidden for styles 0 and 8 (see Waldo_fnc_initHud). These sizes
			// were originally Style 7 (Contact Blip)'s own bespoke pulse-ring
			// effect at the same dimensions - retired in favour of every
			// non-original style sharing this one backing, Contact Blip
			// included, rather than layering two similar ring treatments.
			class rankDiscRim: RscPicture
			{
				idc = 1270;
				text = "ui\rolebg.paa";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.02 * safezoneH);
				w = 0.19 * safezoneH;
				h = 0.19 * safezoneH;
				color[] = {0.105, 0.11, 0.095, 1};   // WALDO_CASING, flat - not role-tinted
			};
			class rankDiscAccent: RscPicture
			{
				idc = 1271;
				text = "ui\rolebg.paa";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.0075 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.0075 * safezoneH);
				w = 0.165 * safezoneH;
				h = 0.165 * safezoneH;
				color[] = {0.85, 0.62, 0.20, 1};   // WALDO_ACCENT gold, flat - not role-tinted
			};
			// idc 1272, not -1: style 8 (Stamped Tag) doesn't use the ring at
			// all and needs to hide this too, or its soft shadow blob would
			// linger behind style 8's own plate with nothing left to belong to.
			class roleShadow: RscPicture
			{
				idc = 1272;
				text = "ui\roleshadow.paa";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.008 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.010 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				color = [0,0,0,0.8];
			};
			class roleTextBGBG: RscPicture
			{
				idc = 999;
				text = "ui\rolebg.paa";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.185 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				color = [1,1,1,0.5];
			};
			class roleTextBG: RscPicture
			{
				idc = 1000;
				text = "ui\role.paa";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.185 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
			};
			class roleText: RscText
			{
				idc = 1001;
				text = "";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.185 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				// CT_STRUCTURED_TEXT's valign='middle' (the old control type here) was
				// a documented engine bug - BI forum reports confirm valign has no real
				// effect on RscStructuredText - so switching to plain RscText was the
				// right call. But ST_VCENTER (which used to be added here) is NOT a
				// "centre vertically" flag despite the name - BIKI documents it (with
				// ST_UP/ST_DOWN) as a VERTICAL/ROTATED TEXT ORIENTATION mode that
				// "should not be mixed with any other styles", which is exactly what
				// combining it with ST_CENTER did. That's almost certainly what threw
				// the letter noticeably off-position rather than just high/low by a
				// few pixels. ST_CENTER alone handles horizontal centring correctly;
				// vertical centring is done for real below, in fn_initHud.sqf, via
				// ctrlTextHeight's actual measured value - not another guessed offset.
				style = ST_CENTER;
				font = "PuristaBold";
				// ~59% of the badge box - confirmed live that 0.075 (50%) still
				// read too small, so this jumps further than the last increment
				// rather than inching up again. Still a bit short of the old 0.095
				// (63%, no margin at all against the ring) to keep some breathing
				// room.
				sizeEx = 0.088 * safezoneH;
				shadow = false;
				colorBackground[] = {0,0,0,0};
			};
			// Credits readout: a proper casing pill (shadow + dark base + accent line)
			// matching the shop/debug header treatment, instead of bare floating text.
			class roleCreditsShadow: RscText
			{
				idc = 1004;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.004 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.225 * safezoneH)) - (0.004 * safezoneH);
				w = (0.15 * safezoneH) + (0.008 * safezoneH);
				h = (0.03 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class roleCreditsBG: RscText
			{
				idc = 1005;
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.225 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.03 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class roleCreditsAccent: RscText
			{
				idc = 1003;
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.225 * safezoneH)) + (0.03 * safezoneH) - (0.0025 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.0025 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			class roleCredits: RscText
			{
				idc = 1002;
				text = "";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.225 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.03 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {1,1,1,1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.021 * safezoneH;
				shadow = 1;
			};

			// ====================================================================
			// Selectable role crest styles (RoleCrestStyle mission param, styles
			// 1-7; style 0 is the roleShadow/roleTextBG*/roleCredits* block above,
			// unchanged). Every style below reuses the SAME badge ring - idc 999
			// (rolebg), 1000 (role, tinted+lettered), 1001 (letter) - as its
			// centrepiece; only the decoration around it differs. That ring's own
			// position/size is never touched here, on purpose: it's the one thing
			// that was actually tuned live against a running client (see the
			// comments above roleText), so every new style inherits that exact
			// anchor instead of re-guessing it.
			//
			// None of these overlap the ring on the side that would need them
			// drawn BEHIND it (Arma draws siblings in declaration order, later on
			// top of earlier, and these are all declared after the ring) - tabs
			// and chips that read as "attached to" the ring in the mockups sit
			// flush against its edge instead of tucking underneath it, so draw
			// order never matters for them. The one style that genuinely needs
			// something behind the ring (Contact Blip's pulse rings) is declared
			// up near roleShadow instead, for that reason.
			//
			// Waldo_fnc_initHud shows only the active style's controls and hides
			// the rest, and - independently - hides each style's credit-only
			// controls for roles with no credits (Jester/Innocent), the same way
			// it already does for style 0's 1002-1005.
			// ====================================================================

			// ---- Style 1: Signal Ring - compass ticks + a small credits tag
			// clipped to the ring's lower-right edge. ----
			class s1TickN: RscText { idc = 1200; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.073 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.017 * safezoneH); w = 0.004 * safezoneH; h = 0.014 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s1TickS: RscText { idc = 1201; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.073 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.153 * safezoneH); w = 0.004 * safezoneH; h = 0.014 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s1TickE: RscText { idc = 1202; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.153 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.073 * safezoneH); w = 0.014 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s1TickW: RscText { idc = 1203; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.017 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.073 * safezoneH); w = 0.014 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			// x offset was 0.09H (right edge at 0.19H) - the ring itself only has
			// a 0.175H budget from its own left edge before hitting the true
			// right edge of the safe area (RX = right_edge - 0.175H), so that
			// pushed the tag 0.015H past the edge of the screen. 0.07H (right
			// edge at 0.17H) keeps a small margin instead.
			class s1TagBG: RscText {
				idc = 1204;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.07 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.128 * safezoneH);
				w = 0.10 * safezoneH;
				h = 0.026 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class s1TagText: RscText {
				idc = 1205;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.07 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.128 * safezoneH);
				w = 0.10 * safezoneH;
				h = 0.026 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = ST_CENTER + ST_VCENTER;
				font = "PuristaBold";
				sizeEx = 0.018 * safezoneH;
				shadow = 1;
			};

			// ---- Style 2: Corner Bracket Frame - four L-brackets (Arma's own
			// target-marking convention) around the ring, plain credits text
			// underneath, no pill. ----
			class s2BrTLh: RscText { idc = 1210; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.02 * safezoneH); w = 0.03 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrTLv: RscText { idc = 1211; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.02 * safezoneH); w = 0.004 * safezoneH; h = 0.03 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrTRh: RscText { idc = 1212; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.14 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.02 * safezoneH); w = 0.03 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrTRv: RscText { idc = 1213; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.166 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.02 * safezoneH); w = 0.004 * safezoneH; h = 0.03 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrBLh: RscText { idc = 1214; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.166 * safezoneH); w = 0.03 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrBLv: RscText { idc = 1215; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.14 * safezoneH); w = 0.004 * safezoneH; h = 0.03 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrBRh: RscText { idc = 1216; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.14 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.166 * safezoneH); w = 0.03 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2BrBRv: RscText { idc = 1217; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.166 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.14 * safezoneH); w = 0.004 * safezoneH; h = 0.03 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			// Above the brackets, not below: the badge anchor only leaves 0.035H
			// of headroom below the ring before the safezone's own bottom edge,
			// and the brackets alone (0.02H pad + 0.03H arm) already use all but
			// 0.015H of that - nowhere near enough room for a text row without
			// spilling past the visible safe area. Above has the same room the
			// original style's credits pill already proved out (it sits at
			// RY - 0.04H).
			//
			// s2CreditBG: this was bare floating text with just a drop shadow -
			// the only credit readout in the whole crest with nothing solid
			// behind it, so against a bright terrain background it washed out
			// unlike every other style's pill/tab/chip. Same WALDO_HEADERBG
			// plate every other credit readout uses, sized to the text.
			class s2CreditBG: RscText {
				idc = 1219;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.05 * safezoneH);
				w = 0.19 * safezoneH;
				h = 0.022 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class s2CreditText: RscText {
				idc = 1218;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.05 * safezoneH);
				w = 0.19 * safezoneH;
				h = 0.022 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.018 * safezoneH;
				shadow = 1;
			};

			// ---- Style 3: Fused Tag - a name-tab flush against the ring's left
			// edge (touching, not underlapping, so draw order can't hide it under
			// the ring). Role name always shows (identity, not shop status); the
			// credits line is the only part gated on _hasCredits. ----
			class s3TabShadow: RscText {
				idc = 1220;
				x = (((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.16 * safezoneH)) - (0.004 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.05 * safezoneH)) - (0.004 * safezoneH);
				w = (0.16 * safezoneH) + (0.008 * safezoneH);
				h = (0.05 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class s3TabBG: RscText {
				idc = 1221;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.16 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.05 * safezoneH);
				w = 0.16 * safezoneH;
				h = 0.05 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class s3TabAccent: RscText {
				idc = 1222;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.16 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.05 * safezoneH);
				w = 0.16 * safezoneH;
				h = 0.004 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			// ST_LEFT alone, NOT "+ ST_VCENTER" - see the long-documented reason
			// above roleText (this file's own BIKI-sourced note: ST_VCENTER is a
			// vertical/rotated TEXT ORIENTATION flag, not "centre vertically",
			// and "should not be mixed with any other styles"). This control and
			// its siblings below (s3Credits/s4RoleName/s4Credits) were the only
			// ones in the whole crest that combined ST_VCENTER with another
			// style and rendered fully blank in testing - real vertical
			// centring is done in script instead (Waldo_fnc_initHud), the same
			// ctrlTextHeight technique roleText already uses.
			class s3RoleName: RscText {
				idc = 1223;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.152 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.054 * safezoneH);
				w = 0.144 * safezoneH;
				h = 0.024 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_LEFT;
				font = "PuristaBold";
				sizeEx = 0.018 * safezoneH;
				shadow = 1;
			};
			class s3Credits: RscText {
				idc = 1224;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.152 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.078 * safezoneH);
				w = 0.144 * safezoneH;
				h = 0.018 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = ST_LEFT;
				font = "PuristaMedium";
				sizeEx = 0.015 * safezoneH;
				shadow = 1;
			};

			// ---- Style 4: Wallet Chip - avatar-plus-balance chip flush against
			// the ring's left edge. Role name always shows; credits line is the
			// only part gated on _hasCredits. ----
			class s4ChipShadow: RscText {
				idc = 1230;
				x = (((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.15 * safezoneH)) - (0.004 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.049 * safezoneH)) - (0.004 * safezoneH);
				w = (0.15 * safezoneH) + (0.008 * safezoneH);
				h = (0.052 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class s4ChipBG: RscText {
				idc = 1231;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.15 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.049 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.052 * safezoneH;
				colorBackground[] = WALDO_CASING;
				style = 0;
			};
			// ST_LEFT alone - see s3RoleName's comment above, same bug.
			class s4RoleName: RscText {
				idc = 1232;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.142 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.053 * safezoneH);
				w = 0.134 * safezoneH;
				h = 0.024 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_LEFT;
				font = "PuristaBold";
				sizeEx = 0.018 * safezoneH;
				shadow = 1;
			};
			class s4Credits: RscText {
				idc = 1233;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.142 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.077 * safezoneH);
				w = 0.134 * safezoneH;
				h = 0.02 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = ST_LEFT;
				font = "PuristaMedium";
				sizeEx = 0.015 * safezoneH;
				shadow = 1;
			};

			// ---- Style 5: Satellite Chip - the ring on its own (closest to the
			// original GMod-TTT look), with a small credits pill clipped onto its
			// lower-right edge, like a notification badge on an avatar. ----
			class s5SatBG: RscText {
				idc = 1240;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.095 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.13 * safezoneH);
				w = 0.075 * safezoneH;
				h = 0.024 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class s5SatText: RscText {
				idc = 1241;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.095 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.13 * safezoneH);
				w = 0.075 * safezoneH;
				h = 0.024 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER + ST_VCENTER;
				font = "PuristaBold";
				sizeEx = 0.016 * safezoneH;
				shadow = 1;
			};

			// ---- Style 6: IFF Transponder - eight ticks standing in for a radar
			// sweep (a real true rotating sweep would need a per-frame script
			// loop; this is the static approximation), plus a squawk-code tab
			// (credits) centred below the ring. ----
			class s6TickN:  RscText { idc = 1250; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.073 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.018 * safezoneH); w = 0.004 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickS:  RscText { idc = 1251; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.073 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.156 * safezoneH); w = 0.004 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickE:  RscText { idc = 1252; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.156 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.073 * safezoneH); w = 0.012 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickW:  RscText { idc = 1253; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.018 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.073 * safezoneH); w = 0.012 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickNE: RscText { idc = 1254; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.152 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.014 * safezoneH); w = 0.006 * safezoneH; h = 0.006 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickSE: RscText { idc = 1255; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.152 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.158 * safezoneH); w = 0.006 * safezoneH; h = 0.006 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickSW: RscText { idc = 1256; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.014 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.158 * safezoneH); w = 0.006 * safezoneH; h = 0.006 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			class s6TickNW: RscText { idc = 1257; x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.014 * safezoneH); y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.014 * safezoneH); w = 0.006 * safezoneH; h = 0.006 * safezoneH; colorBackground[] = {0.61, 0.60, 0.54, 0.65}; style = 0; };
			// y offset was 0.16H (bottom edge at 0.186H) - 0.001H past the 0.185H
			// budget below the ring. 0.157H gives a small margin instead.
			class s6SquawkBG: RscText {
				idc = 1258;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.157 * safezoneH);
				w = 0.11 * safezoneH;
				h = 0.026 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class s6SquawkText: RscText {
				idc = 1259;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.157 * safezoneH);
				w = 0.11 * safezoneH;
				h = 0.026 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER + ST_VCENTER;
				font = "PuristaBold";
				sizeEx = 0.017 * safezoneH;
				shadow = 1;
			};

			// ---- Style 7: Contact Blip credits readout. Now shares the Rank
			// Disc backing (idc 1270/1271, declared up near roleShadow above)
			// with every other non-original style instead of its own bespoke
			// pulse rings. This is just the muted grid-reference-style text
			// underneath, echoing the ping wheel's own text colour (#BFBCAF)
			// rather than the gold accent. ----
			//
			// s7CoordBG: same fix as s2CreditBG above - this was the other
			// credit readout with nothing solid behind it, and its text is
			// deliberately muted/desaturated on top of that, so it had the
			// worst contrast of any style against a bright terrain
			// background. A subtle translucent backing (not the full-opaque
			// WALDO_HEADERBG the pill styles use) keeps the "minimal grid
			// readout" feel while still guaranteeing it's readable.
			class s7CoordBG: RscText {
				idc = 1263;
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.16 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.022 * safezoneH;
				colorBackground[] = {0, 0, 0, 0.55};
				style = 0;
			};
			class s7CoordText: RscText {
				idc = 1262;
				text = "";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.16 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.022 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER;
				font = "PuristaMedium";
				sizeEx = 0.016 * safezoneH;
				shadow = 1;
			};

			// ---- Style 8: Stamped Tag - the one style that drops role.paa/
			// rolebg.paa/roleshadow.paa entirely (idc 999/1000/1001/roleShadow
			// all hidden for this style, see Waldo_fnc_initHud) in favour of a
			// flat square plate in this HUD's own casing material, same recipe
			// as the shop panel/timer bar/notification cards. No dependency on
			// the badge texture's baked-in oval proportions at all. Arma's
			// RscText only draws rectangles - there's no clip-path equivalent -
			// so the diagonal corner flash from the original concept mockup is
			// a small square accent block instead of a diagonal cut; everything
			// else (border, divider, flash, credits strip) is flat rects, same
			// materials as Rank Disc. Letter and credits text both use real
			// ctrlTextHeight centring in script (ST_CENTER alone, no VCENTER -
			// same documented reason as roleText/s3RoleName above), not the
			// ST_VCENTER combo that rendered blank on styles 3/4.
			class s8Shadow: RscText {
				idc = 1280;
				x = (((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH)) - (0.004 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH)) - (0.004 * safezoneH);
				w = (0.17 * safezoneH) + (0.008 * safezoneH);
				h = (0.194 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class s8Border: RscText {
				idc = 1281;
				x = (((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH)) - (0.006 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH)) - (0.006 * safezoneH);
				w = (0.17 * safezoneH) + (0.012 * safezoneH);
				h = (0.194 * safezoneH) + (0.012 * safezoneH);
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			class s8Plate: RscText {
				idc = 1282;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.194 * safezoneH;
				colorBackground[] = WALDO_CASING;
				style = 0;
			};
			class s8Divider: RscText {
				idc = 1283;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH)) + (0.17 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.003 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			// Declared after s8Plate so it renders on top, sitting right in the
			// plate's own top-right corner.
			class s8Flash: RscText {
				idc = 1284;
				x = (((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH)) + (0.144 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH);
				w = 0.026 * safezoneH;
				h = 0.026 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			class s8Letter: RscText {
				idc = 1285;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.17 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};   // tinted to the role colour at runtime
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.1 * safezoneH;
				shadow = false;
			};
			class s8Credits: RscText {
				idc = 1286;
				text = "";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = (((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH)) + (0.173 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.02 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.015 * safezoneH;
				shadow = 1;
			};

			// Key-hints panel (bottom-left): a normal game gives a player no other
			// way to learn what's bound, and dev-only binds are even less
			// discoverable - so this lists whatever's actually relevant to the
			// current role, plus the dev binds too when Testing Mode is on
			// (Waldo_fnc_initHud populates idc 1010, re-run on every role change).
			// Sizes here are placeholders - Waldo_fnc_initHud resizes all three
			// via ctrlSetPosition to fit however many lines actually apply (6
			// without Testing Mode, up to 8 with it), so this never sits around
			// as a fixed box mostly empty.
			// ====================================================================
			// Top bar: round timer (counts down, always visible while the round is
			// live) + a horizontal keybind row directly below it that fades out
			// completely a few seconds after each (re)draw - replaces the old
			// bottom-left key-hints panel and the server's per-second hintSilent
			// timer broadcast (Waldo_fnc_roundLoop now only owns game logic; the
			// client computes and renders its own countdown locally from the
			// already-broadcast timelimit/Waldo_startTime, see Waldo_fnc_topBarTimer).
			// Centred top, matching this mission pack's shared WALDO_CASING look.
			// 3600-3603: timer shadow/casing/accent/text. 3610-3614: keybind row
			// shadow/casing/2 text lines (up to 8 items under Testing Mode don't
			// fit one line without clipping - CT_STATIC never wraps, it just cuts
			// overflow - so the row is genuinely two stacked lines, not one).
			// ====================================================================
			class topBarTimerShadow: RscText
			{
				idc = 3600;
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) - (0.004 * safezoneH);
				y = (safezoneY + (0.015 * safezoneH)) - (0.004 * safezoneH);
				w = (0.36 * safezoneW) + (0.008 * safezoneH);
				h = (0.062 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class topBarTimerBG: RscText
			{
				idc = 3601;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = safezoneY + (0.015 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.062 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			// Baseline/full-width position for the accent bar - Waldo_fnc_topBarTimer
			// shrinks its w/x at runtime to double as a countdown progress bar (see
			// there for why: needs a live fraction-of-time-remaining this file can't
			// know), and flashes it in the last 30s. These values are just its
			// starting (100% remaining) state.
			class topBarTimerAccent: RscText
			{
				idc = 3602;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.062 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.006 * safezoneH;
				colorBackground[] = WALDO_ACCENT;
				style = 0;
			};
			class topBarTimerText: RscText
			{
				idc = 3603;
				text = "";
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = safezoneY + (0.015 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.062 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95,0.93,0.86,1};
				// ST_CENTER alone, NOT "+ ST_VCENTER" - that combination is invalid
				// (see roleText's own fix above); vertical centring is done in
				// script via ctrlTextHeight, same as roleText.
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.35);
				shadow = 1;
			};
			class topBarHintShadow: RscText
			{
				idc = 3610;
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) - (0.004 * safezoneH);
				y = ((safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH)) - (0.004 * safezoneH);
				w = (0.36 * safezoneW) + (0.008 * safezoneH);
				h = (0.075 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = {0, 0, 0, 0.55};
				style = 0;
			};
			class topBarHintBG: RscText
			{
				idc = 3611;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.075 * safezoneH;
				colorBackground[] = {0.105, 0.11, 0.095, 0.85};
				style = 0;
			};
			// Two stacked lines, not one - a plain RscText/CT_STATIC control never
			// wraps (it just cuts overflow), and 7 keybinds under Testing Mode
			// never fit one line at a readable size regardless of box width.
			// Waldo_fnc_initHud splits the current role's hint list evenly across
			// both.
			class topBarHintText: RscText
			{
				idc = 3612;
				text = "";
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) + (0.015 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH);
				w = (0.36 * safezoneW) - (0.030 * safezoneW);
				h = 0.0375 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95,0.93,0.86,1};
				style = ST_CENTER;
				font = "PuristaMedium";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72);
				shadow = 1;
			};
			class topBarHintText2: RscText
			{
				idc = 3613;
				text = "";
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) + (0.015 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.068 * safezoneH) + (0.0375 * safezoneH);
				w = (0.36 * safezoneW) - (0.030 * safezoneW);
				h = 0.0375 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {0.95,0.93,0.86,1};
				style = ST_CENTER;
				font = "PuristaMedium";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72);
				shadow = 1;
			};

			// Announcement banner (airdrops, etc. - Waldo_fnc_topBarAnnounce):
			// "pops out" from directly under the keybind row, fades in, holds,
			// fades back out - alpha 0 by default. All three (shadow/bg/text)
			// need real idc's since the fade animates all of them together.
			class topBarAnnounceShadow: RscText
			{
				idc = 3619;
				x = ((safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW)) - (0.004 * safezoneH);
				y = ((safezoneY + (0.015 * safezoneH)) + (0.149 * safezoneH)) - (0.004 * safezoneH);
				w = (0.36 * safezoneW) + (0.008 * safezoneH);
				h = (0.05 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = {0, 0, 0, 0};
				style = 0;
			};
			class topBarAnnounceBG: RscText
			{
				idc = 3620;
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.149 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.05 * safezoneH;
				colorBackground[] = {0.105, 0.11, 0.095, 0};
				style = 0;
			};
			class topBarAnnounceText: RscText
			{
				idc = 3621;
				text = "";
				x = (safezoneX + (0.5 * safezoneW)) - (0.18 * safezoneW);
				y = (safezoneY + (0.015 * safezoneH)) + (0.149 * safezoneH);
				w = 0.36 * safezoneW;
				h = 0.05 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {1, 0.82, 0.25, 0};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
				shadow = 1;
			};
		};

		// ========================================================================
		// Ping picker (Waldo_fnc_pingWheelOpen/Render/Close). Hold T to show it,
		// scroll to move the highlight, release T to fire it. Lives inside THIS
		// same title resource (not a second titleRsc-shown class) and is just
		// shown/hidden via ctrlShow - titleRsc only has one active slot, so a
		// second titleRsc call for a separate class would silently evict this
		// entire HUD (badge + key hints) the moment the picker first opened.
		// ========================================================================
		class Controls {
			// Row height was 0.044*safezoneH for ALL rows, but the SELECTED row
			// renders TWO lines (label at size 1.0, description at 0.8) - two
			// stacked lines at those sizes need roughly 0.09*safezoneH with a
			// real line-height margin (same "budget must exceed the actual
			// rendered size" rule as the old key-hints panel), so the
			// description clipped past the row's bottom edge every time. Rows
			// bumped to 0.075*safezoneH each (group height grown to match) fixes
			// that with real margin. `style = 0` on the group itself (overriding
			// RscControlsGroup's own default) kills the scrollbar this never
			// needed - 5 fixed rows in a group sized to fit all of them isn't
			// scrollable content to begin with.
			class pingWheelGroup: RscControlsGroup {
				idc = 3520;
				x = (safezoneX + (0.5 * safezoneW)) - (0.1 * safezoneW);
				y = safezoneY + (0.28 * safezoneH);
				w = 0.2 * safezoneW;
				h = 0.42 * safezoneH;
				style = 0;

				class Controls {
					class pwShadow: RscText {
						idc = -1;
						x = -0.004 * safezoneH;
						y = -0.004 * safezoneH;
						w = (0.2 * safezoneW) + (0.008 * safezoneH);
						h = (0.42 * safezoneH) + (0.008 * safezoneH);
						colorBackground[] = WALDO_SHADOW;
						style = 0;
					};
					class pwCasing: RscText {
						idc = -1;
						x = 0; y = 0;
						w = 0.2 * safezoneW;
						h = 0.42 * safezoneH;
						colorBackground[] = WALDO_CASING;
						style = 0;
					};
					class pwHeaderBG: RscText {
						idc = -1;
						x = 0; y = 0;
						w = 0.2 * safezoneW;
						h = 0.036 * safezoneH;
						colorBackground[] = WALDO_HEADERBG;
						style = 0;
					};
					class pwTitle: RscText {
						idc = -1;
						text = "PING  -  scroll to choose";
						x = 0; y = 0;
						w = 0.2 * safezoneW;
						h = 0.036 * safezoneH;
						colorBackground[] = {0,0,0,0};
						colorText[] = {0.95,0.93,0.86,1};
						style = ST_CENTER + ST_VCENTER;
						font = "PuristaBold";
						sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
						shadow = 1;
					};
					class pwAccent: RscText {
						idc = 3502;
						x = 0;
						y = 0.036 * safezoneH;
						w = 0.2 * safezoneW;
						h = 0.0025 * safezoneH;
						colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
						style = 0;
					};
					class pwOpt0: RscStructuredText {
						idc = 3510;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.040 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.075 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt1: RscStructuredText {
						idc = 3511;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.115 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.075 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt2: RscStructuredText {
						idc = 3512;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.190 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.075 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt3: RscStructuredText {
						idc = 3513;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.265 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.075 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt4: RscStructuredText {
						idc = 3514;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.340 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.075 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
				};
			};
		};
	};

	class blind {
		idd = 0;
		fadeout=0;
		fadein=0;
		duration = 99999;
		onLoad = "with uiNamespace do {blind = _this select 0}";

		class controlsBackground {
			class blindy
			{
				type = 0;
				idc = 700;
				text = "";
				style = 18;
				x = safezoneX;
				y = safezoneY;
				w = 1 * safezoneW;
				h = 1 * safezoneH;
				colorBackground[] = {0,0,0,0.9};
				colorText[] = {0.01,0.45,1,1};
				lineSpacing = 0;
				font = "PuristaMedium";
				sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
				default = false;
			};
		};
	};
};

// ============================================================================
// WaldoShop - shared buy menu dialog. A centred panel with a near-black header,
// a thin accent stripe (tinted to the role colour at runtime), a scrollable grid
// of item cards, and a description footer that updates as you hover. Cards are
// generated at runtime from the role's catalog by Waldo_fnc_openBuyMenu, so this
// shell never changes when items are added.
//   1100 title, 1101 credits, 1102 item grid, 1103 hover description,
//   1104 header bar, 1107 purchased-panel group (rows built at runtime by
//   Waldo_shopRenderPurchased, including the Y/U/J key-assign buttons),
//   1108 accent stripe (role-tinted), idc 2 close.
// ============================================================================
class WaldoShop {
	idd = -1;
	fadeout = 0.2;
	fadein = 0.2;
	movingEnable = false;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do { WaldoShop = _this select 0 }";

	class controlsBackground {
		// Dims the world behind the panel and drops a soft shadow under it.
		class shopDim: RscText {
			idc = -1;
			x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
			colorBackground[] = WALDO_DIM;
			style = 0;
		};
		class shopShadow: RscText {
			idc = -1;
			x = safezoneX + (0.28 * safezoneW) - (0.006 * safezoneW);
			y = safezoneY + (0.18 * safezoneH) - (0.006 * safezoneH);
			w = (0.44 * safezoneW) + (0.012 * safezoneW);
			h = (0.64 * safezoneH) + (0.012 * safezoneH);
			colorBackground[] = WALDO_SHADOW;
			style = 0;
		};
		class shopBG: RscText {
			idc = -1;
			x = safezoneX + (0.28 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.44 * safezoneW;
			h = 0.64 * safezoneH;
			colorBackground[] = WALDO_CASING;
			style = 0;
		};
		class shopHeader: RscText {
			idc = 1104;
			x = safezoneX + (0.28 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.44 * safezoneW;
			h = 0.062 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class shopAccentBar: RscText {
			idc = 1108;
			x = safezoneX + (0.28 * safezoneW);
			y = safezoneY + (0.18 * safezoneH) + (0.062 * safezoneH);
			w = 0.44 * safezoneW;
			h = 0.006 * safezoneH;
			colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
			style = 0;
		};
		class shopTitle: RscText {
			idc = 1100;
			text = "Shop";
			x = safezoneX + (0.295 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.26 * safezoneW;
			h = 0.062 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_LEFT + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5);
			shadow = 1;
		};
		class shopCredits: RscText {
			idc = 1101;
			text = "0 credits";
			x = safezoneX + (0.44 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.265 * safezoneW;
			h = 0.062 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_RIGHT + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
			shadow = 1;
		};
		class shopDescBG: RscText {
			idc = -1;
			x = safezoneX + (0.29 * safezoneW);
			y = safezoneY + (0.665 * safezoneH);
			w = 0.42 * safezoneW;
			h = 0.10 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class shopDesc: RscStructuredText {
			idc = 1103;
			text = "";
			x = safezoneX + (0.30 * safezoneW);
			y = safezoneY + (0.672 * safezoneH);
			w = 0.40 * safezoneW;
			h = 0.088 * safezoneH;
			size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			class Attributes {
				font = "PuristaMedium";
				color = "#F2EFE3";
				align = "left";
				shadow = 1;
			};
		};

		// "Purchased" side panel: what you already bought this round + how to use
		// it (the catalog tooltip). A second panel to the right of the main shop.
		class shopPurchBG: RscText {
			idc = -1;
			x = safezoneX + (0.73 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.20 * safezoneW;
			h = 0.64 * safezoneH;
			colorBackground[] = WALDO_CASING;
			style = 0;
		};
		class shopPurchHeader: RscText {
			idc = -1;
			x = safezoneX + (0.73 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.20 * safezoneW;
			h = 0.062 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class shopPurchAccentBar: RscText {
			idc = -1;
			x = safezoneX + (0.73 * safezoneW);
			y = safezoneY + (0.18 * safezoneH) + (0.062 * safezoneH);
			w = 0.20 * safezoneW;
			h = 0.006 * safezoneH;
			colorBackground[] = WALDO_ACCENT;
			style = 0;
		};
		class shopPurchTitle: RscText {
			idc = 1105;
			text = "Purchased";
			x = safezoneX + (0.735 * safezoneW);
			y = safezoneY + (0.18 * safezoneH);
			w = 0.19 * safezoneW;
			h = 0.062 * safezoneH;
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_LEFT + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.1);
			shadow = 1;
		};
	};

	class Controls {
		class shopGroup: RscControlsGroup {
			idc = 1102;
			x = safezoneX + (0.29 * safezoneW);
			y = safezoneY + (0.26 * safezoneH);
			w = 0.42 * safezoneW;
			h = 0.395 * safezoneH;
		};
		class shopPurchGroup: RscControlsGroup {
			idc = 1107;
			x = safezoneX + (0.735 * safezoneW);
			y = safezoneY + (0.26 * safezoneH);
			w = 0.185 * safezoneW;
			h = 0.545 * safezoneH;

			class Controls {
				// Invisible spacer, declared (not runtime-created) so the group's
				// scrollable extent is fixed at dialog-load time - a group's scroll
				// range is computed from its DECLARED children only, not whatever
				// Waldo_shopRenderPurchased ctrlCreate's into it afterwards (same
				// reason the item grid above sizes itself to fit rather than relying
				// on runtime children to trigger scrolling). This stays tall enough
				// that the group scrolls once a round's purchases run past one screen,
				// and every runtime row shares its scroll offset as a sibling in the
				// same group.
				//
				// A declared child sitting at the SAME x/y as the runtime rows/buttons
				// ate every click meant for them - a config-time control apparently
				// wins hit-testing over a ctrlCreate'd one layered "on top" of it in
				// the same group. Pushed off to a razor-thin sliver past the row
				// content's right edge (rows/buttons only ever use x in [0, 0.18*W])
				// so it still forces the same scroll-triggering height without ever
				// overlapping anything clickable.
				class shopPurchSpacer: RscStructuredText {
					idc = -1;
					text = "";
					x = 0.181 * safezoneW;
					y = 0;
					w = 0.001 * safezoneW;
					h = 2.0 * safezoneH;
				};
			};
		};
		class shopClose: RscButton {
			idc = 2;
			text = "CLOSE [ESC]";
			x = safezoneX + (0.60 * safezoneW);
			y = safezoneY + (0.775 * safezoneH);
			w = 0.10 * safezoneW;
			h = 0.04 * safezoneH;
			colorBackground[] = WALDO_BTN;
			colorBackgroundActive[] = WALDO_BTNACTIVE;
			colorText[] = {0.95,0.93,0.86,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			action = "closeDialog 1";
		};
	};
};

// ============================================================================
// WaldoStylePicker - opened with H (Waldo_fnc_openStylePicker). Replaces the
// old cycle-through-styles-on-keypress behaviour with an actual picker: a 3x3
// grid of preview cards (one per Style 0-8), each showing that style's badge
// shape tinted to the player's own role colour plus its name, so the player
// can see before they commit rather than tabbing blind. Same shadow/casing/
// header/accent-stripe recipe as WaldoShop/WaldoScore. Card layout is
// declared, not generated, because hpp has no loops - the shared base
// coordinates are local #defines, undef'd right after this class so they
// don't leak into anything declared later in the file.
// ============================================================================
#define SP_BASEX (safezoneX + (0.32 * safezoneW))
#define SP_BASEY (safezoneY + (0.274 * safezoneH))
#define SP_CARDW (0.11 * safezoneW)
#define SP_CARDH (0.13 * safezoneH)
#define SP_COLSTEP (0.125 * safezoneW)
#define SP_ROWSTEP (0.145 * safezoneH)
class WaldoStylePicker {
	idd = -1;
	fadeout = 0.15;
	fadein = 0.15;
	movingEnable = false;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do { WaldoStylePicker = _this select 0 }";

	class controlsBackground {
		class spDim: RscText {
			idc = -1;
			x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
			colorBackground[] = WALDO_DIM;
			style = 0;
		};
		class spShadow: RscText {
			idc = -1;
			x = (safezoneX + (0.30 * safezoneW)) - (0.006 * safezoneW);
			y = (safezoneY + (0.20 * safezoneH)) - (0.006 * safezoneH);
			w = (0.40 * safezoneW) + (0.012 * safezoneW);
			h = (0.58 * safezoneH) + (0.012 * safezoneH);
			colorBackground[] = WALDO_SHADOW;
			style = 0;
		};
		class spBG: RscText {
			idc = -1;
			x = safezoneX + (0.30 * safezoneW);
			y = safezoneY + (0.20 * safezoneH);
			w = 0.40 * safezoneW;
			h = 0.58 * safezoneH;
			colorBackground[] = WALDO_CASING;
			style = 0;
		};
		class spHeader: RscText {
			idc = -1;
			x = safezoneX + (0.30 * safezoneW);
			y = safezoneY + (0.20 * safezoneH);
			w = 0.40 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class spAccentBar: RscText {
			idc = 1591;
			x = safezoneX + (0.30 * safezoneW);
			y = (safezoneY + (0.20 * safezoneH)) + (0.05 * safezoneH);
			w = 0.40 * safezoneW;
			h = 0.004 * safezoneH;
			colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
			style = 0;
		};
		class spTitle: RscText {
			idc = 1590;
			text = "Select Role UI Style";
			x = safezoneX + (0.315 * safezoneW);
			y = safezoneY + (0.20 * safezoneH);
			w = 0.37 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_LEFT + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.4);
			shadow = 1;
		};

		// ---- Card 0: Original ----
		class sp0Border: RscText { idc = 1600; x = SP_BASEX; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp0Plate: RscText { idc = 1610; x = SP_BASEX + (0.002 * safezoneW); y = SP_BASEY + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp0Preview: RscPicture { idc = 1620; text = "ui\role.paa"; x = (SP_BASEX + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp0Label: RscText { idc = 1630; text = "Original"; x = SP_BASEX; y = SP_BASEY + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 1: Signal Ring ----
		class sp1Border: RscText { idc = 1601; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp1Plate: RscText { idc = 1611; x = SP_BASEX + SP_COLSTEP + (0.002 * safezoneW); y = SP_BASEY + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp1Preview: RscPicture { idc = 1621; text = "ui\role.paa"; x = (SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp1Label: RscText { idc = 1631; text = "Signal Ring"; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 2: Corner Bracket Frame ----
		class sp2Border: RscText { idc = 1602; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp2Plate: RscText { idc = 1612; x = SP_BASEX + (2 * SP_COLSTEP) + (0.002 * safezoneW); y = SP_BASEY + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp2Preview: RscPicture { idc = 1622; text = "ui\role.paa"; x = (SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp2Label: RscText { idc = 1632; text = "Corner Bracket"; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 3: Fused Tag ----
		class sp3Border: RscText { idc = 1603; x = SP_BASEX; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp3Plate: RscText { idc = 1613; x = SP_BASEX + (0.002 * safezoneW); y = SP_BASEY + SP_ROWSTEP + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp3Preview: RscPicture { idc = 1623; text = "ui\role.paa"; x = (SP_BASEX + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + SP_ROWSTEP + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp3Label: RscText { idc = 1633; text = "Fused Tag"; x = SP_BASEX; y = SP_BASEY + SP_ROWSTEP + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 4: Wallet Chip ----
		class sp4Border: RscText { idc = 1604; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp4Plate: RscText { idc = 1614; x = SP_BASEX + SP_COLSTEP + (0.002 * safezoneW); y = SP_BASEY + SP_ROWSTEP + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp4Preview: RscPicture { idc = 1624; text = "ui\role.paa"; x = (SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + SP_ROWSTEP + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp4Label: RscText { idc = 1634; text = "Wallet Chip"; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + SP_ROWSTEP + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 5: Satellite Chip ----
		class sp5Border: RscText { idc = 1605; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp5Plate: RscText { idc = 1615; x = SP_BASEX + (2 * SP_COLSTEP) + (0.002 * safezoneW); y = SP_BASEY + SP_ROWSTEP + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp5Preview: RscPicture { idc = 1625; text = "ui\role.paa"; x = (SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + SP_ROWSTEP + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp5Label: RscText { idc = 1635; text = "Satellite Chip"; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + SP_ROWSTEP + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 6: IFF Transponder ----
		class sp6Border: RscText { idc = 1606; x = SP_BASEX; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp6Plate: RscText { idc = 1616; x = SP_BASEX + (0.002 * safezoneW); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp6Preview: RscPicture { idc = 1626; text = "ui\role.paa"; x = (SP_BASEX + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp6Label: RscText { idc = 1636; text = "IFF Transponder"; x = SP_BASEX; y = SP_BASEY + (2 * SP_ROWSTEP) + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 7: Contact Blip ----
		class sp7Border: RscText { idc = 1607; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp7Plate: RscText { idc = 1617; x = SP_BASEX + SP_COLSTEP + (0.002 * safezoneW); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp7Preview: RscPicture { idc = 1627; text = "ui\role.paa"; x = (SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorText[] = {0.75,0.21,0.21,1}; };
		class sp7Label: RscText { idc = 1637; text = "Contact Blip"; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + (2 * SP_ROWSTEP) + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };

		// ---- Card 8: Stamped Tag - no oval texture, so its preview is a
		// flat square swatch (RscText) instead of an RscPicture, matching
		// what the style itself actually looks like in the corner HUD. ----
		class sp8Border: RscText { idc = 1608; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_CASING; style = 0; };
		class sp8Plate: RscText { idc = 1618; x = SP_BASEX + (2 * SP_COLSTEP) + (0.002 * safezoneW); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.002 * safezoneH); w = SP_CARDW - (0.004 * safezoneW); h = SP_CARDH - (0.004 * safezoneH); colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp8Preview: RscText { idc = 1628; x = (SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW)) - (0.026 * safezoneH); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.012 * safezoneH); w = 0.052 * safezoneH; h = 0.052 * safezoneH; colorBackground[] = {0.75,0.21,0.21,1}; style = 0; };
		class sp8Label: RscText { idc = 1638; text = "Stamped Tag"; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + (2 * SP_ROWSTEP) + (0.10 * safezoneH); w = SP_CARDW; h = 0.024 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.016 * safezoneH; shadow = 1; };
	};

	class Controls {
		// Click targets, declared LAST (after the whole controlsBackground
		// group) so they sit on top and actually receive the click - a
		// config-declared control earlier in z-order has been seen to eat
		// clicks meant for whatever's layered under it elsewhere in this
		// HUD (see the shopPurchSpacer comment above), so the interactive
		// layer has to be the one on top here, not the decoration.
		class sp0Btn: RscButton { idc = 1640; text = ""; x = SP_BASEX; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp1Btn: RscButton { idc = 1641; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp2Btn: RscButton { idc = 1642; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp3Btn: RscButton { idc = 1643; text = ""; x = SP_BASEX; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp4Btn: RscButton { idc = 1644; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp5Btn: RscButton { idc = 1645; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp6Btn: RscButton { idc = 1646; text = ""; x = SP_BASEX; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp7Btn: RscButton { idc = 1647; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class sp8Btn: RscButton { idc = 1648; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = {0,0,0,0}; colorBackgroundActive[] = {1,1,1,0.08}; colorBackgroundDisabled[] = {0,0,0,0}; colorText[] = {0,0,0,0}; };
		class spClose: RscButton {
			idc = 1599;
			text = "CLOSE [ESC]";
			x = safezoneX + (0.60 * safezoneW);
			y = (safezoneY + (0.20 * safezoneH)) + (0.53 * safezoneH);
			w = 0.10 * safezoneW;
			h = 0.04 * safezoneH;
			colorBackground[] = WALDO_BTN;
			colorBackgroundActive[] = WALDO_BTNACTIVE;
			colorText[] = {0.95,0.93,0.86,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			action = "closeDialog 1";
		};
	};
};
#undef SP_BASEX
#undef SP_BASEY
#undef SP_CARDW
#undef SP_CARDH
#undef SP_COLSTEP
#undef SP_ROWSTEP

// ============================================================================
// WaldoDebug - the dev / test menu (opened with '\' when Testing Mode is on).
// Buttons are generated at runtime from an action list by Waldo_fnc_debugMenu,
// so this shell never changes when a test tool is added or removed.
//   idc 3100 = title, 3101 = live game-state readout, 3102 = scrollable grid.
// ============================================================================
class WaldoDebug {
	idd = -1;
	fadeout = 0.15;
	fadein = 0.15;
	movingEnable = true;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do { WaldoDebug = _this select 0 }";

	class controlsBackground {
		class dbgDim: RscText {
			idc = -1;
			x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
			colorBackground[] = WALDO_DIM;
			style = 0;
		};
		class dbgShadow: RscText {
			idc = -1;
			x = (safezoneX + (0.28 * safezoneW)) - (0.006 * safezoneW);
			y = (safezoneY + (0.14 * safezoneH)) - (0.006 * safezoneH);
			w = (0.44 * safezoneW) + (0.012 * safezoneW);
			h = (0.72 * safezoneH) + (0.012 * safezoneH);
			colorBackground[] = WALDO_SHADOW;
			style = 0;
		};
		class dbgBG: RscText {
			idc = -1;
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH));
			w = 0.44 * safezoneW;
			h = 0.72 * safezoneH;
			colorBackground[] = WALDO_CASING;
			colorText[] = {0.95,0.93,0.86,1};
			style = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class dbgHeader: RscText {
			idc = -1;
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH));
			w = 0.44 * safezoneW;
			h = 0.06 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class dbgAccentBar: RscText {
			idc = -1;
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH)) + (0.06 * safezoneH);
			w = 0.44 * safezoneW;
			h = 0.006 * safezoneH;
			colorBackground[] = WALDO_ACCENT;
			style = 0;
		};
		class dbgTitle: RscText {
			idc = 3100;
			text = "Dev / Test Menu";
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH));
			w = 0.44 * safezoneW;
			h = 0.06 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_CENTER + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5);
		};
		class dbgStatus: RscStructuredText {
			idc = 3101;
			text = "";
			x = (safezoneX + (0.29 * safezoneW));
			y = (safezoneY + (0.205 * safezoneH));
			w = 0.42 * safezoneW;
			h = 0.14 * safezoneH;
			size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			class Attributes {
				font = "PuristaMedium";
				color = "#F2EFE3";
				align = "left";
				shadow = 1;
			};
		};
	};

	class Controls {
		class dbgGroup: RscControlsGroup {
			idc = 3102;
			x = (safezoneX + (0.29 * safezoneW));
			y = (safezoneY + (0.35 * safezoneH));
			w = 0.42 * safezoneW;
			h = 0.50 * safezoneH;
		};
	};
};

// ============================================================================
// WaldoScore - in-round scoreboard (toggled with K). A centred panel with a
// title and a scrollable list; rows are generated at runtime by
// Waldo_fnc_scoreboard.  3301 title, 3302 scroll group, 3300 list text.
// ============================================================================
class WaldoScore {
	idd = -1;
	fadeout = 0.15;
	fadein = 0.15;
	movingEnable = false;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do { WaldoScore = _this select 0 }";

	class controlsBackground {
		class scDim: RscText {
			idc = -1;
			x = safezoneX; y = safezoneY; w = safezoneW; h = safezoneH;
			colorBackground[] = WALDO_DIM;
			style = 0;
		};
		class scShadow: RscText {
			idc = -1;
			x = safezoneX + (0.25 * safezoneW) - (0.006 * safezoneW);
			y = safezoneY + (0.17 * safezoneH) - (0.006 * safezoneH);
			w = (0.50 * safezoneW) + (0.012 * safezoneW);
			h = (0.66 * safezoneH) + (0.012 * safezoneH);
			colorBackground[] = WALDO_SHADOW;
			style = 0;
		};
		class scBG: RscText {
			idc = -1;
			x = safezoneX + (0.25 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.50 * safezoneW;
			h = 0.66 * safezoneH;
			colorBackground[] = WALDO_CASING;
			style = 0;
		};
		class scTitleBar: RscText {
			idc = -1;
			x = safezoneX + (0.25 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.50 * safezoneW;
			h = 0.062 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class scAccentBar: RscText {
			idc = -1;
			x = safezoneX + (0.25 * safezoneW);
			y = safezoneY + (0.17 * safezoneH) + (0.062 * safezoneH);
			w = 0.50 * safezoneW;
			h = 0.006 * safezoneH;
			colorBackground[] = WALDO_ACCENT;
			style = 0;
		};
		class scTitle: RscText {
			idc = 3301;
			text = "Round Scoreboard";
			x = safezoneX + (0.25 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.50 * safezoneW;
			h = 0.062 * safezoneH;
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_CENTER + ST_VCENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.4);
			shadow = 1;
		};

		// Keybind reference panel, attached to the scoreboard's right edge (same
		// top/height, small gap after its 0.75W right edge). Populated at runtime
		// by Waldo_fnc_scoreboard from the same Waldo_keyHintsFor helper the top
		// bar uses, so both stay in sync with a single source of truth.
		class scKbShadow: RscText {
			idc = -1;
			x = (safezoneX + (0.756 * safezoneW)) - (0.006 * safezoneW);
			y = safezoneY + (0.17 * safezoneH) - (0.006 * safezoneW);
			w = (0.16 * safezoneW) + (0.012 * safezoneW);
			h = (0.66 * safezoneH) + (0.012 * safezoneW);
			colorBackground[] = WALDO_SHADOW;
			style = 0;
		};
		class scKbBG: RscText {
			idc = -1;
			x = safezoneX + (0.756 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.16 * safezoneW;
			h = 0.66 * safezoneH;
			colorBackground[] = WALDO_CASING;
			style = 0;
		};
		class scKbHeaderBG: RscText {
			idc = -1;
			x = safezoneX + (0.756 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.16 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = WALDO_HEADERBG;
			style = 0;
		};
		class scKbAccent: RscText {
			idc = -1;
			x = safezoneX + (0.756 * safezoneW);
			y = safezoneY + (0.17 * safezoneH) + (0.05 * safezoneH);
			w = 0.16 * safezoneW;
			h = 0.005 * safezoneH;
			colorBackground[] = WALDO_ACCENT;
			style = 0;
		};
		class scKbTitle: RscText {
			idc = -1;
			text = "Keybinds";
			x = safezoneX + (0.756 * safezoneW);
			y = safezoneY + (0.17 * safezoneH);
			w = 0.16 * safezoneW;
			h = 0.05 * safezoneH;
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_CENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.05);
			shadow = 1;
		};
		class scKbList: RscStructuredText {
			idc = 3320;
			text = "";
			x = safezoneX + (0.756 * safezoneW) + (0.010 * safezoneW);
			y = safezoneY + (0.17 * safezoneH) + (0.06 * safezoneH);
			w = (0.16 * safezoneW) - (0.020 * safezoneW);
			h = (0.66 * safezoneH) - (0.07 * safezoneH);
			size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
			class Attributes {
				font = "PuristaMedium";
				color = "#D8D5C8";
				align = "left";
				shadow = 1;
			};
		};
	};

	class Controls {
		class scGroup: RscControlsGroup {
			idc = 3302;
			x = safezoneX + (0.26 * safezoneW);
			y = safezoneY + (0.245 * safezoneH);
			w = 0.48 * safezoneW;
			h = 0.52 * safezoneH;

			class Controls {
				class scList: RscStructuredText {
					idc = 3300;
					text = "";
					x = 0;
					y = 0;
					w = 0.46 * safezoneW;
					h = 3.0 * safezoneH;   // tall so the group scrolls for big lobbies
					size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
					class Attributes {
						font = "PuristaMedium";
						color = "#F2EFE3";
						align = "left";
						shadow = 1;
					};
				};
			};
		};
		class scClose: RscButton {
			idc = 2;
			text = "CLOSE [K]";
			x = safezoneX + (0.64 * safezoneW);
			y = safezoneY + (0.785 * safezoneH);
			w = 0.10 * safezoneW;
			h = 0.038 * safezoneH;
			colorBackground[] = WALDO_BTN;
			colorBackgroundActive[] = WALDO_BTNACTIVE;
			colorText[] = {0.95,0.93,0.86,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			action = "closeDialog 1";
		};
	};
};
