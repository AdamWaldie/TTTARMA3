//////////////////////////////////////////////////////////////////
// Waldo_fnc_setupWeather
// SERVER: randomises time of day and weather within configured bounds.
// NOTE: the old code compared `floor(random 100) < chanceRain` where
// chanceRain was already a 0..1 fraction, so rain/fog almost never fired.
// This version compares against the fraction correctly.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

// Time of day from the single lobby selector:
//   0 Random, 1 Dawn, 2 Day, 3 Dusk, 4 Night.
// Default (both here and the lobby param) is 2 (Day) - out of the box every
// round is fought in daylight; a host has to opt into Random/Dawn/Dusk/Night.
private _hour = switch (missionNamespace getVariable ["timeOfDay", 2]) do {
	case 1: { 5  + floor (random 2) };   // Dawn  05:00-06:xx
	case 2: { 11 + floor (random 3) };   // Day   11:00-13:xx
	case 3: { 18 + floor (random 2) };   // Dusk  18:00-19:xx
	case 4: { 22 + floor (random 3) };   // Night 22:00-00:xx (wraps to 24 -> 0)
	// Random - dawn through evening (05:00-20:xx), never full dark night.
	// Used to be any hour 0-23, which could just as easily land in the
	// middle of the night as at noon - "Random" is meant to vary the
	// LIGHTING mood, not gamble on whether anyone can see anything at all.
	default { 5 + floor (random 16) };
};

setDate [2035, 7, 6, (_hour % 24), floor (random 60)];
setWind [0, 0, true];
0 setOvercast (random 1);

if ((missionNamespace getVariable ["allowRain", true]) && {random 1 < (missionNamespace getVariable ["chanceRain", 0.4])}) then {
	private _rain = random 1;
	0 setOvercast _rain;
	0 setRain _rain;
};

if ((missionNamespace getVariable ["allowFog", true]) && {random 1 < (missionNamespace getVariable ["chanceFog", 0.2])}) then {
	0 setFog (random 0.75);
};

forceWeatherChange;
