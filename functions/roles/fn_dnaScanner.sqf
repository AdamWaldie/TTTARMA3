//////////////////////////////////////////////////////////////////
// Waldo_fnc_dnaScanner
// CLIENT: detective activation item (Y). Aim at a source of DNA within 4m and
// press Y to sample it, then track the culprit with a "hot/cold" readout
// (distance + compass bearing).
//
// DNA is left by Waldo_fnc_onKilled on bodies, and by placed traitor equipment
// (e.g. C4 charges) on the object itself - so investigation is not limited to
// corpses. DNA DECAYS: the older the trace, the shorter the track you get.
//
// Returns true when a sample was taken (consuming the item), false otherwise.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target) exitWith { hint "Aim at a body or a piece of evidence."; false };
if ((player distance _target) > 4) exitWith { hint "Move closer to the evidence."; false };
// A living person cannot be sampled - only bodies and tagged objects carry DNA.
if (_target isKindOf "CAManBase" && {alive _target}) exitWith { hint "Aim at a body, not a living person."; false };

private _killer = _target getVariable ["Waldo_killerDNA", objNull];
if (isNull _killer) exitWith { hint "No usable DNA here."; false };

hint "Sampling DNA...";
sleep 2;
hint "";

// Track duration decays with the age of the trace (fresh 45s -> old floor 12s).
private _age = time - (_target getVariable ["Waldo_killerDNATime", time]);
private _dur = ((45 - (_age * 0.25)) max 12) min 45;

[_killer, _dur] spawn {
	params ["_killer", "_dur"];
	private _endAt = time + _dur;
	private _dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
	while { time < _endAt && {!isNull _killer} && {alive _killer} && {alive player} } do {
		private _d = round (player distance _killer);
		private _c = _dirs select (floor ((((player getDir _killer) + 22.5) % 360) / 45));
		hintSilent parseText format [
			"<t size='1.2' color='#02b3ff'>DNA Suspect</t><br/><t size='1.4'>~%1 m</t>  <t size='1.1'>%2</t><br/><t size='0.8' color='#9a9a9a'>tracking %3s</t>",
			_d, _c, round (_endAt - time)
		];
		sleep 1;
	};
	if (!isNull _killer && {!alive _killer}) then {
		hintSilent parseText "<t size='1.2' color='#02b3ff'>Suspect is down.</t>";
		sleep 3;
	};
	hintSilent "";
};

true
