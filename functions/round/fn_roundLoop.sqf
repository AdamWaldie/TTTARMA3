//////////////////////////////////////////////////////////////////
// Waldo_fnc_roundLoop
// SERVER: the 1 Hz round loop. Formats timers, pushes per-role HUD hints,
// triggers airdrops, and checks win conditions. Blocks until the round ends.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _start = missionNamespace getVariable ["Waldo_startTime", 180];

private _fmt = {
	params ["_s"];
	private _m = floor (_s / 60);
	private _sec = _s % 60;
	format ["%1:%2", _m, [str _sec, "0" + str _sec] select (_sec < 10)]
};

private _airdropWait = round ((random (missionNamespace getVariable ["airdropRandomTimer", 75])) + (missionNamespace getVariable ["airdropBaseTimer", 75]));
private _airdropTimer = 0;
private _timer = 0;

while { missionNamespace getVariable ["gameOn", false] } do {

	private _timelimit = missionNamespace getVariable ["timelimit", _start];

	// --- Timers ---
	private _civInt = _start - _timer;
	private _civTimer = if (_timer > _start) then { "Overtime" } else { [_civInt] call _fmt };
	private _traitorTimer = [(_timelimit - _timer)] call _fmt;

	// --- HUD hints per player ---
	{
		private _role = _x getVariable ["role", "Innocent"];
		private _text = if (_role == "Traitor") then {
			format [
				"<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />%1 (%2)</t><br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>",
				_traitorTimer, _civTimer
			]
		} else {
			private _t = format ["<t align='center' size='1.5'><t color='#ffbb00' shadow='1'>Round Timer:</t><br />%1</t>", _civTimer];
			if (_role == "Detective") then {
				_t = _t + "<br /><br /><t align='center' size='0.8'><t shadow='1'>Press 'B' to open BuyMenu</t>";
			};
			_t
		};
		(parseText _text) remoteExec ["hintSilent", _x];
	} forEach allPlayers;

	// --- Airdrop ---
	if ((missionNamespace getVariable ["airdrop", true]) && {_airdropTimer + 1 >= _airdropWait}) then {
		[] call Waldo_fnc_spawnAirdrop;
		_airdropWait = round ((random (missionNamespace getVariable ["airdropRandomTimer", 75])) + (missionNamespace getVariable ["airdropBaseTimer", 75]));
		_airdropTimer = 0;
	};

	// --- Win check ---
	private _ending = [_timer, _timelimit] call Waldo_fnc_checkWin;
	if (_ending != "") exitWith { [_ending] call Waldo_fnc_endRound; };

	sleep 1;
	_timer = _timer + 1;
	_airdropTimer = _airdropTimer + 1;
};
