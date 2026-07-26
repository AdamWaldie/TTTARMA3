//////////////////////////////////////////////////////////////////
// Waldo_fnc_dnaScanner
// CLIENT: detective activation item (Y). Aim at a source of DNA within 4m and
// press Y to sample it, then track the suspect with a "hot/cold" readout
// (distance + compass bearing).
//
// DNA is left by Waldo_fnc_onKilled on bodies AND dropped gear, and by placed
// traitor equipment (e.g. C4 charges) - investigation is not limited to
// corpses. Two mechanics stop this from being a free "read and shoot":
//   - DECAY: the older the trace, the shorter the track you get.
//   - CONTAMINATION (Waldo_fnc_dnaContaminate): every different player who came
//     near the scene raises a chance the trace MISDIRECTS you to an innocent
//     bystander instead of the real suspect. You're told the scene is
//     contaminated (so you know to be wary) but never told whether THIS
//     reading is the real one - that judgement call is the point.
//
// "Enhanced Scanner" (a Detective passive) halves the misdirection chance,
// extends the track duration/floor, and adds forensic detail (time since death,
// weapon used) when scanning a body.
//
// Returns true when a sample was taken (consuming the item), false otherwise.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target) exitWith { hint "Aim at a body or a piece of evidence."; false };
if ((player distance _target) > 4) exitWith { hint "Move closer to the evidence."; false };
// A living person cannot be sampled - only bodies and tagged objects carry DNA.
if (_target isKindOf "CAManBase" && {alive _target}) exitWith { hint "Aim at a body, not a living person."; false };

private _source = _target getVariable ["Waldo_killerDNA", objNull];
if (isNull _source) exitWith { hint "No usable DNA here."; false };

hint "Sampling DNA...";
sleep 2;
hint "";

private _enhanced = player getVariable ["Waldo_enhancedScanner", false];

// --- Contamination: chance the scanner points at the wrong person. ---
private _contam = _target getVariable ["Waldo_dnaContamination", 0];
private _misChance = (_contam * (if (_enhanced) then { 0.07 } else { 0.15 })) min 0.85;
private _tracked = _source;
if (_contam > 0 && {random 1 < _misChance}) then {
	private _decoyPool = allPlayers select { alive _x && {_x != _source} };
	if (count _decoyPool > 0) then { _tracked = selectRandom _decoyPool; };
};
if (_contam > 1) then {
	hint format ["Sample contaminated (%1 people were near the scene) - the reading may be unreliable.", _contam];
	sleep 1.5;
};

// --- Track duration: decays with trace age; Enhanced Scanner extends both ends. ---
private _age = time - (_target getVariable ["Waldo_killerDNATime", time]);
private _baseMax   = if (_enhanced) then { 60 } else { 45 };
private _baseFloor = if (_enhanced) then { 20 } else { 12 };
private _decayRate = if (_enhanced) then { 0.18 } else { 0.25 };
private _dur = ((_baseMax - (_age * _decayRate)) max _baseFloor) min _baseMax;

// --- Enhanced forensic line (only meaningful on a body, not dropped gear). ---
private _forensics = "";
if (_enhanced) then {
	private _dt = _target getVariable ["Waldo_deathTime", -1];
	if (_dt > 0) then {
		private _dw = _target getVariable ["Waldo_deathWeapon", ""];
		private _wTxt = if (_dw != "" && {isClass (configFile >> "CfgWeapons" >> _dw)}) then {
			" - " + (getText (configFile >> "CfgWeapons" >> _dw >> "displayName"))
		} else { "" };
		_forensics = format ["<br/><t size='0.8' color='#02b3ff'>Died %1s ago%2</t>", round (time - _dt), _wTxt];
	};
};

[_tracked, _dur, _forensics] spawn {
	params ["_suspect", "_dur", "_forensics"];
	private _endAt = time + _dur;
	private _dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
	while { time < _endAt && {!isNull _suspect} && {alive _suspect} && {alive player} } do {
		private _d = round (player distance _suspect);
		private _c = _dirs select (floor ((((player getDir _suspect) + 22.5) % 360) / 45));
		hintSilent parseText format [
			"<t size='1.2' color='#02b3ff'>DNA Suspect</t><br/><t size='1.4'>~%1 m</t>  <t size='1.1'>%2</t><br/><t size='0.8' color='#9a9a9a'>tracking %3s</t>%4",
			_d, _c, round (_endAt - time), _forensics
		];
		sleep 1;
	};
	if (!isNull _suspect && {!alive _suspect}) then {
		hintSilent parseText "<t size='1.2' color='#02b3ff'>Suspect is down.</t>";
		sleep 3;
	};
	hintSilent "";
};

true
