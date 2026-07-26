//////////////////////////////////////////////////////////////////
// Waldo_fnc_deadRingerTrigger
// CLIENT: fires when an armed Dead Ringer would otherwise take a fatal hit (see
// the HandleDamage guard in Waldo_fnc_initClient, which caps the actual damage
// so the unit survives). Sells the fake death: forces an unconscious ragdoll
// (so onlookers see you drop exactly like a kill) and spawns a decoy corpse
// nearby tagged as an Innocent, so anyone who investigates "the body" is misled
// about your real role. This is a scripted approximation, not true invisibility
// - you are down and vulnerable for the duration, just not actually dead.
//
// params: [_unit]
//////////////////////////////////////////////////////////////////

params ["_unit"];
if (_unit getVariable ["Waldo_deadRingerTriggered", false]) exitWith {};   // guard re-entry
_unit setVariable ["Waldo_deadRingerTriggered", true];
_unit setVariable ["Waldo_deadRingerArmed", false];

[getPosATL _unit, getDir _unit] remoteExec ["Waldo_fnc_spawnDecoyCorpse", 2];

_unit allowDamage false;
_unit setUnconscious true;
hintSilent parseText "<t color='#bf3636' size='1.1'>DEAD RINGER</t><br/><t size='0.9'>Playing dead...</t>";

[_unit] spawn {
	params ["_unit"];
	sleep 20;
	if (alive _unit) then {
		_unit setUnconscious false;
		_unit allowDamage true;
		_unit setVariable ["Waldo_deadRingerTriggered", false];
		hintSilent "";
		hint "You're back up.";
	};
};
