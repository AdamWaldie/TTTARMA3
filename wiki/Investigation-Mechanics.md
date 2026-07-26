# Investigation Mechanics

## DNA scanner and contamination

Every kill leaves DNA (`Waldo_fnc_onKilled` tags the body, and the weapon holders the engine drops near it a moment later, with `Waldo_killerDNA`). A Detective's DNA Scanner samples a body or a piece of evidence within 4m and starts a hot/cold track: distance and compass bearing to the suspect, refreshed once a second.

Two things stop this from being a free read:

- **Decay.** The older the sample, the shorter the track you get. A fresh kill gives a longer track than one investigated ten minutes later.
- **Contamination.** For 90 seconds after a body or item appears, every different player (Detectives excluded, since the scanner itself requires standing inside the contamination radius) who comes within 3m counts as a witness. Each witness raises the odds the reading misdirects onto a random living non-culprit instead of the real suspect. The Detective is told the scene is contaminated but never told whether this particular reading is the real one, that judgment call is the actual investigation.

**Enhanced Scanner** (a Detective passive) halves the misdirection chance, extends both the maximum and minimum track duration, and adds a forensic line when scanning a body: time since death and the murder weapon.

## Identify Body

Calling in a corpse (a scroll action added to every body) always confirms the death to the whole server. Revealing the victim's *role* is different: only a Detective's identification does that (`Waldo_roleRevealed`). A non-Detective finding the body first announces "found" once and does not consume the action, so a Detective who arrives later can still get the role reveal. Only a Detective's call retires the action for good. This also drives the in-round scoreboard's "confirmed dead" count.

## Dead Ringer (Traitor)

Arms a 25-second window where the next lethal hit you take is faked instead of killing you. A `HandleDamage` guard installed once per life (see [Architecture](Architecture) for why this needs reinstalling after a revive) caps the actual damage, then `Waldo_fnc_deadRingerTrigger` sells it: you ragdoll (`setUnconscious`, `allowDamage false`) and a decoy corpse spawns nearby, dressed from the spawn loadout pool and tagged role Innocent so anyone investigating it is misled. You're down and vulnerable for 20 seconds, not invisible, before getting back up.

## False Flag (Traitor)

A passive that arms your next kill to leave a random living innocent's DNA at the scene instead of yours. Consumed on the next kill regardless of whether it lands on a Detective's radar.

## Body Remover (Traitor)

Destroys a corpse outright. No DNA, no Identify Body, no forensic trail at all, at the cost of a shop slot and the time it takes to walk up and use it.
