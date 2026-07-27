//////////////////////////////////////////////////////////////////
// Waldo_fnc_pingWheelOpen
// CLIENT: opens the ping picker on T KeyDown (traitors only). This is a HUD
// overlay, not a modal dialog - the player still needs to look/move while
// choosing - so selection is driven by the mouse wheel (Waldo_fnc_pingWheelRender
// redraws the highlight) rather than clicking anything. Defaults the highlight
// to whatever a quick tap used to send (Target if aiming at a living player,
// else Location), so releasing T immediately still behaves like the old
// auto-detect ping. Waldo_fnc_pingWheelClose reads the final highlight on KeyUp
// and fires it.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
if ((player getVariable ["role", ""]) != "Traitor") exitWith {};
if (missionNamespace getVariable ["Waldo_pingWheelOpen", false]) exitWith {};

disableSerialization;
if (isNil { uiNamespace getVariable "TTTPingWheel" }) then {
	titleRsc ["TTTPingWheel", "PLAIN", 1, false];
	waitUntil { !isNull (uiNamespace getVariable ["TTTPingWheel", displayNull]) };
};
private _display = uiNamespace getVariable "TTTPingWheel";

Waldo_pingWheelOptions = [
	["Target",        "track who you're aiming at"],
	["Location",      "mark where you're looking"],
	["Danger",        "warn of a threat here"],
	["Regroup Here",  "call traitors to your position"],
	["Enemy Spotted", "flag a suspicious player"]
];

private _ct = cursorTarget;
private _aimingPlayer = !isNull _ct && {_ct isKindOf "CAManBase"} && {alive _ct} && {(player distance _ct) < 300};
Waldo_pingWheelIndex = if (_aimingPlayer) then { 0 } else { 1 };

private _color = ["Traitor"] call Waldo_roleColor;
(_display displayCtrl 3502) ctrlSetBackgroundColor [_color select 0, _color select 1, _color select 2, 1];

[] call Waldo_fnc_pingWheelRender;
(_display displayCtrl 3520) ctrlShow true;
Waldo_pingWheelOpen = true;

// Mouse wheel moves the highlight while T stays held; returning true here also
// suppresses the default zoom/optic-adjust so scrolling doesn't fight the game.
Waldo_pingWheelEH = (findDisplay 46) displayAddEventHandler ["MouseZChanged", {
	params ["_d", "_delta"];
	private _n = count (missionNamespace getVariable ["Waldo_pingWheelOptions", []]);
	if (_n > 0) then {
		private _step = if (_delta > 0) then { 1 } else { -1 };
		Waldo_pingWheelIndex = ((Waldo_pingWheelIndex + _step) + _n) mod _n;
		[] call Waldo_fnc_pingWheelRender;
	};
	true
}];
