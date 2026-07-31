//////////////////////////////////////////////////////////////////
// Waldo_fnc_radarCountdown
// CLIENT: a small always-on corner label counting down to the owner's next
// Radar pulse (Waldo_radarNextPing, kept up to date by
// Waldo_fnc_traitorRadar/Waldo_fnc_detectiveRadar each time it recharges).
// One control, created once and text-updated in place each tick - no
// per-tick ctrlCreate/ctrlDelete churn. Replaces rather than stacks if
// called again (rebuying Radar), and clears itself on death.
//
// params: [_interval]
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};
params ["_interval"];

player setVariable ["Waldo_radarCountdownToken", (player getVariable ["Waldo_radarCountdownToken", 0]) + 1];
private _token = player getVariable ["Waldo_radarCountdownToken", 0];

[_token, _interval] spawn {
	params ["_token", "_interval"];

	waitUntil { uiSleep 0.1; !isNull (uiNamespace getVariable ["TTTHud", displayNull]) || !alive player };
	if (!alive player) exitWith {};
	private _display = uiNamespace getVariable "TTTHud";

	// Tucked just under the round-timer bar (fn_topBarTimer.sqf), same
	// horizontal centring, small and out of the way of everything else.
	private _w = 0.12 * safezoneW;
	private _h = 0.03 * safezoneH;
	private _x = safezoneX + (0.5 * safezoneW) - (_w / 2);
	private _y = safezoneY + (0.015 * safezoneH) + (0.062 * safezoneH) + (0.008 * safezoneH);

	private _ctrl = _display ctrlCreate ["RscStructuredText", -1];
	_ctrl ctrlSetPosition [_x, _y, _w, _h];
	_ctrl ctrlCommit 0;

	while { alive player && {(player getVariable ["Waldo_radarCountdownToken", 0]) == _token} } do {
		private _remaining = ceil (((player getVariable ["Waldo_radarNextPing", time]) - time) max 0);
		_ctrl ctrlSetStructuredText parseText format [
			"<t align='center' font='PuristaMedium' size='0.6' color='#D9AE34'>Radar in %1s</t>", _remaining
		];
		sleep 1;
	};

	if (!isNull _ctrl) then { ctrlDelete _ctrl; };
};
