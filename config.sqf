//////////////////////////////////////////////////////////////////
// Game Config
// Last update by: Waldo 14SEP2022
//////////////////////////////////////////////////////////////////



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

// Airdrop loadouts (Advanced)
// ["weapon","WeaponClassname",["MagazineClassname","Amount"],["Attachment1","Attachment2"]]
airdropLoadouts = [
["weapon","arifle_MXM_Black_F",["30Rnd_65x39_caseless_black_mag",5],["acc_flashlight","optic_Hamr","muzzle_snds_h"]],
["weapon","arifle_MX_GL_Black_F",["30Rnd_65x39_caseless_black_mag",5],["acc_flashlight","optic_aco_smg"]],
["weapon","srifle_LRR_F",["7Rnd_408_Mag",3],["optic_LRPS"]],
["weapon","srifle_EBR_F",["20Rnd_762x51_Mag",3],["acc_flashlight","muzzle_snds_B","optic_MRCO"]],
["weapon","LMG_Mk200_F",["200Rnd_65x39_cased_Box",2],["acc_flashlight","optic_Holosight","bipod_01_F_blk"]],
["weapon","LMG_Zafir_F",["150Rnd_762x54_Box",2],["optic_aco_smg"]]
];

// Airdrop loadouts amount in each airdrop
airdropLoadoutsAmount = 1;



// -- Spawn options -- //

// Player uniforms
uniforms = ["U_BG_Guerrilla_6_1","U_BG_Guerilla1_1","U_BG_Guerilla2_2","U_BG_Guerilla3_1","U_BG_Guerilla2_1","U_BG_Guerilla2_3"];

missionNamespace setVariable ["uniformsConfig",uniforms,true];

// Player headgears
headgears = ["H_Shemag_olive","H_ShemagOpen_tan","H_Cap_oli","H_Booniehat_khk","H_Bandanna_gry","H_Beret_blk"];

missionNamespace setVariable ["headgearsConfig",headgears,true];

// Player vests
vests = ["V_Rangemaster_belt"];

missionNamespace setVariable ["vestsConfig",vests,true];

// Detective loadout ("" means nothing) 
// ["Uniform","Vest","Headgear",["primaryWeapon","MagazineClassname","Amount"],["sideArm","MagazineClassname","Amount"]]
detectiveLoadout = ["U_B_GEN_Soldier_F","V_TacVest_blk_POLICE","H_Beret_02",["arifle_MXM_Black_F","30Rnd_65x39_caseless_black_mag",3],["","",0]];

missionNamespace setVariable ["detectiveConfig",detectiveLoadout,true];

// -- Loot options -- //

// Spawnable primary weapons
lootPriWeapons = ["SMG_01_F","SMG_02_F","hgun_PDW2000_F","SMG_03_TR_camo","SMG_03_black","arifle_Mk20C_plain_F","arifle_SDAR_F","arifle_TRG20_F","SMG_03C_TR_Black","SMG_03C_Black","arifle_SDAR_F","SMG_05_F","sgun_HunterShotgun_01_F","sgun_HunterShotgun_01_sawedoff_F"];

// Spawnable secondary weapons
lootSecWeapons = ["hgun_Pistol_heavy_01_F","hgun_ACPC2_F","hgun_P07_F","hgun_Rook40_F","hgun_Pistol_heavy_02_F","hgun_P07_blk_F","hgun_P07_khk_F","hgun_Pistol_01_F","hgun_Pistol_heavy_01_green_F"];

// Blacklisted attachments
lootAttachments = ["optic_AMS","optic_AMS_khk","optic_AMS_snd","optic_DMS","optic_DMS_ghex_F","optic_DMS_weathered_F","optic_DMS_weathered_Kir_F","optic_KHS_blk","optic_KHS_hex","optic_KHS_old","optic_KHS_tan","optic_LRPS","optic_LRPS_ghex_F","optic_LRPS_tna_F","optic_NVS","optic_NIGHTSTALKER","optic_tws","optic_tws_mg"];

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

//Toggle For Jester
JesterEnabled = true;

//Percentage chance Of Jester Spawning
JesterPercentagechance = 0.25;

//Lower Bound For Chance of Traitor Numbers
TraitorPercentageChanceLowerBound = 0.25;

//Higher Bound For Chance of Traitor Numbers
TraitorPercentageChanceHigherBound = 0.45;

diag_log ("Config loaded");