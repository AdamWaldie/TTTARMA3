//////////////////////////////////////////////////////////////////
// Game Config
// Last update by: Waldo 28DEC2022
//////////////////////////////////////////////////////////////////

// -- Equipment Options -- //
// Equipment Config files can be found in ModpackConfiguration. 
//Please unhash the file you wish to utilise below. Custom.sqf is for your own personal changes.
// At least one config file must be selected for this mission to work.

//Vanilla + DLC (NO CDLC)
execVM "ModpackConfiguration\Vanilla.sqf";

//WW2 - Northern Fronts + JMs Second Assault
//execVM "ModpackConfiguration\WW2.sqf";


//Custom (Your Edits, by default Vanilla)
//execVM "ModpackConfiguration\Custom.sqf";


// -- Round options -- //

// Base round length in seconds
roundBaseLength = 180;

// For each player added time to round length in seconds
roundPlayerLength = 30;

// Traitor extra time in seconds
roundTraitorLength = 45;

// Player dead add round length in seconds
roundDeadLength = 30;

missionNamespace setVariable ["roundDeadLength",roundDeadLength,true];

// Warmup length in seconds
roundWarmupLength = 20;

// -- Airdrop options -- //

// Allow airdrops (True/False)
airdrop = true;

// Airdrop base timer in seconds
airdropBaseTimer = 75;

// Airdrop random timer add in seconds
airdropRandomTimer = 75;

// Airdrop loadouts amount in each airdrop
airdropLoadoutsAmount = 1;

// Max amount of bullets in magazine
lootMaxBullets = 50;

// -- Weather options -- //

// Allow rain (True/False)
allowRain = true;

// Chance of rain in percentage
chanceRain = 40;

// Allow fog (True/False)
allowFog = true;

// Chance of fog in percentage
chanceFog = 20;

// Earliest time of day in hours
timeFrom = 5;

// Latest time of day in hours
timeTo = 19;


// -- Game Options -- //

//Toggle For Jester - Cannot be used with ACE at the moment.
JesterEnabled = false;

//Percentage chance Of Jester Spawning
JesterPercentagechance = 0.40;

//Lower Bound For Chance of Traitor Numbers
TraitorPercentageChanceLowerBound = 0.25;

//Higher Bound For Chance of Traitor Numbers
TraitorPercentageChanceHigherBound = 0.45;

diag_log ("Config loaded");