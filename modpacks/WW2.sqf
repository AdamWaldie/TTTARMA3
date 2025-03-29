//////////////////////////////////////////////////////////////////
// Equipment Config - WW2 (Northen Fronts Edition)
// Last update by: Waldo 28DEC2022
//////////////////////////////////////////////////////////////////


// --  Airdrop loadouts -- //

// ["weapon","WeaponClassname",["MagazineClassname","Amount"],["Attachment1","Attachment2"]]
airdropLoadouts = [
["weapon","LIB_MP40",["LIB_32Rnd_9x19",5],[]],
["weapon","JMSSA_bren2_Rifle",["JMSSA_30Rnd_770x56",3],[]],
["weapon","LIB_K98ZF39",["LIB_5Rnd_792x57",3],[]],
["weapon","LIB_FG42G",["LIB_20Rnd_792x57",4],[]],
["weapon","LIB_DELISLE",["LIB_7Rnd_45ACP_DeLisle",2],[]],
["weapon","JMSSA_thompson_Rifle",["JMSSA_30Rnd_45ACP",2],[]],
["weapon","CSA38_g98ii",["CSA38_7_92_5xMauser2",2],[]]
];

// -- Spawn Equipment options -- //

// Player uniforms
uniforms = ["JMSSA_brit_p37_clean_F_CombatUniform","JMSSA_brit_p37_cpl_F_CombatUniform","JMSSA_brit_p37_serg_F_CombatUniform","JMSSA_can_p37_1stRCR_lcpl_F_CombatUniform","JMSSA_scot_p37_cameron_F_CombatUniform","JMSSA_can_p37_1stRCR_serg_F_CombatUniform","JMSSA_can_p37_dirty_F_CombatUniform","JMSSA_can_p37_3rd7th_lcpl_F_CombatUniform","JMSSA_brit_p37_78th_lt_F_CombatUniform"];

missionNamespace setVariable ["uniformsConfig",uniforms,true];

// Player headgears
headgears = ["JMSSA_brit_mk2n_helmet","JMSSA_brit_mk2n2_helmet","JMSSA_brit_mk2n3_helmet","JMSSA_brit_mk3n2_helmet","JMSSA_brit_mk3n_helmet"];

missionNamespace setVariable ["headgearsConfig",headgears,true];

// Player vests
vests = ["JMSSA_brit_p37of","JMSSA_brit_p37crew"];

missionNamespace setVariable ["vestsConfig",vests,true];

// Detective loadout ("" means nothing) 
// ["Uniform","Vest","Headgear",["primaryWeapon","MagazineClassname","Amount"],["sideArm","MagazineClassname","Amount"]]
detectiveLoadout = ["JMSSA_brit_p37NA_lt_F_CombatUniform","JMSSA_brit_p37lt","JMSSA_brit_ofcap_khaki",["LIB_MP44","LIB_30Rnd_792x33",3],["","",0]];

missionNamespace setVariable ["detectiveConfig",detectiveLoadout,true];

// -- Loot options -- //

// Spawnable primary weapons
lootPriWeapons = ["JMSSA_carcano1891_Rifle","JMSSA_carcano1924_Rifle","CSA38_M1895DE","CSA38_kar98k","CSA38_No4","LIB_M1_Garand","LIB_M1A1_Carbine","CSA38_M1895H","CSA38_M1895k","LIB_G3340","LIB_G41","LIB_G43","LIB_K98_Late","LIB_LeeEnfield_No4","JMSSA_moschetto1891_Rifle","LIB_SVT_40"];

// Spawnable secondary weapons
lootSecWeapons = ["LIB_Colt_M1911","JMSSA_M1934_pistol","NORTH_TT33","NORTH_m1895","EAW_C96_Auto","EAW_C96","NORTH_M1914","NORTH_m1893","EAW_Type14","csa38_lp08","LIB_P38","LIB_TT33","csa38_czvz27","LIB_WaltherPPK","JMSSA_webleyVI_pistol","LIB_Welrod_mk1"];

// Blacklisted attachments
lootAttachments = ["eaw_type97_sniper_scope"];

// -- Buy Menu -- //

//Rocket Launcher/Heavy weapon to give on the launcher puchase
traitorLauncher = "LIB_PzFaust_60m";
traitorLauncherMagazine = "LIB_1Rnd_PzFaust_60m";

missionNamespace setVariable ["TraitorLauncher",traitorLauncher,true];
missionNamespace setVariable ["TraitorLauncherMag",traitorLauncherMagazine,true];

// Long Rifle/ Sniper rifle weapon to give on purchase
traitorRifle = "CSA38_g98ii";
traitorRifleMagazine = "CSA38_7_92_5xMauser2";
traitorRifleOptics = "csa38_sg84bayonet";

missionNamespace setVariable ["TraitorRifle",traitorRifle,true];
missionNamespace setVariable ["TraitorRifleMag",traitorRifleMagazine,true];
missionNamespace setVariable ["TraitorRifleOptics",traitorRifleOptics,true];