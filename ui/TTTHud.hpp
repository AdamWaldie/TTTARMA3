class RscTitles
{
	class default {
		idd = -3;
		fadeout=0;
		fadein=0;
		duration = 99999;
		onLoad = "";
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
			// Drop shadow behind the whole crest, same offset-dark-copy treatment the
			// shop/debug panels use, so this reads as a mounted badge instead of a
			// flat sticker floating over the world.
			class roleShadow: RscPicture
			{
				idc = -1;
				text = "ui\rolebg.paa";
				x = ((safezoneW + safezoneX) - (0.175 * safezoneH)) + (0.008 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.185 * safezoneH)) + (0.010 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				color = [0,0,0,0.55];
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
			class roleText: RscStructuredText
			{
				idc = 1001;
				text = "";
				x = (safezoneW + safezoneX) - (0.175 * safezoneH);
				y = (safezoneH + safezoneY) - (0.185 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneH;
				size = 0.095 * safezoneH;
				type = CT_STRUCTURED_TEXT;
				style = ST_CENTER;
				shadow = false;
				// CT_STRUCTURED_TEXT paints an opaque black box by default when
				// colorBackground isn't set - invisible on the dark shop/debug panels
				// elsewhere in this file, but a solid dark square over the role letter
				// when it's this control sitting directly on the tinted circular badge.
				colorBackground[] = {0,0,0,0};
				class Attributes{
					font = "PuristaBold";
					align = "center";
					valign = "middle";
				};
			};
			// Credits readout: a proper casing pill (shadow + dark base + accent line)
			// matching the shop/debug header treatment, instead of bare floating text.
			class roleCreditsShadow: RscText
			{
				idc = -1;
				x = ((safezoneW + safezoneX) - (0.19 * safezoneH)) - (0.004 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.225 * safezoneH)) - (0.004 * safezoneH);
				w = (0.18 * safezoneH) + (0.008 * safezoneH);
				h = (0.03 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class roleCreditsBG: RscText
			{
				idc = -1;
				x = (safezoneW + safezoneX) - (0.19 * safezoneH);
				y = (safezoneH + safezoneY) - (0.225 * safezoneH);
				w = 0.18 * safezoneH;
				h = 0.03 * safezoneH;
				colorBackground[] = WALDO_HEADERBG;
				style = 0;
			};
			class roleCreditsAccent: RscText
			{
				idc = 1003;
				x = (safezoneW + safezoneX) - (0.19 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.225 * safezoneH)) + (0.03 * safezoneH) - (0.0025 * safezoneH);
				w = 0.18 * safezoneH;
				h = 0.0025 * safezoneH;
				colorBackground[] = WALDO_ACCENT;   // tinted to the role colour at runtime
				style = 0;
			};
			class roleCredits: RscText
			{
				idc = 1002;
				text = "";
				x = (safezoneW + safezoneX) - (0.19 * safezoneH);
				y = (safezoneH + safezoneY) - (0.225 * safezoneH);
				w = 0.18 * safezoneH;
				h = 0.03 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {1,1,1,1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.024 * safezoneH;
				shadow = 1;
			};

			// Key-hints panel (bottom-left): a normal game gives a player no other
			// way to learn what's bound, and dev-only binds are even less
			// discoverable - so this lists whatever's actually relevant to the
			// current role, plus the dev binds too when Testing Mode is on
			// (Waldo_fnc_initHud populates idc 1010, re-run on every role change).
			// Sizes here are placeholders - Waldo_fnc_initHud resizes all three
			// via ctrlSetPosition to fit however many lines actually apply (5
			// without Testing Mode, up to 7 with it), so this never sits around
			// as a fixed box mostly empty.
			class keyHintShadow: RscText
			{
				idc = 1012;
				x = (safezoneX + (0.012 * safezoneW)) - (0.004 * safezoneH);
				y = ((safezoneH + safezoneY) - (0.16 * safezoneH)) - (0.004 * safezoneH);
				w = (0.16 * safezoneW) + (0.008 * safezoneH);
				h = (0.15 * safezoneH) + (0.008 * safezoneH);
				colorBackground[] = WALDO_SHADOW;
				style = 0;
			};
			class keyHintBG: RscText
			{
				idc = 1013;
				x = safezoneX + (0.012 * safezoneW);
				y = (safezoneH + safezoneY) - (0.16 * safezoneH);
				w = 0.16 * safezoneW;
				h = 0.15 * safezoneH;
				colorBackground[] = WALDO_CASING;
				style = 0;
			};
			class keyHintText: RscStructuredText
			{
				idc = 1010;
				text = "";
				x = (safezoneX + (0.012 * safezoneW)) + (0.010 * safezoneW);
				y = ((safezoneH + safezoneY) - (0.16 * safezoneH)) + (0.008 * safezoneH);
				w = (0.16 * safezoneW) - (0.020 * safezoneW);
				h = (0.15 * safezoneH) - (0.016 * safezoneH);
				size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.95);
				colorBackground[] = {0,0,0,0};
				class Attributes {
					font = "PuristaMedium";
					color = "#D8D5C8";
					align = "left";
					shadow = 1;
				};
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
			class pingWheelGroup: RscControlsGroup {
				idc = 3520;
				x = (safezoneX + (0.5 * safezoneW)) - (0.1 * safezoneW);
				y = safezoneY + (0.28 * safezoneH);
				w = 0.2 * safezoneW;
				h = 0.27 * safezoneH;

				class Controls {
					class pwShadow: RscText {
						idc = -1;
						x = -0.004 * safezoneH;
						y = -0.004 * safezoneH;
						w = (0.2 * safezoneW) + (0.008 * safezoneH);
						h = (0.27 * safezoneH) + (0.008 * safezoneH);
						colorBackground[] = WALDO_SHADOW;
						style = 0;
					};
					class pwCasing: RscText {
						idc = -1;
						x = 0; y = 0;
						w = 0.2 * safezoneW;
						h = 0.27 * safezoneH;
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
						y = 0.042 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.044 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt1: RscStructuredText {
						idc = 3511;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.086 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.044 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt2: RscStructuredText {
						idc = 3512;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.130 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.044 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt3: RscStructuredText {
						idc = 3513;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.174 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.044 * safezoneH;
						size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.0);
						colorBackground[] = {0,0,0,0};
						class Attributes { font = "PuristaMedium"; color = "#BFBCAF"; align = "left"; shadow = 1; };
					};
					class pwOpt4: RscStructuredText {
						idc = 3514;
						text = "";
						x = 0.010 * safezoneW;
						y = 0.218 * safezoneH;
						w = 0.18 * safezoneW;
						h = 0.044 * safezoneH;
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
//   1104 header bar, 1108 accent stripe (role-tinted), idc 2 close.
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
				class shopPurchList: RscStructuredText {
					idc = 1106;
					text = "";
					x = 0;
					y = 0;
					w = 0.18 * safezoneW;
					h = 2.0 * safezoneH;   // tall so the group scrolls once purchases stack up
					size = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9);
					class Attributes {
						font = "PuristaMedium";
						color = "#F2EFE3";
						align = "left";
						shadow = 1;
					};
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
