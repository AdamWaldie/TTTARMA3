//////////////////////////////////////////////////////////////////
// Waldo_fnc_dnaScanner
// CLIENT: detective activation item (Y/U/J, whichever it's bound to). Aim at
// a source of DNA within 4m and press it to sample the trace, then track the
// suspect with a "hot/cold" readout (distance + compass bearing).
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
// Limited uses: Waldo_dnaScannerCharges is set to 3 on purchase (see the DNA
// Scanner catalog entry in fn_initShops.sqf) and decremented on every
// successful sample below. The item's activation slot only actually frees up
// (Waldo_fnc_useActivationSlot's contract: return true = consumed) once
// charges hit 0 - a failed attempt (no target, out of range, etc) never
// spends a charge at all, only a real sample does.
//
// Returns true once charges are exhausted (consuming the item), false
// otherwise (including every early-exit below, none of which spend a charge).
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

// cursorTarget is unreliable for small, loosely-simulated evidence (dropped
// gear, the C4 decoy prop) - it's tuned to pick out AI-relevant targets like
// full character bodies, which is why fn_removeBody.sqf/fn_revive.sqf/
// fn_tester.sqf (corpse-only) never hit this problem but this scanner - which
// also has to pick up WeaponHolderSimulated/GroundWeaponHolder and the C4
// decoy prop - could come up completely empty even when aimed at something in
// range. Fall back to the nearest DNA-bearing object when the cursor itself
// finds nothing at all; this can never resolve to a living player, since a
// living player never carries Waldo_killerDNA in the first place.
if (isNull _target) then {
	private _nearby = nearestObjects [player, ["CAManBase", "WeaponHolderSimulated", "GroundWeaponHolder", "Land_Suitcase_F"], 4];
	_nearby = _nearby select { !isNull (_x getVariable ["Waldo_killerDNA", objNull]) };
	if (count _nearby > 0) then { _target = _nearby select 0; };
};

private _warn = {
	params ["_msg"];
	["DNA SCANNER", _msg, "WARNING", 3, "BOTTOM_LEFT", "DNA_SAMPLE", "DNA SCANNER"] call Waldo_fnc_ShowUiNotification;
};

if (isNull _target) exitWith { ["Aim at a body or a piece of evidence."] call _warn; false };
if ((player distance _target) > 4) exitWith { ["Move closer to the evidence."] call _warn; false };
// A living person cannot be sampled - only bodies and tagged objects carry DNA.
if (_target isKindOf "CAManBase" && {alive _target}) exitWith { ["Aim at a body, not a living person."] call _warn; false };

private _source = _target getVariable ["Waldo_killerDNA", objNull];
if (isNull _source) exitWith { ["No usable DNA here."] call _warn; false };

// One sample per piece of evidence, full stop - global (not per-detective),
// so re-aiming at the same corpse can't be used to re-roll contamination/
// misdirection for a better outcome, and two different detectives can't
// each burn a charge on the same body for two independent rolls either.
if (_target getVariable ["Waldo_dnaSampled", false]) exitWith { ["Already sampled - no new information here."] call _warn; false };
_target setVariable ["Waldo_dnaSampled", true, true];

private _charges = (player getVariable ["Waldo_dnaScannerCharges", 3]) - 1;
player setVariable ["Waldo_dnaScannerCharges", _charges, true];
[
	"DNA SCANNER", format ["Sampling DNA... (%1 use%2 left)", _charges, ["s", ""] select (_charges == 1)],
	"INFO", 2, "BOTTOM_LEFT", "DNA_SAMPLE", "DNA SCANNER"
] call Waldo_fnc_ShowUiNotification;

// Y is handled unscheduled (called directly from the KeyDown handler), so
// everything below (both early sleeps and the tracking loop) has to live in
// one scheduled thread - sleep is illegal here otherwise.
[_target, _source] spawn {
	params ["_target", "_source"];
	sleep 2;

	private _enhanced = player getVariable ["Waldo_enhancedScanner", false];

	// --- Contamination: chance the scanner points at the wrong person. ---
	private _contam = _target getVariable ["Waldo_dnaContamination", 0];
	private _misChance = (_contam * (if (_enhanced) then { 0.07 } else { 0.15 })) min 0.85;
	private _tracked = _source;
	if (_contam > 0 && {random 1 < _misChance}) then {
		// _decoyPool must also exclude the scanning player, not just the real
		// source - fn_dnaContaminate.sqf already keeps a Detective's own
		// presence from inflating _contam, but this pool used to let a
		// misdirection land on "player" anyway, and a Detective is by
		// definition within 4m of whatever they're scanning. With few living
		// players left (the exact point this matters most), that made the
		// scanner "usually" track the detective holding it.
		private _decoyPool = allPlayers select { alive _x && {_x != _source} && {_x != player} };
		if (count _decoyPool > 0) then { _tracked = selectRandom _decoyPool; };
	};
	// A raw witness count means nothing to a player without context for what
	// it does to their odds - show the actual risk tier (derived from
	// _misChance, so it already reflects Enhanced Scanner's halving) plus the
	// count, instead of just the count alone.
	if (_contam > 0) then {
		private _tier = ["Low", "Moderate", "High", "Severe"] select (
			if (_misChance < 0.15) then {0} else { if (_misChance < 0.4) then {1} else { if (_misChance < 0.7) then {2} else {3} } }
		);
		private _tierColour = ["#6CE5A8", "#FFD166", "#FF9F5A", "#FF6161"] select (
			if (_misChance < 0.15) then {0} else { if (_misChance < 0.4) then {1} else { if (_misChance < 0.7) then {2} else {3} } }
		);
		[
			"DNA SCANNER",
			format ["<t color='%1'>%2 contamination</t> (%3 nearby witness%4) - reading may be unreliable.",
				_tierColour, _tier, _contam, ["es", ""] select (_contam == 1)],
			"WARNING", 4, "BOTTOM_LEFT", "DNA_CONTAM", "DNA SCANNER"
		] call Waldo_fnc_ShowUiNotification;
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
			_forensics = format ["<br/><t size='0.8' color='#9FB3C8'>Died %1s ago%2</t>", round (time - _dt), _wTxt];
		};
	};

	private _endAt = time + _dur;
	private _dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
	// This is its own notification channel/display now, not hintSilent, so it
	// no longer needs the gameOn race-guard the old hintSilent version did
	// (that was specifically to stop clobbering Waldo_fnc_mvpCelebrate's
	// round-end banner on the ONE shared hint channel) - still stops the loop
	// at round end on its own merits, though, since tracking a suspect past
	// the round being over is meaningless.
	while {
		time < _endAt
		&& {!isNull _tracked} && {alive _tracked} && {alive player}
		&& {missionNamespace getVariable ["gameOn", true]}
	} do {
		private _d = round (player distance _tracked);
		private _c = _dirs select (floor ((((player getDir _tracked) + 22.5) % 360) / 45));
		[
			"DNA SUSPECT",
			format ["~%1 m  %2<br/><t size='0.8' color='#9FB3C8'>tracking %3s</t>%4", _d, _c, round (_endAt - time), _forensics],
			"INFO", 0, "BOTTOM_LEFT", "DNA_TRACK", "DNA SCANNER"
		] call Waldo_fnc_ShowUiNotification;
		sleep 1;
	};
	if (!isNull _tracked && {!alive _tracked} && {missionNamespace getVariable ["gameOn", true]}) then {
		["DNA SUSPECT", "Suspect is down.", "SUCCESS", 4, "BOTTOM_LEFT", "DNA_TRACK", "DNA SCANNER"] call Waldo_fnc_ShowUiNotification;
	} else {
		["DNA_TRACK"] call Waldo_fnc_DismissUiNotification;
	};
};

_charges <= 0
