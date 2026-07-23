//////////////////////////////////////////////////////////////////
// Waldo_fnc_setupWeather
// SERVER: randomises time of day and weather within configured bounds.
// NOTE: the old code compared `floor(random 100) < chanceRain` where
// chanceRain was already a 0..1 fraction, so rain/fog almost never fired.
// This version compares against the fraction correctly.
//////////////////////////////////////////////////////////////////

if (!isServer) exitWith {};

private _timeFrom = missionNamespace getVariable ["timeFrom", 5];
private _timeTo   = missionNamespace getVariable ["timeTo", 19];

setDate [2022, 9, 18, (random (_timeTo - _timeFrom - 1)) + _timeFrom, floor (random 60)];
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
