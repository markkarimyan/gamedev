# Campus Comedy Duel Issue Drafts

Publishing blocker: GitHub returned `403 Resource not accessible by integration` when creating issues in `markkarimyan/gamedev`. No issues were created.

Apply the `needs-triage` label to each issue when publishing.

## 1. Add ultimate charge, inputs, and HUD meters

## What to build

Add the first reusable ultimate-system slice to the existing local 1v1 match: each player gains ultimate charge over time and from combat, can activate only when ready, resets charge at round start, and sees readiness in the HUD. Player 1 should use `G`; Player 2 should use `Right Shift`.

## Acceptance criteria

- [ ] Player 1 and Player 2 each have ultimate charge state that resets at the start of every round.
- [ ] Ultimate charge increases slowly over time while a round is active.
- [ ] Ultimate charge increases when a player deals damage and also when a player takes damage.
- [ ] Ultimate activation is gated by readiness and the correct player-specific input (`G` for Player 1, `Right Shift` for Player 2).
- [ ] The HUD shows ultimate charge and a clear ready state for both players.
- [ ] Existing movement, shooting, pickups, round scoring, win condition, restart, and menu behavior still work.

## Blocked by

None - can start immediately.

## 2. Add match cinematic freeze state for ultimates

## What to build

Add an explicit match-level cinematic freeze state for ultimate activations so player control, bullets, pickups, hazards, and ultimate timing pause predictably while short ultimate setup moments play.

## Acceptance criteria

- [ ] The match can enter and exit a cinematic freeze state during an active round.
- [ ] Player control is disabled during the cinematic freeze and restored afterward.
- [ ] Gameplay effects do not damage or move players while they cannot control their character.
- [ ] Existing round end, restart, menu, score, and win-screen transitions still behave correctly.
- [ ] The freeze state exposes a clear integration point for player-specific ultimate effects to resolve after the cinematic ends.

## Blocked by

Issue 1.

## 3. Implement Player 1 car-summon ultimate

## What to build

Implement Player 1's red-hat car-summon ultimate using the shared ultimate system: a short cinematic setup, a clear telegraph, then an off-screen horizontal car sweep in Player 1's facing direction that damages and knocks back only the opponent.

## Acceptance criteria

- [ ] Player 1 can trigger the car ultimate only when ultimate charge is ready.
- [ ] Activation starts with a short cinematic/freeze setup before the attack can hit.
- [ ] The car enters from off-screen and travels horizontally in Player 1's facing direction.
- [ ] The car ignores Player 1 and can hit Player 2 for heavy damage and knockback.
- [ ] The attack is telegraphed enough for Player 2 to react after control resumes.
- [ ] The car ultimate cleans itself up after the sweep and does not break later rounds.

## Blocked by

Issues 1 and 2.

## 4. Implement Player 2 coffee overdrive ultimate

## What to build

Implement Player 2's coffee overdrive ultimate using the shared ultimate system: a short drink cinematic, then a temporary overdrive with faster movement, stronger jumping, faster shooting, and a short crash afterward with reduced movement.

## Acceptance criteria

- [ ] Player 2 can trigger coffee overdrive only when ultimate charge is ready.
- [ ] Activation starts with a short drink cinematic/freeze before buffs begin.
- [ ] Overdrive temporarily increases movement speed, jump strength, and shooting rate.
- [ ] Overdrive does not add invincibility, lifesteal, teleporting, or massive damage multipliers.
- [ ] A short crash state follows overdrive and temporarily reduces movement speed.
- [ ] All overdrive and crash modifiers clean up on expiration and round reset.

## Blocked by

Issues 1 and 2.

## 5. Add ultimate prototype playtest checklist

## What to build

Add a focused manual validation checklist for the systems-first ultimate prototype, covering charge gain, readiness, cinematic freeze behavior, car damage/knockback, coffee buff/crash timing, cleanup, and existing round flow.

## Acceptance criteria

- [ ] The checklist covers same-keyboard input for shooting, jumping, and ultimate activation.
- [ ] The checklist verifies ultimate charge gain from time, dealing damage, and taking damage.
- [ ] The checklist verifies round-start charge reset and cleanup of active ultimate effects.
- [ ] The checklist verifies car ultimate telegraph, damage, knockback, and non-instant-kill tuning.
- [ ] The checklist verifies coffee overdrive buff duration, crash duration, and modifier cleanup.
- [ ] The checklist verifies existing score, round, restart, menu, pickup, and win-screen behavior.

## Blocked by

Issues 3 and 4.

## 6. Convert the current arena into a reusable hand-built arena pattern

## What to build

Refactor the single current `Game.tscn` arena structure into a reusable hand-built arena pattern that separates decorative backgrounds from authored gameplay geometry, spawns, platforms, pickups, and future hazards.

## Acceptance criteria

- [ ] Gameplay collision, platforms, spawns, and pickups remain authored separately from the decorative background.
- [ ] The current arena can still be played as before after the restructuring.
- [ ] Arena data or scenes provide clear places for background, platforms, spawns, pickups, and one future gimmick.
- [ ] Players, bullets, pickups, platforms, and HUD remain readable over the background.
- [ ] Existing first-to-three round flow and round reset behavior still work.

## Blocked by

Issue 5.

## 7. Randomize hand-built arenas between rounds

## What to build

Add random hand-built arena selection between rounds once the reusable arena pattern exists, preserving the current first-to-three flow and clean round resets.

## Acceptance criteria

- [ ] A match can choose from multiple authored arena definitions or scenes.
- [ ] A new arena can be selected between rounds without requiring a level-select menu.
- [ ] Player spawns, pickups, platforms, and background update correctly for the selected arena.
- [ ] Ultimate charge still resets every round, including when the arena changes.
- [ ] Existing score progression, round messages, and win condition remain intact.

## Blocked by

Issue 6.

## 8. Add a campus courtyard starter arena

## What to build

Add a balanced campus courtyard arena as a starter map with a decorative pixel-style background, separately authored fair gameplay geometry, readable platforms, predictable pickup placement, and no more than one simple gimmick.

## Acceptance criteria

- [ ] The courtyard arena appears in the random arena pool.
- [ ] The arena uses campus-themed decorative art while keeping collision and platforms authored separately.
- [ ] Spawn positions are mirrored or otherwise fair for both players.
- [ ] Pickup positions are predictable and readable.
- [ ] The arena has no more than one major readable gimmick, or no gimmick if balance needs a baseline.
- [ ] Players, bullets, pickups, ultimates, and hazards remain visually readable over the background.

## Blocked by

Issues 6 and 7.

## 9. Add a cafeteria arena with one readable gimmick

## What to build

Add a campus cafeteria arena to the random arena pool with one readable comedy gimmick, while keeping combat legible and preserving separately authored platforms, spawns, pickups, and collision.

## Acceptance criteria

- [ ] The cafeteria arena appears in the random arena pool.
- [ ] The arena has a clear campus cafeteria identity using decorative pixel-style visuals.
- [ ] Collision and platforms are authored separately from the background.
- [ ] Spawn and pickup placement remains fair and predictable.
- [ ] The arena includes no more than one major readable gimmick.
- [ ] Existing movement, shooting, pickups, and ultimates remain understandable in the arena.

## Blocked by

Issues 6 and 7.

## 10. Choose and add the third campus arena concept

## What to build

Choose the third campus arena concept, such as library or rooftop, then add it to the random arena pool with fair authored geometry, readable visuals, and one major gimmick at most.

## Acceptance criteria

- [ ] The third arena concept is approved before implementation.
- [ ] The arena appears in the random arena pool.
- [ ] The arena has a clear campus comedy identity.
- [ ] Collision, platforms, spawns, pickups, and any gimmick are authored separately from the background.
- [ ] The arena has no more than one major readable gimmick.
- [ ] Gameplay readability is preserved for players, bullets, pickups, ultimates, and hazards.

## Blocked by

Issues 6 and 7.

## 11. Add one new funny pickup to the arena loop

## What to build

Choose and implement one new campus-comedy pickup that extends the existing pickup model without overwhelming the duel, including readable visuals, a temporary or clear effect, cleanup, and round reset behavior.

## Acceptance criteria

- [ ] The pickup concept is approved before implementation.
- [ ] The pickup is integrated into the existing `Pickup` scene/script pattern.
- [ ] The pickup effect is funny, readable, and temporary or otherwise clearly bounded.
- [ ] The effect expires or resets cleanly at round start.
- [ ] Pickup visuals and label/icon language are readable during combat.
- [ ] Existing weapon, rapid-fire, jump-boost, and medkit pickups still work.

## Blocked by

Issue 5.

## 12. Do a campus comedy readability and naming pass

## What to build

Review the implemented prototype for visual readability, campus-comedy cohesion, and public-facing naming choices, especially car and energy-drink references that may need parody treatment before public release.

## Acceptance criteria

- [ ] Player, bullet, pickup, ultimate, hazard, platform, and background readability are reviewed across arenas.
- [ ] HUD ultimate meters and readiness prompts are understandable during fast play.
- [ ] Arena names, pickup names, and ultimate names fit the campus comedy tone.
- [ ] Real-world brand references are replaced or marked for replacement before public release.
- [ ] Any required follow-up issues for art, naming, tuning, or legal/product review are created.

## Blocked by

Issues 3, 4, 8, 9, 10, and 11.
