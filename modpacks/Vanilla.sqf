//////////////////////////////////////////////////////////////////
// Equipment Config - Vanila
//////////////////////////////////////////////////////////////////


// --  Airdrop loadouts -- //

// ["weapon","WeaponClassname",["MagazineClassname","Amount"],["Attachment1","Attachment2"]]
airdropLoadouts = [
["weapon","arifle_MXM_Black_F",["30Rnd_65x39_caseless_black_mag",5],["acc_flashlight","optic_Hamr","muzzle_snds_h"]],
["weapon","srifle_LRR_F",["7Rnd_408_Mag",3],["optic_LRPS"]],
["weapon","srifle_EBR_F",["20Rnd_762x51_Mag",3],["acc_flashlight","muzzle_snds_B","optic_MRCO"]],
["weapon","LMG_Mk200_F",["200Rnd_65x39_cased_Box",2],["acc_flashlight","optic_Holosight","bipod_01_F_blk"]],
["weapon","LMG_Zafir_F",["150Rnd_762x54_Box",2],["optic_aco_smg"]]
];

// -- Spawn Equipment options -- //

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

// -- Buy Menu -- //

//Rocket Launcher/Heavy weapon to give on the launcher puchase
traitorLauncher = "launch_NLAW_F";
traitorLauncherMagazine = "NLAW_F";

missionNamespace setVariable ["TraitorLauncher",traitorLauncher,true];
missionNamespace setVariable ["TraitorLauncherMag",traitorLauncherMagazine,true];

// Long Rifle/ Sniper rifle weapon to give on purchase
traitorRifle = "srifle_LRR_F";
traitorRifleMagazine = "7Rnd_408_Mag";
traitorRifleOptics = "optic_LRPS";

missionNamespace setVariable ["TraitorRifle",traitorRifle,true];
missionNamespace setVariable ["TraitorRifleMag",traitorRifleMagazine,true];
missionNamespace setVariable ["TraitorRifleOptics",traitorRifleOptics,true];