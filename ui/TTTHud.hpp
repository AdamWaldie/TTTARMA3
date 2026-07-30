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

			// The old "Rank Disc" shared backing (rankDiscRim/rankDiscAccent,
			// idc 1270/1271) is gone. It existed because styles 1-7 had no
			// material of their own - they were decorations hung off style 0's
			// badge ring, so they needed something behind that ring to make
			// them read as a crest rather than as loose marks. Every one of
			// them now owns its own shadow/border/plate (see the block further
			// down), so a shared backing has nothing left to back, and keeping
			// it would just double up a second rim behind each style's own.
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
			// The white "face" showing through the ring's hole. Was briefly
			// retired while style 0 borrowed another style's look; it's back
			// and shown for style 0 only, along with the rest of the ring,
			// because style 0 is the untouched original and this disc is part
			// of that original. No other style shows it - they all replace the
			// ring outright rather than decorating it.
			class roleTextBGBG: RscPicture
			{
				idc = 999;
				text = "ui\rolebg.paa";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.185 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				// Raised from 0.5. At 0.5 this disc was half-transparent, so what
				// sat behind the role letter was whatever terrain happened to be
				// there - near-invisible against bright ground, a grey smudge
				// against dark. The medallion never read as a solid object and the
				// letter's legibility changed shot to shot. At 0.72 it's a
				// consistent pale face on any background, which is also closer to
				// the solid disc of the GMod-TTT badge this is an homage to - so it
				// reads as more like the original reference, not less.
				color = [1,1,1,0.72];
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
				// Was false. This is the only text control in the whole HUD without
				// a shadow, and it's the largest one - the role letter sits over a
				// pale disc whose own brightness varies with the terrain behind it,
				// so an unshadowed glyph had nothing holding its edge. Every other
				// label here already uses shadow = 1.
				shadow = 1;
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
			// The one piece of amber on Original. Every other style carries a fixed
			// amber mark as the thread that ties the crest family together, and
			// Original had none - it was the odd one out on a shelf of nine. A
			// hairline along the pill's top edge is the smallest thing that joins
			// it to the rest: it doubles as the top bevel every other panel in this
			// HUD already has (see s8Highlight), it doesn't touch the silhouette,
			// and it leaves the role-tinted accent line at the pill's bottom - the
			// part that actually carries Original's identity - exactly as it was.
			// Part of the credits group, so it hides with the pill for roles that
			// have no credits rather than leaving a stray line under the badge.
			class roleCreditsHighlight: RscText
			{
				idc = 1006;
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.225 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.0025 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // fixed amber, never role-tinted
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
				// Was pure white, the only pure-white text anywhere in this HUD -
				// next to the cream every other label uses it read colder and
				// cheaper than its surroundings. Same cream now. Deliberately still
				// not role-tinted (see fn_initHud.sqf's note on why).
				colorText[] = {0.95, 0.93, 0.86, 1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.021 * safezoneH;
				shadow = 1;
			};

			// ====================================================================
			// Role crest styles 1-7. Style 0 above is the original GMod-TTT homage
			// and stays structurally as it always was - it has had a light polish
			// pass (each change is commented at the control it touches) but its
			// medallion-plus-pill composition is not up for redesign.
			//
			// Everything from here down is a deliberate break from how styles 1-7
			// used to work. They were decorations pinned around style 0's badge
			// ring, which meant seven variations on one silhouette; the direction
			// was that each style needs its own thematic approach and styling, so
			// each one below is now a self-contained crest with its own footprint,
			// composition and idea. None of them touch the ring (idc 999/1000/
			// 1001/1272) at all - Waldo_fnc_initHud hides it for every style but 0.
			//
			// The shared visual family is Style 8 (Stamped Tag)'s recipe, which is
			// the one that landed: a black drop shadow, a role-coloured border, a
			// near-black casing plate, amber (WALDO_ACCENT) as the fixed accent on
			// top of it, and the role letter role-tinted over the plate. Amber
			// marks are NEVER role-tinted - they are the constant thread that ties
			// all eight styles together, and the role colour is what varies.
			//
			// Flat RscText rects only, no RscPicture. Two separate attempts at
			// texture-based tinting for new crest elements (reusing ui\rolebg.paa,
			// then two dedicated freshly-generated .paa files) both failed to
			// apply their tint in-game, confirmed live via screenshots. Flat
			// colorBackground[] is the one technique that has rendered correctly
			// with zero exceptions anywhere in this file.
			//
			// Credits handling, per the direction that credit displays must either
			// be worked into the design or omitted without notice: every style's
			// balance is a transparent-background text control sitting over its own
			// plate, in a band the plate already fills. Jester/Innocent have no
			// credits, so Waldo_fnc_initHud simply hides that one control and the
			// plate underneath is plain - there is no bordered sub-panel or inset
			// pocket anywhere that could leave a visible hole. The two styles whose
			// composition genuinely reserves space for the balance (1's right cell,
			// 2's lower half) put their amber divider/rule in the credits group too
			// and have their letter re-centred over the full plate in script, so
			// they collapse cleanly rather than sitting half-empty.
			//
			// Every rect below was checked against the screen edge before being
			// written: with the anchor at RX/RY, no control may extend past
			// RX + 0.175*safezoneH or RY + 0.185*safezoneH. That check caught real
			// overflows in styles 5 and 6 while these were being laid out.
			// ====================================================================
#define RX ((safezoneW + safezoneX) - (0.175 * safezoneH))
#define RY ((safezoneH + safezoneY) - (0.185 * safezoneH))
			// Fully opaque and a touch darker than WALDO_CASING: that macro's 0.96
			// alpha let bright terrain bleed through and read as a warm brown
			// instead of a dark plate. Same value style 8's plate settled on.
#define CREST_PLATE {0.07, 0.075, 0.065, 1}
// Same value, two names on purpose. ROLE_LETTER is only a placeholder - every
// letter gets ctrlSetTextColor'd to the role colour on each redraw, so what's
// declared here never actually shows. CREAM is the real, final colour of the
// balance text and is deliberately never role-tinted: every role colour is dark
// and saturated, and these all sit on a near-black plate, so role-tinted credit
// text was low-contrast on every style (worst on Traitor red).
#define ROLE_LETTER {0.95, 0.93, 0.86, 1}
#define CREAM {0.95, 0.93, 0.86, 1}

			// ---- Style 1: Rank Bar - a landscape shoulder-slide. Letter in its own
			// left cell, an amber divider, then the balance in the wide right
			// cell. The divider belongs to the credits group, so a role with no
			// credits gets a plain lettered bar and the letter is re-centred
			// across the whole plate in script - no empty right half. ----
			class s1Shadow: RscText { idc = 1300; x = RX - (0.039 * safezoneH); y = RY + (0.085 * safezoneH); w = 0.208 * safezoneH; h = 0.094 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s1Border: RscText { idc = 1301; x = RX - (0.041 * safezoneH); y = RY + (0.083 * safezoneH); w = 0.212 * safezoneH; h = 0.098 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s1Plate: RscText { idc = 1302; x = RX - (0.035 * safezoneH); y = RY + (0.089 * safezoneH); w = 0.2 * safezoneH; h = 0.086 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s1Letter: RscText { idc = 1303; text = ""; x = RX - (0.035 * safezoneH); y = RY + (0.089 * safezoneH); w = 0.08 * safezoneH; h = 0.086 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.062 * safezoneH; shadow = false; };
			class s1Divider: RscText { idc = 1304; x = RX + (0.045 * safezoneH); y = RY + (0.097 * safezoneH); w = 0.003 * safezoneH; h = 0.07 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s1Credits: RscText { idc = 1305; text = ""; x = RX + (0.054 * safezoneH); y = RY + (0.089 * safezoneH); w = 0.111 * safezoneH; h = 0.086 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.024 * safezoneH; shadow = 1; };

			// ---- Style 2: Stencil Column - a narrow vertical crate stencil. Letter
			// stacked over an amber rule with the balance beneath it. Rule is in
			// the credits group; with no credits the letter re-centres over the
			// full column height in script. ----
			class s2Shadow: RscText { idc = 1310; x = RX + (0.071 * safezoneH); y = RY + (0.018 * safezoneH); w = 0.098 * safezoneH; h = 0.158 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s2Border: RscText { idc = 1311; x = RX + (0.069 * safezoneH); y = RY + (0.016 * safezoneH); w = 0.102 * safezoneH; h = 0.162 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s2Plate: RscText { idc = 1312; x = RX + (0.075 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.09 * safezoneH; h = 0.15 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s2Letter: RscText { idc = 1313; text = ""; x = RX + (0.075 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.09 * safezoneH; h = 0.1 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.062 * safezoneH; shadow = false; };
			class s2Rule: RscText { idc = 1314; x = RX + (0.083 * safezoneH); y = RY + (0.122 * safezoneH); w = 0.074 * safezoneH; h = 0.003 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s2Credits: RscText { idc = 1315; text = ""; x = RX + (0.075 * safezoneH); y = RY + (0.132 * safezoneH); w = 0.09 * safezoneH; h = 0.028 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.02 * safezoneH; shadow = 1; };

			// ---- Style 3: Service Pips - a rank-insignia plate. Three amber pips
			// stepping out of the bottom-right corner, always shown (they read as
			// insignia, not as data), with the balance tucked into the opposite
			// bottom-left corner as bare text over the plate - nothing to leave a
			// hole behind when a role has no credits. ----
			class s3Shadow: RscText { idc = 1320; x = RX + (0.011 * safezoneH); y = RY + (0.018 * safezoneH); w = 0.158 * safezoneH; h = 0.158 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s3Border: RscText { idc = 1321; x = RX + (0.009 * safezoneH); y = RY + (0.016 * safezoneH); w = 0.162 * safezoneH; h = 0.162 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s3Plate: RscText { idc = 1322; x = RX + (0.015 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.15 * safezoneH; h = 0.15 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s3Pip1: RscText { idc = 1324; x = RX + (0.123 * safezoneH); y = RY + (0.158 * safezoneH); w = 0.032 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s3Pip2: RscText { idc = 1325; x = RX + (0.131 * safezoneH); y = RY + (0.148 * safezoneH); w = 0.024 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s3Pip3: RscText { idc = 1326; x = RX + (0.139 * safezoneH); y = RY + (0.138 * safezoneH); w = 0.016 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s3Letter: RscText { idc = 1323; text = ""; x = RX + (0.015 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.15 * safezoneH; h = 0.15 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.09 * safezoneH; shadow = false; };
			class s3Credits: RscText { idc = 1327; text = ""; x = RX + (0.025 * safezoneH); y = RY + (0.14 * safezoneH); w = 0.07 * safezoneH; h = 0.022 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.019 * safezoneH; shadow = 1; };

			// ---- Style 4: Punch Card - a records-office tab. A row of five amber
			// punch marks along the top edge (the closest flat rects get to a
			// perforated card), letter below them, balance stamped along the
			// bottom as bare text over the plate. ----
			class s4Shadow: RscText { idc = 1330; x = RX + (0.011 * safezoneH); y = RY + (0.018 * safezoneH); w = 0.158 * safezoneH; h = 0.158 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s4Border: RscText { idc = 1331; x = RX + (0.009 * safezoneH); y = RY + (0.016 * safezoneH); w = 0.162 * safezoneH; h = 0.162 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s4Plate: RscText { idc = 1332; x = RX + (0.015 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.15 * safezoneH; h = 0.15 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s4Punch1: RscText { idc = 1334; x = RX + (0.04 * safezoneH); y = RY + (0.031 * safezoneH); w = 0.012 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s4Punch2: RscText { idc = 1335; x = RX + (0.062 * safezoneH); y = RY + (0.031 * safezoneH); w = 0.012 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s4Punch3: RscText { idc = 1336; x = RX + (0.084 * safezoneH); y = RY + (0.031 * safezoneH); w = 0.012 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s4Punch4: RscText { idc = 1337; x = RX + (0.106 * safezoneH); y = RY + (0.031 * safezoneH); w = 0.012 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s4Punch5: RscText { idc = 1338; x = RX + (0.128 * safezoneH); y = RY + (0.031 * safezoneH); w = 0.012 * safezoneH; h = 0.012 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s4Letter: RscText { idc = 1333; text = ""; x = RX + (0.015 * safezoneH); y = RY + (0.032 * safezoneH); w = 0.15 * safezoneH; h = 0.14 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.09 * safezoneH; shadow = false; };
			class s4Credits: RscText { idc = 1339; text = ""; x = RX + (0.015 * safezoneH); y = RY + (0.144 * safezoneH); w = 0.15 * safezoneH; h = 0.02 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.019 * safezoneH; shadow = 1; };

			// ---- Style 5: Bracket Sight - Arma's own target-marking convention. Four
			// amber L-arms floating clear of the plate's border, so the crest
			// reads as something the player has locked onto. Balance sits inside
			// the plate's lower band as bare text. ----
			class s5Shadow: RscText { idc = 1340; x = RX + (0.013 * safezoneH); y = RY + (0.023 * safezoneH); w = 0.148 * safezoneH; h = 0.148 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s5Border: RscText { idc = 1341; x = RX + (0.011 * safezoneH); y = RY + (0.021 * safezoneH); w = 0.152 * safezoneH; h = 0.152 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s5Plate: RscText { idc = 1342; x = RX + (0.017 * safezoneH); y = RY + (0.027 * safezoneH); w = 0.14 * safezoneH; h = 0.14 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s5ArmTLh: RscText { idc = 1344; x = RX + (0.003 * safezoneH); y = RY + (0.013 * safezoneH); w = 0.026 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmTLv: RscText { idc = 1345; x = RX + (0.003 * safezoneH); y = RY + (0.013 * safezoneH); w = 0.004 * safezoneH; h = 0.026 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmTRh: RscText { idc = 1346; x = RX + (0.145 * safezoneH); y = RY + (0.013 * safezoneH); w = 0.026 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmTRv: RscText { idc = 1347; x = RX + (0.167 * safezoneH); y = RY + (0.013 * safezoneH); w = 0.004 * safezoneH; h = 0.026 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmBLh: RscText { idc = 1348; x = RX + (0.003 * safezoneH); y = RY + (0.177 * safezoneH); w = 0.026 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmBLv: RscText { idc = 1349; x = RX + (0.003 * safezoneH); y = RY + (0.155 * safezoneH); w = 0.004 * safezoneH; h = 0.026 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmBRh: RscText { idc = 1350; x = RX + (0.145 * safezoneH); y = RY + (0.177 * safezoneH); w = 0.026 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5ArmBRv: RscText { idc = 1351; x = RX + (0.167 * safezoneH); y = RY + (0.155 * safezoneH); w = 0.004 * safezoneH; h = 0.026 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s5Letter: RscText { idc = 1343; text = ""; x = RX + (0.017 * safezoneH); y = RY + (0.027 * safezoneH); w = 0.14 * safezoneH; h = 0.14 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.088 * safezoneH; shadow = false; };
			class s5Credits: RscText { idc = 1352; text = ""; x = RX + (0.017 * safezoneH); y = RY + (0.139 * safezoneH); w = 0.14 * safezoneH; h = 0.02 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.019 * safezoneH; shadow = 1; };

			// ---- Style 6: Layered Chip - two plates offset like stacked casino chips,
			// the role colour showing as the one underneath rather than as a
			// border around the front one. An amber bevel line catches the front
			// plate's top edge; balance sits in its lower band. ----
			class s6Shadow: RscText { idc = 1360; x = RX + (0.01 * safezoneH); y = RY + (0.02 * safezoneH); w = 0.163 * safezoneH; h = 0.163 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s6BackPlate: RscText { idc = 1361; x = RX + (0.024 * safezoneH); y = RY + (0.034 * safezoneH); w = 0.145 * safezoneH; h = 0.145 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s6FrontPlate: RscText { idc = 1362; x = RX + (0.014 * safezoneH); y = RY + (0.024 * safezoneH); w = 0.145 * safezoneH; h = 0.145 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s6Bevel: RscText { idc = 1363; x = RX + (0.014 * safezoneH); y = RY + (0.024 * safezoneH); w = 0.145 * safezoneH; h = 0.003 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s6Letter: RscText { idc = 1364; text = ""; x = RX + (0.014 * safezoneH); y = RY + (0.024 * safezoneH); w = 0.145 * safezoneH; h = 0.145 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.09 * safezoneH; shadow = false; };
			class s6Credits: RscText { idc = 1365; text = ""; x = RX + (0.014 * safezoneH); y = RY + (0.142 * safezoneH); w = 0.145 * safezoneH; h = 0.02 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.019 * safezoneH; shadow = 1; };

			// ---- Style 7: Ledger Slip - a bookkeeper's margin. An amber rule down the
			// left with faint ruled lines across the plate (declared before the
			// letter so it writes over them), the letter set in the body column,
			// and the balance on the last ruled line. ----
			class s7Shadow: RscText { idc = 1370; x = RX + (0.011 * safezoneH); y = RY + (0.018 * safezoneH); w = 0.158 * safezoneH; h = 0.158 * safezoneH; colorBackground[] = WALDO_SHADOW; style = 0; };
			class s7Border: RscText { idc = 1371; x = RX + (0.009 * safezoneH); y = RY + (0.016 * safezoneH); w = 0.162 * safezoneH; h = 0.162 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
			class s7Plate: RscText { idc = 1372; x = RX + (0.015 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.15 * safezoneH; h = 0.15 * safezoneH; colorBackground[] = CREST_PLATE; style = 0; };
			class s7Rule: RscText { idc = 1373; x = RX + (0.045 * safezoneH); y = RY + (0.028 * safezoneH); w = 0.003 * safezoneH; h = 0.138 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
			class s7Line1: RscText { idc = 1374; x = RX + (0.051 * safezoneH); y = RY + (0.074 * safezoneH); w = 0.108 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = {0.95, 0.93, 0.86, 0.16}; style = 0; };
			class s7Line2: RscText { idc = 1375; x = RX + (0.051 * safezoneH); y = RY + (0.122 * safezoneH); w = 0.108 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = {0.95, 0.93, 0.86, 0.16}; style = 0; };
			class s7Letter: RscText { idc = 1376; text = ""; x = RX + (0.051 * safezoneH); y = RY + (0.022 * safezoneH); w = 0.108 * safezoneH; h = 0.13 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = ROLE_LETTER; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.088 * safezoneH; shadow = false; };
			class s7Credits: RscText { idc = 1377; text = ""; x = RX + (0.051 * safezoneH); y = RY + (0.144 * safezoneH); w = 0.108 * safezoneH; h = 0.02 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = CREAM; style = ST_CENTER; font = "PuristaMedium"; sizeEx = 0.019 * safezoneH; shadow = 1; };

#undef RX
#undef RY
#undef CREST_PLATE
#undef ROLE_LETTER
#undef CREAM

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
			// Reverted back to its original 0.17H/0.194H proportions - the
			// attempt to match the Rank Disc's exact 0.19H footprint made
			// the border margin overwhelming ("too fat, too chonky"), losing
			// the clean, mostly-plate look this had before. Kept the two
			// worthwhile fixes from that pass: the fully-opaque darker
			// plate (was WALDO_CASING's 0.96 alpha, which let terrain bleed
			// through and read as brown instead of dark casing) and the
			// unified 0.098H letter size matching styles 1-7.
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
			// Fully opaque, not WALDO_CASING's 0.96 alpha - that 4% let
			// bright terrain bleed through and read as a warm brown
			// instead of a dark casing plate. A touch darker than the
			// macro too, for contrast against the (also opaque) role-tinted
			// border around it.
			class s8Plate: RscText {
				idc = 1282;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.194 * safezoneH;
				colorBackground[] = {0.07, 0.075, 0.065, 1};
				style = 0;
			};
			// Thin lighter edge along the plate's top, catching light like a
			// stamped-metal bevel - the closest a flat RscText rect can get
			// to the diagonal highlight in the concept mockup without new
			// art. Declared after the plate so it sits on top.
			class s8Highlight: RscText {
				idc = 1287;
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) - (0.02 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) - (0.044 * safezoneH);
				w = 0.17 * safezoneH;
				h = 0.003 * safezoneH;
				colorBackground[] = {0.32, 0.33, 0.28, 0.55};
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
			// Same 0.098H letter size as styles 1-7 for scale consistency,
			// but its own box (0.17H, matching the plate) rather than the
			// ring's 0.15H - the plate is deliberately a bit bigger than
			// the ring, same as it always was.
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
				sizeEx = 0.098 * safezoneH;
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
				sizeEx = 0.018 * safezoneH;
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
// grid of named cards (one per Style 0-8), the selected one highlighted by
// filling its own background with the player's role colour, so the player
// knows what they currently have without tabbing blind. Deliberately a
// single RscText per card (background colour + text together), not layered
// border+plate+label controls - an earlier layered version consistently
// rendered as blank boxes with no visible text in practice, and this is the
// simplest structure that removes any z-order dependency between sibling
// controls as a possible cause. Same shadow/casing/header/accent-stripe
// recipe as WaldoShop/WaldoScore. Card layout is declared, not generated,
// because hpp has no loops - the shared base coordinates are local
// #defines, undef'd right after this class so they don't leak into
// anything declared later in the file.
// ============================================================================
#define SP_BASEX (safezoneX + (0.325 * safezoneW))
#define SP_BASEY (safezoneY + (0.28 * safezoneH))
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
		// ST_LEFT alone, NOT "+ ST_VCENTER" - the exact combo already
		// confirmed to render fully blank elsewhere in this file (see the
		// long comment above roleText/s3RoleName). Real vertical centring
		// is done in script instead (Waldo_fnc_openStylePicker), same
		// ctrlTextHeight technique. Full header width now that the
		// accessibility toggle moved to the bottom-left corner instead of
		// sharing this row.
		class spTitle: RscText {
			idc = 1590;
			text = "Select Role UI Style";
			x = safezoneX + (0.32 * safezoneW);
			y = safezoneY + (0.20 * safezoneH);
			w = 0.36 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.95,0.93,0.86,1};
			style = ST_LEFT;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.4);
			shadow = 1;
		};

		// Card previews, rebuilt. They were removed entirely at one point
		// because they relied on RscPicture textures that never rendered
		// reliably at card size - the cards have been label-only ever since,
		// which made nine differently-named styles look identical until you
		// picked one. Everything is a flat RscText rect now, the one technique
		// that has never failed in this file.
		//
		// Each preview is a schematic, not a literal scale-down: the real amber
		// marks are 0.002-0.004 of safezoneH and would land on a fraction of a
		// pixel at this size. Each card keeps its style's silhouette (landscape
		// bar, narrow column, square, offset pair) and its one signature mark,
		// which is what actually tells the styles apart.
		//
		// Only the role-coloured rect in each preview carries an idc - the amber
		// and plate rects never change, so they cost nothing to leave static.
		//
		// The card itself is now a plain background with no text of its own, and
		// the label is a separate control in a band at the card's foot. It used
		// to be one control doing both jobs, which meant the script's vertical
		// centring pass shrank the card's background down to the height of its
		// own text - so the "card" was really a thin strip and the selected
		// style's highlight was a thin band rather than a filled card. Selection
		// is an amber frame behind the card instead of a role-coloured fill,
		// because the previews now carry the role colour themselves and a
		// role-filled card would swallow them.
		// ---- 0: Original ----
		class sp0Select: RscText { idc = 1630; x = (SP_BASEX) - (0.003 * safezoneH); y = (SP_BASEY) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp0Card: RscText { idc = 1600; text = ""; x = SP_BASEX; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp0Pv1: RscText { idc = 1660; x = SP_BASEX + (0.5 * SP_CARDW) - (0.017 * safezoneH); y = (SP_BASEY) + (0.012 * safezoneH); w = 0.034 * safezoneH; h = 0.034 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp0Pv2: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.011 * safezoneH); y = (SP_BASEY) + (0.018 * safezoneH); w = 0.022 * safezoneH; h = 0.022 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp0Pv3: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.0375 * safezoneH); y = (SP_BASEY) + (0.054 * safezoneH); w = 0.075 * safezoneH; h = 0.01 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp0Pv4: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.0375 * safezoneH); y = (SP_BASEY) + (0.054 * safezoneH); w = 0.075 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp0Pv5: RscText { idc = 1669; x = SP_BASEX + (0.5 * SP_CARDW) - (0.0375 * safezoneH); y = (SP_BASEY) + (0.0625 * safezoneH); w = 0.075 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp0Label: RscText { idc = 1620; text = "Original"; x = SP_BASEX; y = (SP_BASEY) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 1: Rank Bar ----
		class sp1Select: RscText { idc = 1631; x = (SP_BASEX + SP_COLSTEP) - (0.003 * safezoneH); y = (SP_BASEY) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp1Card: RscText { idc = 1601; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp1Pv1: RscText { idc = 1661; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0375 * safezoneH); y = (SP_BASEY) + (0.028 * safezoneH); w = 0.075 * safezoneH; h = 0.026 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp1Pv2: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0355 * safezoneH); y = (SP_BASEY) + (0.03 * safezoneH); w = 0.071 * safezoneH; h = 0.022 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp1Pv3: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0095 * safezoneH); y = (SP_BASEY) + (0.033 * safezoneH); w = 0.002 * safezoneH; h = 0.016 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp1Label: RscText { idc = 1621; text = "Rank Bar"; x = SP_BASEX + SP_COLSTEP; y = (SP_BASEY) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 2: Stencil Column ----
		class sp2Select: RscText { idc = 1632; x = (SP_BASEX + (2 * SP_COLSTEP)) - (0.003 * safezoneH); y = (SP_BASEY) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp2Card: RscText { idc = 1602; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp2Pv1: RscText { idc = 1662; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.013 * safezoneH); y = (SP_BASEY) + (0.012 * safezoneH); w = 0.026 * safezoneH; h = 0.058 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp2Pv2: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.011 * safezoneH); y = (SP_BASEY) + (0.014 * safezoneH); w = 0.022 * safezoneH; h = 0.054 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp2Pv3: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.008 * safezoneH); y = (SP_BASEY) + (0.048 * safezoneH); w = 0.016 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp2Label: RscText { idc = 1622; text = "Stencil Column"; x = SP_BASEX + (2 * SP_COLSTEP); y = (SP_BASEY) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 3: Service Pips ----
		class sp3Select: RscText { idc = 1633; x = (SP_BASEX) - (0.003 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp3Card: RscText { idc = 1603; text = ""; x = SP_BASEX; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp3Pv1: RscText { idc = 1663; x = SP_BASEX + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.044 * safezoneH; h = 0.044 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp3Pv2: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.02 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.021 * safezoneH); w = 0.04 * safezoneH; h = 0.04 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp3Pv3: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) + (0.006 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.0555 * safezoneH); w = 0.012 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp3Pv4: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) + (0.009 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.0515 * safezoneH); w = 0.009 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp3Pv5: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) + (0.012 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.0475 * safezoneH); w = 0.006 * safezoneH; h = 0.002 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp3Label: RscText { idc = 1623; text = "Service Pips"; x = SP_BASEX; y = (SP_BASEY + SP_ROWSTEP) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 4: Punch Card ----
		class sp4Select: RscText { idc = 1634; x = (SP_BASEX + SP_COLSTEP) - (0.003 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Card: RscText { idc = 1604; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp4Pv1: RscText { idc = 1664; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.044 * safezoneH; h = 0.044 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp4Pv2: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.02 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.021 * safezoneH); w = 0.04 * safezoneH; h = 0.04 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp4Pv3: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.016 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.024 * safezoneH); w = 0.004 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Pv4: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0092 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.024 * safezoneH); w = 0.004 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Pv5: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0024 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.024 * safezoneH); w = 0.004 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Pv6: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) + (0.0044 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.024 * safezoneH); w = 0.004 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Pv7: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) + (0.0112 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.024 * safezoneH); w = 0.004 * safezoneH; h = 0.004 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp4Label: RscText { idc = 1624; text = "Punch Card"; x = SP_BASEX + SP_COLSTEP; y = (SP_BASEY + SP_ROWSTEP) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 5: Bracket Sight ----
		class sp5Select: RscText { idc = 1635; x = (SP_BASEX + (2 * SP_COLSTEP)) - (0.003 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Card: RscText { idc = 1605; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + SP_ROWSTEP; w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp5Pv1: RscText { idc = 1665; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.018 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.023 * safezoneH); w = 0.036 * safezoneH; h = 0.036 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp5Pv2: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.016 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.025 * safezoneH); w = 0.032 * safezoneH; h = 0.032 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp5Pv3: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.008 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv4: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.0015 * safezoneH; h = 0.008 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv5: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) + (0.014 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.008 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv6: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) + (0.0205 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.019 * safezoneH); w = 0.0015 * safezoneH; h = 0.008 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv7: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.0615 * safezoneH); w = 0.008 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv8: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.055 * safezoneH); w = 0.0015 * safezoneH; h = 0.008 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv9: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) + (0.014 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.0615 * safezoneH); w = 0.008 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Pv10: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) + (0.0205 * safezoneH); y = (SP_BASEY + SP_ROWSTEP) + (0.055 * safezoneH); w = 0.0015 * safezoneH; h = 0.008 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp5Label: RscText { idc = 1625; text = "Bracket Sight"; x = SP_BASEX + (2 * SP_COLSTEP); y = (SP_BASEY + SP_ROWSTEP) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 6: Layered Chip ----
		class sp6Select: RscText { idc = 1636; x = (SP_BASEX) - (0.003 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp6Card: RscText { idc = 1606; text = ""; x = SP_BASEX; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp6Pv1: RscText { idc = 1666; x = SP_BASEX + (0.5 * SP_CARDW) - (0.015 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.026 * safezoneH); w = 0.038 * safezoneH; h = 0.038 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp6Pv2: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.021 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.02 * safezoneH); w = 0.038 * safezoneH; h = 0.038 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp6Pv3: RscText { idc = -1; x = SP_BASEX + (0.5 * SP_CARDW) - (0.021 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.02 * safezoneH); w = 0.038 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp6Label: RscText { idc = 1626; text = "Layered Chip"; x = SP_BASEX; y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 7: Ledger Slip ----
		class sp7Select: RscText { idc = 1637; x = (SP_BASEX + SP_COLSTEP) - (0.003 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp7Card: RscText { idc = 1607; text = ""; x = SP_BASEX + SP_COLSTEP; y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp7Pv1: RscText { idc = 1667; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.022 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.019 * safezoneH); w = 0.044 * safezoneH; h = 0.044 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp7Pv2: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.02 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.021 * safezoneH); w = 0.04 * safezoneH; h = 0.04 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp7Pv3: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.013 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.023 * safezoneH); w = 0.0015 * safezoneH; h = 0.036 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp7Pv4: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0095 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.034 * safezoneH); w = 0.024 * safezoneH; h = 0.001 * safezoneH; colorBackground[] = {0.95, 0.93, 0.86, 0.16}; style = 0; };
		class sp7Pv5: RscText { idc = -1; x = SP_BASEX + SP_COLSTEP + (0.5 * SP_CARDW) - (0.0095 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.046 * safezoneH); w = 0.024 * safezoneH; h = 0.001 * safezoneH; colorBackground[] = {0.95, 0.93, 0.86, 0.16}; style = 0; };
		class sp7Label: RscText { idc = 1627; text = "Ledger Slip"; x = SP_BASEX + SP_COLSTEP; y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };

		// ---- 8: Stamped Tag ----
		class sp8Select: RscText { idc = 1638; x = (SP_BASEX + (2 * SP_COLSTEP)) - (0.003 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) - (0.003 * safezoneH); w = SP_CARDW + (0.006 * safezoneH); h = SP_CARDH + (0.006 * safezoneH); colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp8Card: RscText { idc = 1608; text = ""; x = SP_BASEX + (2 * SP_COLSTEP); y = SP_BASEY + (2 * SP_ROWSTEP); w = SP_CARDW; h = SP_CARDH; colorBackground[] = WALDO_HEADERBG; style = 0; };
		class sp8Pv1: RscText { idc = 1668; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.018 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.019 * safezoneH); w = 0.036 * safezoneH; h = 0.044 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };   // tinted to the role colour at runtime
		class sp8Pv2: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.016 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.021 * safezoneH); w = 0.032 * safezoneH; h = 0.04 * safezoneH; colorBackground[] = {0.07, 0.075, 0.065, 1}; style = 0; };
		class sp8Pv3: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) - (0.016 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.056 * safezoneH); w = 0.032 * safezoneH; h = 0.0015 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp8Pv4: RscText { idc = -1; x = SP_BASEX + (2 * SP_COLSTEP) + (0.5 * SP_CARDW) + (0.009 * safezoneH); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.021 * safezoneH); w = 0.007 * safezoneH; h = 0.007 * safezoneH; colorBackground[] = WALDO_ACCENT; style = 0; };
		class sp8Label: RscText { idc = 1628; text = "Stamped Tag"; x = SP_BASEX + (2 * SP_COLSTEP); y = (SP_BASEY + (2 * SP_ROWSTEP)) + (0.088 * safezoneH); w = SP_CARDW; h = 0.03 * safezoneH; colorBackground[] = {0,0,0,0}; colorText[] = {0.95,0.93,0.86,1}; style = ST_CENTER; font = "PuristaBold"; sizeEx = 0.019 * safezoneH; shadow = 1; };
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
		// Colourblind-safe palette toggle - Waldo_accessibilityMode in
		// profileNamespace, read by Waldo_roleColor itself (fn_initShops.sqf),
		// so this one toggle covers every caller of that function (HUD, buy
		// menu, top bar icons, radar, ping wheel) without needing its own
		// per-system switch. Text/state set in script on open and on click.
		// Bottom-left corner, clear of the card grid above it.
		class spAccessToggle: RscButton {
			idc = 1592;
			text = "";
			x = safezoneX + (0.325 * safezoneW);
			y = safezoneY + (0.72 * safezoneH);
			w = 0.15 * safezoneW;
			h = 0.04 * safezoneH;
			colorBackground[] = WALDO_BTN;
			colorBackgroundActive[] = WALDO_BTNACTIVE;
			colorText[] = {0.95,0.93,0.86,1};
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
		};
		class spClose: RscButton {
			idc = 1599;
			text = "CLOSE [ESC]";
			x = safezoneX + (0.575 * safezoneW);
			y = safezoneY + (0.72 * safezoneH);
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
