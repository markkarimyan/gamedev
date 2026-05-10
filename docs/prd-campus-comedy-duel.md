## Problem Statement

Pixel Duel Arena already works as a small same-keyboard local multiplayer arena fighter, but it currently has only one core arena flow and generic combat/pickup variety. The next version needs a clearer product identity: a funny, coherent, pixel-art campus comedy duel where each player feels characterful, levels vary round to round, and signature ultimate abilities create memorable moments without making matches unfair or unreadable.

From the player's perspective, the game should feel more like a polished local 1v1 party duel: quick to understand, funny to watch, easy to replay, and visually consistent across characters, levels, pickups, and effects.

## Solution

Expand Pixel Duel Arena into a local same-machine 1v1 pixel comedy duel with hand-built campus-themed arenas, random arena variety between rounds, funny pickups, simple arena-specific hazards, and asymmetric cinematic ultimate abilities for each player.

The game keeps its existing foundation: two players, same-keyboard controls, health, shooting, jumping, pickups, round scoring, HUD, main menu, and win screen. The new layer adds stronger identity and replayability:

- A unified campus comedy theme for arenas and backgrounds.
- Decorative pixelized backgrounds with separate gameplay collision and foreground platforms for fairness.
- Hand-built arenas with one strong readable gimmick each.
- Pickup-based comedy powerups that extend the current pickup model.
- Player-specific ultimate abilities with short cinematic pauses.
- Ultimate charge meters and clear input prompts in the HUD.
- A first playable systems slice that validates whether the two signature ultimates make the duel fun before investing heavily in more content.

## User Stories

1. As a local player, I want to fight another player on the same keyboard, so that we can play quick 1v1 matches together on one machine.
2. As a local player, I want the game to stay round-based and first-to-three, so that matches remain short, competitive, and easy to replay.
3. As a local player, I want different arenas to appear across rounds, so that each match has variety without requiring menu setup.
4. As a local player, I want arenas to be hand-built instead of random, so that each level feels fair, readable, and intentionally designed.
5. As a local player, I want each arena to have a campus comedy identity, so that the game feels like one coherent world instead of unrelated mini-games.
6. As a local player, I want new backgrounds to be pixelized into the same visual style, so that every level looks like it belongs in the same game.
7. As a local player, I want backgrounds to be decorative while platforms and collisions are built separately, so that I can always tell what is playable and what is just scenery.
8. As a local player, I want players, pickups, bullets, hazards, and platforms to remain visually readable over the background, so that combat decisions are clear during fast moments.
9. As Player 1, I want a signature car-summon ultimate, so that my character has a ridiculous memorable ability beyond normal shooting.
10. As Player 1, I want the car ultimate to have a short cinematic setup, so that it feels dramatic and funny when triggered.
11. As Player 1, I want the car to enter from off-screen and drive horizontally in my facing direction, so that the attack is powerful but understandable.
12. As Player 1, I want the car ultimate to deal heavy damage and knockback without being an instant guaranteed kill, so that it feels strong without ending rounds unfairly.
13. As Player 2, I want a Red Bull coffee ultimate, so that my character has a distinct chaotic power fantasy.
14. As Player 2, I want the match to pause during the drink animation, so that the ultimate has a funny cinematic moment before gameplay resumes.
15. As Player 2, I want the coffee ultimate to grant temporary speed, jumping, and shooting boosts, so that I feel intensely powered up for a short burst.
16. As the defending player, I want ultimate attacks to happen after the cinematic pause, so that I am not damaged while I cannot control my character.
17. As the defending player, I want ultimates to be telegraphed, so that I have a chance to dodge, reposition, or survive.
18. As either player, I want ultimates to charge gradually through time and combat, so that both players eventually get a signature moment during longer rounds.
19. As a losing player, I want taking damage to contribute to ultimate charge, so that I have a comeback opportunity instead of only falling further behind.
20. As a winning player, I want dealing damage to contribute to ultimate charge, so that aggressive play still feels rewarded.
21. As either player, I want ultimate charge to reset each round, so that each round starts clean and is easy to understand.
22. As Player 1, I want to trigger my ultimate with a key near my existing shooting controls, so that the ability is easy to use during combat.
23. As Player 2, I want to trigger my ultimate with a key near my existing movement/shooting area, so that the ability is reachable on a shared keyboard.
24. As either player, I want the HUD to show ultimate readiness, so that I know when my signature skill is available.
25. As either player, I want funny pickups to continue existing, so that arena control and surprise moments remain part of the duel.
26. As either player, I want each arena to have no more than one major gimmick at first, so that matches stay readable rather than chaotic.
27. As a player learning the game, I want the base movement, shooting, and pickups to remain familiar, so that the new comedy systems do not erase the existing game.
28. As a spectator, I want ultimates and hazards to be visually funny and readable, so that watching a round is entertaining even before mastering the controls.
29. As the game creator, I want the first implementation slice to focus on the ultimate system before extra arenas, so that future content is built around a proven combat loop.
30. As the game creator, I want placeholder visuals to be acceptable during prototyping, so that gameplay can be validated before final pixel assets are produced.

## Implementation Decisions

- Preserve the current local same-keyboard 1v1 match structure, round scoring, health model, shooting, jumping, pickups, main menu, HUD, and win screen.
- Build a systems-first prototype before producing all arena content. The first systems slice should include ultimate charge, ultimate input, cinematic match freeze, HUD meters, the car ultimate, and the coffee overdrive ultimate.
- Treat Player 1 as the red-hat/car-summon character and Player 2 as the coffee/Red Bull overdrive character unless character assignment changes later.
- Add a reusable ultimate system to the player/match model rather than hardcoding one-off effects only in scene logic. The system should support charge, readiness, activation, cinematic timing, effect execution, and post-effect cleanup.
- Add an explicit match cinematic/freeze state so player control, bullets, hazards, pickups, and ultimate timing behave predictably while an ultimate animation is playing.
- During cinematic pauses, player control should be disabled and active gameplay should stop. Ultimate effects should resolve only after the cinematic ends.
- Ultimate charge should be hybrid: slow passive gain, bonus gain from dealing damage, and comeback gain from taking damage.
- Ultimate charge should reset at the beginning of each round for clarity.
- Player 1 ultimate input should be G.
- Player 2 ultimate input should be Right Shift.
- The car ultimate should be a telegraphed horizontal sweep from off-screen in the summoning player's facing direction. It should heavily damage and knock back the opponent while ignoring the summoning player.
- The car should not be an unavoidable instant kill. Its strength should come from timing, positioning, and forcing the opponent to react.
- The coffee ultimate should pause the match for a short drink animation, then grant a temporary overdrive state with faster movement, stronger jumping, and faster shooting.
- Coffee overdrive should include a short crash afterward with reduced movement speed. The first version should not include invincibility, lifesteal, teleporting, or massive damage multipliers.
- Add HUD support for ultimate charge and readiness for both players.
- Keep backgrounds decorative and build gameplay geometry separately. Collision, platforms, hazards, spawns, and pickups should be authored in Godot rather than inferred from background images.
- Use hand-built campus-themed arenas. Each arena should have a small number of clear platforms, fair mirrored or equivalent spawn logic, predictable pickup placement, and one readable gimmick at most in the first version.
- Use random arena selection between rounds once multiple arenas exist. The initial implementation may use duplicated or placeholder arena data until final backgrounds and layouts are ready.
- Keep the visual style unified: pixel-art scaling, crisp texture filtering, bright readable players and combat effects, lower-contrast decorative backgrounds, and consistent platform/hazard language.
- Future real-world brand references should be reviewed before public release. The Honda Insight and Red Bull references are acceptable for private ideation, but a public build may need parody naming and original visual designs.

## Testing Decisions

- Tests should focus on external game behavior rather than internal implementation details. Good tests should verify outcomes such as charge gain, ultimate readiness, freeze behavior, effect timing, damage/knockback, buff duration, crash duration, and round reset behavior.
- Player behavior should be tested around movement-affecting states, combat damage, charge changes, ultimate activation gating, coffee overdrive modifiers, and cleanup after buffs/crashes.
- Match management should be tested around round start/reset, cinematic freeze entry/exit, player control disabling/enabling, score progression, and win condition preservation.
- HUD behavior should be tested around health, score, round display, message display, and new ultimate meter/readiness display.
- Projectile and hit behavior should be tested where ultimate charge depends on dealing/taking damage, so that charge gains remain tied to successful combat outcomes.
- Pickup behavior should continue to be validated when adding funny powerups, especially that temporary effects expire and round resets restore a clean baseline.
- There is no existing automated test suite in the project. Initial validation may rely on focused manual playtest checklists in Godot, followed by lightweight automated tests if a Godot test framework is added later.
- Manual test prior art should mirror current gameplay surfaces: same-keyboard input, round reset, health bars, score tracking, pickups, bullet hits, knockback, and win screen transitions.

## Out of Scope

- Online multiplayer.
- Single-player or co-op PvE enemies.
- Procedurally generated arenas.
- Full level-select UI for the first slice.
- Final polished pixel art for every new arena before systems validation.
- Final brand/legal treatment for car and energy drink references.
- Complex character roster beyond the two current players.
- Advanced AI, progression, inventory, campaign structure, or unlock systems.
- Multiple hazards per arena in the first version.
- Invincibility, lifesteal, teleporting, or other high-complexity coffee ultimate effects in the first version.

## Further Notes

- Inferred assumption: "local co-op 1v1" means same-machine local competitive play, not cooperative PvE.
- Inferred assumption: Player 1 maps to the red-hat/car ultimate character and Player 2 maps to the coffee/Red Bull ultimate character.
- Inferred assumption: incoming background images will be converted into pixel-style decorative backdrops and then paired with separately-authored gameplay geometry.
- Suggested first arenas after systems validation: campus courtyard as the balanced starter, cafeteria as a slippery/hazard arena, and library or rooftop as a readable gimmick arena.
- The key product question for the prototype is: does the duel become funnier and more memorable when each player has one cinematic signature ultimate while the core combat remains readable and fair?
