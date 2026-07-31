//////////////////////////////////////////////////////////////////
// Waldo_fnc_fakeHealthStation
// Traitor deployable. Completely indistinguishable from the real Detective
// Health Station (Waldo_fnc_healthStation) - same crate, same cleared
// cargo, same "Health Station" addAction (identical label, colour, size,
// priority, and radius) - right up until someone uses it: instead of
// healing them, it detonates (Waldo_fnc_fakeHealthStationBoom). No healing
// of any kind; this is a decoy, not a real aid station. The owner
// themselves is exempt from setting it off, so they can safely walk past
// their own trap - that check is invisible to everyone else, so it isn't a
// tell. Expires and deletes itself after 120s if never used, same as the
// real station.
//
// Client call: no args -> forwards the buyer's position (and identity, so
// the trap can exempt them) to the server.
// Server call: [_pos, _owner] -> spawns and arms the trap.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {
	[getPosATL player, player] remoteExec ["Waldo_fnc_fakeHealthStation", 2];
};

// Same listen-server-host position fix as Waldo_fnc_healthStation: isServer
// is true on the very machine that bought this, so the exitWith above never
// fires there, and this runs straight through with the shop's original
// empty _this - default to the caller's own position/unit instead of a
// fixed [0,0,0]/objNull.
params [["_pos", getPosATL player], ["_owner", player]];

private _station = createVehicle ["Box_NATO_Support_F", _pos, [], 0, "CAN_COLLIDE"];
_station allowDamage false;
_station setVariable ["Waldo_fakeOwner", _owner, true];

// Box_NATO_Support_F spawns with vanilla's own default NATO cargo already
// inside - cleared for the same reason the real station clears it: this
// needs to look identical, not like a free loot crate that happens to have
// a health station's addAction on it.
clearWeaponCargoGlobal _station;
clearMagazineCargoGlobal _station;
clearItemCargoGlobal _station;
clearBackpackCargoGlobal _station;

// Every parameter here matches Waldo_fnc_healthStation's own addAction
// exactly except the code (detonate instead of heal) and the condition
// (also exempts the owner) - neither of those differences is visible to a
// player looking at the action before using it.
[_station, [
	"<t color='#3FE07A' size='1.4'>HEALTH STATION</t>",
	{
		params ["_target"];
		[_target] remoteExec ["Waldo_fnc_fakeHealthStationBoom", 2];
	},
	nil, 1.5, false, false, "",
	"alive _this && {_this != (_target getVariable ['Waldo_fakeOwner', objNull])}",
	4
]] remoteExec ["addAction", 0, _station];

[_station] spawn {
	params ["_station"];
	sleep 120;
	if (!isNull _station) then { deleteVehicle _station; };
};

// Same diagnostic as Waldo_fnc_healthStation - "no interactions" reported
// with no bug found on static review; logging so the next .rpt confirms
// whether the crate is actually created/registered where expected.
diag_log format ["[Waldo][server] fakeHealthStation deployed at %1 for owner %2 (netId=%3, typeOf=%4, isNull=%5)", _pos, _owner, netId _station, typeOf _station, isNull _station];
