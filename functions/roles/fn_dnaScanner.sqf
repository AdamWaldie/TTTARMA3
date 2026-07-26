//////////////////////////////////////////////////////////////////
// Waldo_fnc_dnaScanner
// CLIENT: detective activation item (Y). Aim at a body within 4m and press Y to
// sample the killer's DNA (set on the body by Waldo_fnc_onKilled). Once sampled,
// a "hot/cold" tracker shows the suspect's distance + compass bearing for a
// while, so the detective can hunt down whoever made the kill - the classic TTT
// investigation loop the role reveal (tester) doesn't provide.
//
// Returns true when a sample was taken (consuming the item), false otherwise.
//////////////////////////////////////////////////////////////////

private _target = cursorTarget;

if (isNull _target || {!(_target isKindOf "CAManBase")} || {alive _target}) exitWith {
	hint "Aim at a body.";
	false
};
if ((player distance _target) > 4) exitWith {
	hint "Move closer to the body.";
	false
};

private _killer = _target getVariable ["Waldo_killerDNA", objNull];
if (isNull _killer) exitWith {
	hint "No usable DNA on this body.";
	false
};

hint "Sampling DNA...";
sleep 2;
hint "";

// Track the suspect for a while (ends early if they die or you do).
[_killer] spawn {
	params ["_killer"];
	private _endAt = time + 45;
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
