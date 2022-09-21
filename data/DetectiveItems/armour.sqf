
["Armour Provided To All!"] remotexec ["hintsilent",-2];

{
	_x addVest (selectRandom ["V_TacVest_blk","V_TacVest_brn","V_TacVest_oli","V_I_G_resistanceLeader_F"]);
	
} forEach  allPlayers;