//////////////////////////////////////////////////////////////////
// Game Config
// Auto-generated to use mission params correctly via `param`
//////////////////////////////////////////////////////////////////

// -- Equipment Options -- //
// Equipment Config files can be found in ModpackConfiguration. 
//Please unhash the file you wish to utilise below. Custom.sqf is for your own personal changes.
// At least one config file must be selected for this mission to work.

//Vanilla + DLC (NO CDLC)
execVM "modpacks\Vanilla.sqf";

//WW2 - Northern Fronts + JMs Second Assault
//execVM "modpacks\WW2.sqf";


//Custom (Your Edits, by default Vanilla)
//execVM "modpacks\Custom.sqf";

// === ROUND OPTIONS ===
roundBaseLength    = param [0, 180];  missionNamespace setVariable ["roundBaseLength", roundBaseLength];
roundPlayerLength  = param [1, 30];   missionNamespace setVariable ["roundPlayerLength", roundPlayerLength];
roundTraitorLength = param [2, 45];   missionNamespace setVariable ["roundTraitorLength", roundTraitorLength];
roundDeadLength    = param [3, 30];   missionNamespace setVariable ["roundDeadLength", roundDeadLength];
roundWarmupLength  = param [4, 20];   missionNamespace setVariable ["roundWarmupLength", roundWarmupLength];

// === AIRDROP OPTIONS ===
airdrop               = param [5, True]; missionNamespace setVariable ["airdrop", airdrop];
airdropBaseTimer      = param [6, 75];    missionNamespace setVariable ["airdropBaseTimer", airdropBaseTimer];
airdropRandomTimer    = param [7, 75];    missionNamespace setVariable ["airdropRandomTimer", airdropRandomTimer];
airdropLoadoutsAmount = param [8, 1];     missionNamespace setVariable ["airdropLoadoutsAmount", airdropLoadoutsAmount];
lootMaxBullets        = param [9, 50];    missionNamespace setVariable ["lootMaxBullets", lootMaxBullets];

// === WEATHER OPTIONS ===
allowRain  = param [10, True]; missionNamespace setVariable ["allowRain", allowRain];
chanceRain = (param [11, 40]/100);    missionNamespace setVariable ["chanceRain", chanceRain];
allowFog   = param [12, True]; missionNamespace setVariable ["allowFog", allowFog];
chanceFog  = (param [13, 20]/100);    missionNamespace setVariable ["chanceFog", chanceFog];
timeFrom   = param [14, 5];     missionNamespace setVariable ["timeFrom", timeFrom];
timeTo     = param [15, 19];    missionNamespace setVariable ["timeTo", timeTo];

// === GAME OPTIONS ===
JesterEnabled                     = param [16, False];   missionNamespace setVariable ["JesterEnabled", JesterEnabled];
JesterPercentagechance            = (param [17, 30]/100);      missionNamespace setVariable ["JesterPercentagechance", JesterPercentagechance];
TraitorPercentageChanceLowerBound = (param [18, 25]/100);     missionNamespace setVariable ["TraitorPercentageChanceLowerBound", TraitorPercentageChanceLowerBound];
TraitorPercentageChanceHigherBound = (param [19, 45]/100);    missionNamespace setVariable ["TraitorPercentageChanceHigherBound", TraitorPercentageChanceHigherBound];

//Test flag
TestingFlag = param [20, False];    missionNamespace setVariable ["TestingFlag", TestingFlag];


diag_log "Config loaded from mission parameters using correct param[] indexing.";
