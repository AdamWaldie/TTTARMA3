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

		class controlsBackground {
			class roleTextBGBG: RscPicture
			{
				idc = 999;
				text = "ui\rolebg.paa";
				x = (safezoneW + safezoneX) - (0.160 * safezoneH);
				y = (safezoneH + safezoneY) - (0.20 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneW;
				color = [1,1,1,0.5];
			};
			class roleTextBG: RscPicture
			{
				idc = 1000;
				text = "ui\role.paa";
				x = (safezoneW + safezoneX) - (0.160 * safezoneH);
				y = (safezoneH + safezoneY) - (0.20 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneW;
			};
			class roleText: RscStructuredText
			{
				idc = 1001;
				text = "";
				x = (safezoneW + safezoneX) - (0.160 * safezoneH);
				y = (safezoneH + safezoneY) - (0.20 * safezoneH) + (0.01000 * safezoneW);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneW;
				size = 0.12 * safezoneW;
				type = CT_STRUCTURED_TEXT;
				style = ST_RIGHT;
				shadow = false;
				class Attributes{
					font = "PuristaBold";
					align = "center";
					valign = "middle";
				};
			};
			class roleCredits: RscText
			{
				idc = 1002;
				text = "";
				x = (safezoneW + safezoneX) - (0.24 * safezoneH);
				y = (safezoneH + safezoneY) - (0.235 * safezoneH);
				w = 0.23 * safezoneH;
				h = 0.03 * safezoneH;
				colorBackground[] = {0,0,0,0};
				colorText[] = {1,1,1,1};
				style = ST_CENTER;
				font = "PuristaBold";
				sizeEx = 0.028 * safezoneH;
				shadow = 1;
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
// WaldoShop - shared buy menu dialog. Buttons are generated at runtime from
// the role's catalog by Waldo_fnc_openBuyMenu, so this shell never changes
// when shop items are added or removed.
//   idc 1100 = title, 1101 = credits, 1102 = scrollable button group.
// ============================================================================
class WaldoShop {
	idd = -1;
	fadeout = 0.25;
	fadein = 0.25;
	movingEnable = true;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do { WaldoShop = _this select 0 }";

	class controlsBackground {
		class shopBG: RscText {
			idc = -1;
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.75 * safezoneH));
			w = 0.22 * safezoneW;
			h = 0.55 * safezoneH;
			colorBackground[] = {0.10196,0.10196,0.10196,1};
			colorText[] = {1,1,1,1};
			style = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class shopTitle: RscText {
			idc = 1100;
			text = "Shop";
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.75 * safezoneH));
			w = 0.22 * safezoneW;
			h = 0.06 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			style = ST_CENTER;
			font = "PuristaBold";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5);
		};
		class shopCredits: RscText {
			idc = 1101;
			text = "Credits: 0";
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.685 * safezoneH));
			w = 0.22 * safezoneW;
			h = 0.05 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			style = ST_CENTER;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
		};
	};

	class Controls {
		class shopGroup: RscControlsGroup {
			idc = 1102;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.62 * safezoneH));
			w = 0.21 * safezoneW;
			h = 0.42 * safezoneH;
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
		class dbgBG: RscText {
			idc = -1;
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH));
			w = 0.44 * safezoneW;
			h = 0.72 * safezoneH;
			colorBackground[] = {0.05,0.05,0.05,0.92};
			colorText[] = {1,1,1,1};
			style = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
		};
		class dbgTitle: RscText {
			idc = 3100;
			text = "Dev / Test Menu";
			x = (safezoneX + (0.28 * safezoneW));
			y = (safezoneY + (0.14 * safezoneH));
			w = 0.44 * safezoneW;
			h = 0.06 * safezoneH;
			colorBackground[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			style = ST_CENTER;
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
				color = "#ffffff";
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
