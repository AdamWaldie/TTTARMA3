//////////////////////////////////////////////////////////////////
// Waldo_fnc_setupDeadChatFilter
// CLIENT: installs ONE managed HandleChatMessage handler that keeps the
// living and the dead from talking to each other over text chat. Global,
// Side, Command, and Group are all shared-side channels every player has
// access to regardless of role, so without this a dead player (or a
// spectator who never even had a role yet) can type in Side chat and feed
// still-living players information mid-round.
//
// HandleChatMessage fires locally on every machine for every incoming chat
// message and can cancel it before it ever reaches that machine's chat feed
// (it does NOT fire for scripted systemChat/etc - see the wiki - so this
// can't eat this mission's own announcements). Rule: if the message's
// sender and this viewer aren't in the same alive/dead state, hide it. That
// also means the dead effectively get a free "dead chat" out of Global/Side
// for free - they can still see and talk to each other, just not to anyone
// still playing - with no extra channel setup needed.
//
// The handler id is stored so a second call replaces rather than stacks it.
//////////////////////////////////////////////////////////////////

if (!hasInterface) exitWith {};

private _old = missionNamespace getVariable ["Waldo_deadChatFilterEH", -1];
if (_old >= 0) then { removeMissionEventHandler ["HandleChatMessage", _old]; };

private _eh = addMissionEventHandler ["HandleChatMessage", {
	params ["_channel", "_owner", "_from", "_text", "_person"];

	// Only Global/Side/Command/Group are shared "everyone on this side" or
	// "everyone in this group" channels; Vehicle/Direct are already scoped
	// to who's physically present and don't need gating here.
	if (!(_channel in [0, 1, 2, 3])) exitWith { false };
	if (isNull _person) exitWith { false };   // system/connection messages, not a player's own line

	(alive player) != (alive _person)   // true -> block, mismatched alive/dead states
}];

missionNamespace setVariable ["Waldo_deadChatFilterEH", _eh];
