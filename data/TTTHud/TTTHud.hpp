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
				text = "data\TTTHud\rolebg.paa"; 
				x = (safezoneW + safezoneX) - (0.160 * safezoneH);
				y = (safezoneH + safezoneY) - (0.20 * safezoneH);
				w = 0.15 * safezoneH;
				h = 0.15 * safezoneW;
				color = [1,1,1,0.5];
			};
			class roleTextBG: RscPicture
			{
				idc = 1000;
				text = "data\TTTHud\role.paa"; 
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

class dMenu {
	idd = -3;
	fadeout=0.25;
	fadein=0.25;
	movingEnable = true;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do {dMenu = _this select 0}";

	class controlsBackground {
		class dMenuPoints
		{
			type = 0;
			idc = 801;
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.7 * safezoneH));
			w = 0.20 * safezoneW;
			h = 0.05 * safezoneH;
			style = 18;
			text = "Credits: 1";
			colorBackground[] = {0.10196,0.10196,0.10196,0};
			colorText[] = {0.01,0.45,1,1};
			lineSpacing = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
			default = false;
		};
		class dMenuBG
		{
			type = 0;
			idc = 800;
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.75 * safezoneH));
			w = 0.20 * safezoneW;
			h = 0.50 * safezoneH;
			style = 18;
			text = "Detective Shop";
			colorBackground[] = {0.10196,0.10196,0.10196,1};
			colorText[] = {0.01,0.45,1,1};
			lineSpacing = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5);
			default = false;
		};
	};

	class Controls
	{
		class Button1
		{
			type = 1;
			idc = 802;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.65 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Portable Tester";
			colorBackground[] = {0.01,0.45,1,1};
			colorBackgroundActive[] = {0,0,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Activation Ability (Press Y)";
		};
		class Button2
		{
			type = 1;
			idc = 803;
			x = ((safezoneW + safezoneX) - (0.495 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.65 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Radar";
			colorBackground[] = {0.01,0.45,1,1};
			colorBackgroundActive[] = {0,0,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};	
			default = false;
			tooltip = "Passive Ability";
		};
		class Button3
		{
			type = 1;
			idc = 804;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.57 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Smoke Grenades";
			colorBackground[] = {0.01,0.45,1,1};
			colorBackgroundActive[] = {0,0,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Weapon Ability";
		};
		class Button4
		{
			type = 1;
			idc = 805;
			x = ((safezoneW + safezoneX) - (0.495 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.57 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Stamina";
			colorBackground[] = {0.01,0.45,1,1};
			colorBackgroundActive[] = {0,0,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};	
			default = false;
			tooltip = "Passive Ability";
		};
		class Button5
		{
			type = 1;
			idc = 806;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.49 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Flower Power";
			colorBackground[] = {0.01,0.45,1,1};
			colorBackgroundActive[] = {0,0,1,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Passive Ability";
		};
	};
};

class tMenu {
	idd = -2;
	fadeout=0.25;
	fadein=0.25;
	movingEnable = true;
	enableSimulation = true;
	duration = 99999;
	onLoad = "with uiNamespace do {tMenu = _this select 0}";

	class controlsBackground {
		class tMenuPoints
		{
			type = 0;
			idc = 901;
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.7 * safezoneH));
			w = 0.20 * safezoneW;
			h = 0.05 * safezoneH;
			style = 18;
			text = "Points: 1";
			colorBackground[] = {0.10196,0.10196,0.10196,0};
			colorText[] = {0.75,0.21,0.21,1};
			lineSpacing = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.25);
			default = false;
		};
		class tMenuBG
		{
			type = 0;
			idc = 900;
			x = ((safezoneW + safezoneX) - (0.6 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.75 * safezoneH));
			w = 0.20 * safezoneW;
			h = 0.50 * safezoneH;
			style = 18;
			text = "Traitor Shop";
			colorBackground[] = {0.10196,0.10196,0.10196,1};
			colorText[] = {0.75,0.21,0.21,1};
			lineSpacing = 0;
			font = "PuristaMedium";
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1.5);
			default = false;
		};
	};

	class Controls
	{
		class Button1
		{
			type = 1;
			idc = 902;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.65 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Suicide Bomb";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Activation Ability (Press Y)";
		};
		class Button2
		{
			type = 1;
			idc = 903;
			x = ((safezoneW + safezoneX) - (0.495 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.65 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Radar";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};	
			default = false;
			tooltip = "Passive Ability";
		};
		class Button3
		{
			type = 1;
			idc = 904;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.57 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Rocket Launcher";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Weapon Ability";
		};
		class Button4
		{
			type = 1;
			idc = 905;
			x = ((safezoneW + safezoneX) - (0.495 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.57 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Stamina";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};	
			default = false;
			tooltip = "Passive Ability";
		};
		class Button5
		{
			type = 1;
			idc = 906;
			x = ((safezoneW + safezoneX) - (0.595 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.49 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Teleportation Grenades";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};		
			default = false;
			tooltip = "Red Smoke Grenades Teleport, only vanilla throwing supported";
		};
		class Button6
		{
			type = 1;
			idc = 907;
			x = ((safezoneW + safezoneX) - (0.495 * safezoneW));
			y = ((safezoneH + safezoneY) - (0.49 * safezoneH));
			w = 0.09 * safezoneW;
			h = 0.075 * safezoneH;
			bordersize = 0;
			style = 0+2;
			text = "Long Rifle";
			colorBackground[] = {0.75,0.21,0.21,1};
			colorBackgroundActive[] = {1,0,0,1};
			colorBackgroundDisabled[] = {0.2,0.2,0.2,1};
			colorBorder[] = {1,1,1,0};
			colorDisabled[] = {0.2,0.2,0.2,1};
			colorFocused[] = {0.2,0.2,0.2,1};
			colorShadow[] = {0,0,0,0};
			colorText[] = {1,1,1,1};
			font = "PuristaMedium";
			offsetPressedX = 0.001;
			offsetPressedY = 0.001;
			offsetX = 0;
			offsetY = 0;
			sizeEx = (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1);
			soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1.0};
			soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1.0};
			soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1.0};
			soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1.0};	
			default = false;
			tooltip = "Weapon Ability";
		};
	};
};