//////////////////////////////////////////////////////////////////
// Waldo_fnc_setupBriefing
// CLIENT: writes a "How To Play" diary (map screen -> Notes) once per
// session, so a new player has a rules reference in-mission instead of
// needing the wiki open in a second window. Static content - nothing here
// depends on role or round state, so it's safe to call once, early, well
// before roles are even assigned.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};

player createDiarySubject ["WaldoHowToPlay", "How To Play"];

player createDiaryRecord ["WaldoHowToPlay", [
	"Objective",
	"<t align='left'>Every round, everyone is secretly assigned a role. " +
	"<t color='#26bf1e'>Innocents</t> win when every Traitor is dead. " +
	"<t color='#bf3636'>Traitors</t> win by killing everyone who isn't a Traitor. " +
	"Nobody knows anyone else's role at the start except the Traitors, who know each other.<br/><br/>" +
	"Dying doesn't end your game - you drop into Spectator and can keep watching (and, per this " +
	"server's chat rules, keep talking to other dead players) until the round ends.</t>"
]];

player createDiaryRecord ["WaldoHowToPlay", [
	"The Round Clock & Overtime",
	"<t align='left'>Every round has a planned base length, shown as the round timer from the start. " +
	"Every death - anyone's - extends the clock a bit, so a round with a lot of killing runs longer than " +
	"a quiet one.<br/><br/>" +
	"Each extra death matters a little less than the last, though - there's no single death after which " +
	"extensions just stop, but a chaotic round can't run away forever either.<br/><br/>" +
	"Once the clock runs past its planned base length, that's <t color='#FFD166'>OVERTIME</t> - you'll see " +
	"a banner for it. The round is no longer running on its original timer at that point, only on however " +
	"much extra time the deaths so far have bought it.</t>"
]];

player createDiaryRecord ["WaldoHowToPlay", [
	"The Roles",
	"<t align='left'>" +
	"<t color='#26bf1e'>Innocent</t> - the majority. No powers, no extra information - work it out from " +
	"behaviour, bodies, and what the Detective finds.<br/><br/>" +
	"<t color='#bf3636'>Traitor</t> - a hidden minority who know each other from the start. Shared credit " +
	"shop full of sabotage and counter-investigation tools. Win by killing everyone else.<br/><br/>" +
	"<t color='#02b3ff'>Detective</t> - a PUBLICLY known Innocent (everyone can see this role) with an " +
	"investigation shop: corpse testing, a DNA scanner, radar. Wins alongside the Innocents.<br/><br/>" +
	"<t color='#9a2ecc'>Jester</t> - deals no damage and can't win the normal way. The Traitors are told " +
	"who the Jester is. If anyone who ISN'T a Traitor kills the Jester, the Jester wins instead and " +
	"nobody else does.</t>"
]];

player createDiaryRecord ["WaldoHowToPlay", [
	"Investigation",
	"<t align='left'>Every kill leaves DNA on the body and nearby dropped gear. A Detective's DNA Scanner " +
	"samples it and gives a hot/cold distance-and-bearing track to the suspect - older samples and " +
	"witnesses contaminating the scene both weaken the read.<br/><br/>" +
	"Any player can scroll-wheel a corpse and use <t color='#ffd23f'>Identify Body</t> to call in a death " +
	"to the whole server. That alone doesn't reveal the victim's role - only a Detective's call-in does " +
	"that, and it's what moves the scoreboard's CONFIRMED DEAD count.<br/><br/>" +
	"Press K any time for the in-round scoreboard: who's alive, whose body has been found, kills this " +
	"round, and roles where you're allowed to know them.</t>"
]];

player createDiaryRecord ["WaldoHowToPlay", [
	"Shop & Credits",
	"<t align='left'>Traitors and Detectives earn credits over the round (and a bonus for a confirmed " +
	"enemy kill) to spend in their own role's shop: weapons, gear, and one-shot ACTIVATION items " +
	"(explosives, decoys, and the like).<br/><br/>" +
	"Activation items go on the Y/U/J keys via the buy menu - press the assigned key to use one. Buy more " +
	"than 3 and the extras queue up, backfilling a slot automatically as it frees up.</t>"
]];

player createDiaryRecord ["WaldoHowToPlay", [
	"Controls",
	"<t align='left'>" +
	"<t color='#ffd23f'>K</t> - Scoreboard<br/>" +
	"<t color='#ffd23f'>H</t> - Role crest style picker<br/>" +
	"<t color='#ffd23f'>L</t> - Holster weapon<br/>" +
	"<t color='#ffd23f'>B</t> - Buy menu (Traitor/Detective)<br/>" +
	"<t color='#ffd23f'>Y / U / J</t> - Use the activation item bound to that slot<br/>" +
	"<t color='#ffd23f'>T (hold)</t> - Ping wheel (Traitor)<br/><br/>" +
	"Scroll-wheel a corpse for Identify Body, or a Health Station / defusable charge for their own actions.</t>"
]];
