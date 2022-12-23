
["Armour Provided Target"] remotexec ["hintsilent",-2];
removeVest cursorTarget;
cursorTarget addVest "V_TacVest_blk";

player setVariable ["powerup","bodyArmour",false];
waituntil {!isnull (finddisplay 46)};
(findDisplay 46) displayRemoveAllEventHandlers "KeyDown";
_shop = findDisplay 46 displayAddEventHandler ["KeyDown", {_this select 1 execVM "shops.sqf"}];