//////////////////////////////////////////////////////////////////
// Equipment Config - WW2 (Northen Fronts Edition)
// Last update by: Waldo 28DEC2022
//////////////////////////////////////////////////////////////////


// --  Airdrop loadouts -- //

// ["weapon","WeaponClassname",["MagazineClassname","Amount"],["Attachment1","Attachment2"]]
airdropLoadouts = [
["weapon","NORTH_ls26",["NORTH_20Rnd_ls26_mag",5],[]],
["weapon","NORTH_kp31_sjr",["NORTH_20rnd_kp31_mag",3],[]],
["weapon","EAW_Type97_Sniper",["EAW_Type38_Magazine",3],["eaw_type97_sniper_scope"]],
["weapon","EAW_Type99",["EAW_Type99_Magazine",2],[]],
["weapon","NORTH_AVT40",["NORTH_10rnd_SVT_mag",2],[]]
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
lootPriWeapons = ["NORTH_fin_M27","NORTH_fin_M28","NORTH_fin_m39_optics","NORTH_nor_smle""EAW_C96_Carbine","NORTH_SVT40","JMSSA_carcano1891_Rifle","CSA38_M1895DE","CSA38_kar98k","CSA38_No4","LIB_M1_Garand","LIB_M1A1_Carbine"];

// Spawnable secondary weapons
lootSecWeapons = ["LIB_Colt_M1911","JMSSA_M1934_pistol","NORTH_TT33","NORTH_m1895","EAW_C96_Auto","EAW_C96","NORTH_M1914","NORTH_m1893","EAW_Type14"];

// Blacklisted attachments
lootAttachments = ["eaw_type97_sniper_scope"];

// -- Buy Menu -- //

//Rocket Launcher/Heavy weapon to give on the launcher puchase
traitorLauncher = "LIB_M1A1_Bazooka";
traitorLauncherMagazine = "LIB_1Rnd_60mm_M6";

missionNamespace setVariable ["TraitorLauncher",traitorLauncher,true];
missionNamespace setVariable ["TraitorLauncherMag",traitorLauncherMagazine,true];

// Long Rifle/ Sniper rifle weapon to give on purchase
traitorRifle = "EAW_Type97_Sniper";
traitorRifleMagazine = "EAW_Type38_Magazine";
traitorRifleOptics = "eaw_type97_sniper_scope";

missionNamespace setVariable ["TraitorRifle",traitorRifle,true];
missionNamespace setVariable ["TraitorRifleMag",traitorRifleMagazine,true];
missionNamespace setVariable ["TraitorRifleOptics",traitorRifleOptics,true];