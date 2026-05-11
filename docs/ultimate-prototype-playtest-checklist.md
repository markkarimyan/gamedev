# Ultimate Prototype Playtest Checklist

Use this checklist for a focused manual validation pass in Godot after changing the ultimate system, round flow, pickups, or HUD. Test with two players on the same keyboard in `scenes/Game.tscn`.

Current prototype mapping:

- Player 1: `A` / `D` move, `W` jump and double jump, `F` shoot, `G` coffee overdrive ultimate.
- Player 2: `Left` / `Right` move, `Up` jump and double jump, `Right Ctrl` or `Numpad 0` shoot, `Right Shift` car ultimate.
- Match: `R` restarts the match, `Esc` returns to the main menu.

## Setup

- [ ] Launch the project in Godot 4 and start a match from the main menu.
- [ ] Confirm both players spawn at full health with empty ultimate meters.
- [ ] Confirm the HUD shows health, score, round number, ultimate meters, and no stale round message.
- [ ] Confirm both players can move, jump, double jump, shoot, and activate ultimates using the same keyboard layout above.

## Ultimate Charge And Readiness

- [ ] Let both players idle in an active round and confirm both ultimate meters gain charge over time.
- [ ] Have Player 1 shoot Player 2 and confirm Player 1 gains charge for dealing damage.
- [ ] Confirm Player 2 gains charge from taking that damage.
- [ ] Have Player 2 shoot Player 1 and confirm Player 2 gains charge for dealing damage.
- [ ] Confirm Player 1 gains charge from taking that damage.
- [ ] Try `G` before Player 1 is ready and confirm no ultimate starts and the meter is not consumed.
- [ ] Try `Right Shift` before Player 2 is ready and confirm no ultimate starts and the meter is not consumed.
- [ ] Fill or wait for each meter and confirm the HUD changes to the ready state for that player.
- [ ] Activate each ready ultimate and confirm its meter is consumed immediately.

## Cinematic Freeze

- [ ] Activate Player 1's ultimate with `G` and confirm player control is disabled during the short cinematic setup.
- [ ] Activate Player 2's ultimate with `Right Shift` and confirm player control is disabled during the short cinematic setup.
- [ ] During each cinematic setup, confirm bullets, pickups, player movement, and ultimate timing do not continue resolving.
- [ ] Confirm neither player can take damage while the match is in cinematic freeze.
- [ ] Confirm control returns cleanly when the cinematic setup ends.
- [ ] Confirm the ultimate effect begins only after the cinematic freeze ends.

## Car Ultimate

- [ ] Charge Player 2's meter to ready, face toward Player 1, and press `Right Shift`.
- [ ] Confirm the car attack starts with cinematic freeze before it can hit.
- [ ] Confirm a clear horizontal warning/telegraph appears after the cinematic setup.
- [ ] Confirm the car starts off-screen in Player 2's facing direction.
- [ ] Confirm Player 1 can react after control returns and before the car hit window.
- [ ] Confirm the car travels horizontally across the arena.
- [ ] Confirm the car ignores Player 2.
- [ ] Confirm the car deals heavy damage to Player 1 without being an instant kill from full health.
- [ ] Confirm Player 1 receives strong knockback in the sweep direction.
- [ ] Confirm the car cleans itself up after the sweep and does not leave collision, warning, or visual leftovers.

## Coffee Overdrive

- [ ] Charge Player 1's meter to ready and press `G`.
- [ ] Confirm coffee overdrive starts with a short cinematic drink/freeze before buffs begin.
- [ ] Confirm overdrive temporarily increases Player 1 movement speed.
- [ ] Confirm overdrive temporarily strengthens Player 1 jumping.
- [ ] Confirm overdrive temporarily increases Player 1 shooting rate.
- [ ] Confirm overdrive does not add invincibility, lifesteal, teleporting, or a large damage multiplier.
- [ ] Confirm the overdrive buff lasts for its intended short burst, currently about 2.2 seconds.
- [ ] Confirm a crash state follows overdrive, currently about 0.85 seconds.
- [ ] Confirm the crash temporarily reduces Player 1 movement speed.
- [ ] Confirm jump strength and shooting rate return to normal during or after the crash as intended.
- [ ] Confirm all coffee modifiers clear after the crash expires.

## Round Reset And Cleanup

- [ ] End a round while no ultimate is active and confirm both players respawn with full health and empty ultimate meters.
- [ ] End a round while a car ultimate is active and confirm the next round has no lingering car, telegraph, damage, or collision.
- [ ] End a round while coffee overdrive is active and confirm the next round starts with normal movement, jump, shooting, and no crash state.
- [ ] End a round while coffee crash is active and confirm the next round starts with normal movement speed.
- [ ] Confirm round start always resets ultimate charge for both players.
- [ ] Confirm player control is enabled at the start of every active round.

## Existing Match Flow

- [ ] Confirm health bars update when bullets and ultimates deal damage.
- [ ] Confirm normal bullet damage and knockback still work for both players.
- [ ] Confirm pickups can still be collected and apply their expected effects.
- [ ] Confirm temporary pickup effects still expire or reset cleanly between rounds.
- [ ] Confirm the score increments for the round winner only.
- [ ] Confirm the round number advances after each non-final round.
- [ ] Confirm `R` restarts the match from a clean state.
- [ ] Confirm `Esc` returns to the main menu.
- [ ] Confirm the first player to 3 round wins reaches the win screen.
- [ ] From the win screen, confirm restart and menu actions still work.

## Notes

- Record any tuning observations where the car feels unavoidable, instantly lethal, too weak, or unclear.
- Record any timing observations where coffee overdrive or crash duration feels too short, too long, or hard to read.
- Record any readability issues where HUD ready prompts, telegraphs, bullets, pickups, or players are hard to see during fast play.
