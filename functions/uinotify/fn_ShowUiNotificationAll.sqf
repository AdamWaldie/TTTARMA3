/*
 * Broadcasts a WMP notification card to every currently connected player, via
 * a targeted remoteExec PER PLAYER rather than remoteExec's "-2" (all
 * clients) target.
 *
 * Identify Body's "BODY FOUND"/"BODY IDENTIFIED" cards, sent this way,
 * confirmed live to never render on ANY machine at all - not queued, not
 * delayed, genuinely never delivered, on this mission's actual hosting
 * setup - while a remoteExec targeted at one specific player object is the
 * exact mechanism the round-start briefing card (Waldo_fnc_showRoleCard)
 * already uses and which DOES work reliably. Rather than keep chasing
 * exactly why "-2" doesn't deliver here, every mission-wide broadcast now
 * goes through this instead, using the mechanism already proven to work.
 *
 * Arguments: same as Waldo_fnc_ShowUiNotification (title, message, state,
 * duration, placement, channel, source, ...)
 * Return Value: None
 * Example: ["TITLE", "message", "INFO", 8, "TOP_RIGHT", "CHANNEL"] call Waldo_fnc_ShowUiNotificationAll;
 */
private _args = _this;
{ _args remoteExec ["Waldo_fnc_ShowUiNotification", _x]; } forEach allPlayers;
