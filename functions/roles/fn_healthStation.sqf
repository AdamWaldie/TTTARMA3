//////////////////////////////////////////////////////////////////
// Waldo_fnc_healthStation
// Detective deployable. Called on the buyer's client; forwards to the server
// which spawns a supply crate that slowly heals nearby players for a while.
// Healing is remote-executed to each player's machine (setDamage must run
// where the unit is local).
//
// Client call: no args -> forwards player's position to the server.
// Server call: [_pos] -> spawns and runs the station.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {
	[getPosATL player] remoteExec ["Waldo_fnc_healthStation", 2];
};

params [["_pos", [0,0,0]]];

private _station = createVehicle ["Box_NATO_Support_F", _pos, [], 0, "CAN_COLLIDE"];
_station allowDamage false;
_station setVariable ["Waldo_healUntil", time + 120, true];

// Plain setDamage doesn't actually heal a player under ACE's medical
// system - ACE tracks its own per-limb injury/bleeding/pain state and
// largely ignores/overrides direct damage changes, which is why this did
// nothing at all with ACE Medical active. ace_medical_treatment_fnc_fullHeal
// is ACE's own documented way to heal a unit; harmless/idempotent to call
// repeatedly on someone already at full health, so no extra "are they
// hurt" check is needed before calling it.
[{
	params ["_args", "_handle"];
	_args params ["_station"];
	if (isNull _station || {time > (_station getVariable ["Waldo_healUntil", 0])}) exitWith {
		[_handle] call CBA_fnc_removePerFrameHandler;
	};
	{
		if (alive _x && {(_x distance _station) < 5}) then {
			if (isNil "ace_medical_treatment_fnc_fullHeal") then {
				if (damage _x > 0) then {
					[_x, (((damage _x) - 0.05) max 0)] remoteExec ["setDamage", _x];
				};
			} else {
				[objNull, _x] remoteExec ["ace_medical_treatment_fnc_fullHeal", _x];
			};
		};
	} forEach allPlayers;
}, 2, [_station]] call CBA_fnc_addPerFrameHandler;

diag_log format ["[Waldo][server] healthStation deployed at %1", _pos];
