# Pixel Duel Arena

Pixel Duel Arena is a small Godot 4 local multiplayer arena fighter. Two players fight on the same keyboard in a single-screen pixel-style arena. Each player starts with 100 HP, uses themed guns, and the first player to win 3 rounds wins the match.

## How to run

1. Open Godot 4.
2. Choose **Import**.
3. Select this folder and open `project.godot`.
4. Press **Play**.

## Controls

Player 1:

- `A` / `D`: move
- `W`: jump
- Press `W` again in air: double jump
- `F`: shoot
- `G`: ultimate

Player 2:

- `Left` / `Right`: move
- `Up`: jump
- Press `Up` again in air: double jump
- `Right Ctrl` or `Numpad 0`: shoot
- `Right Shift`: ultimate

Match controls:

- `R`: restart match
- `Esc`: return to main menu

## Features

- Main menu
- One-screen arena
- Randomized hand-built arenas between rounds
- Two local players
- Movement, jumping, gun shooting
- Double jump
- Four-frame walking spritesheets and shooting recoil/flash
- Bullet hit detection
- French/Swedish-inspired fast rifle for Player 1
- Russian-inspired heavier rifle for Player 2
- Arena pickups for weapon swaps, rapid fire, medkits, and jump boost
- Health bars
- Ultimate charge meters and ready prompts
- Damage and knockback
- Round winner detection
- Score tracking
- First to 3 rounds wins
- Win screen with restart/menu options

## Playtesting

- `docs/ultimate-prototype-playtest-checklist.md`: focused manual validation for ultimate charge, cinematic freeze, car sweep, coffee overdrive, cleanup, and existing match flow.

## Project Structure

- `scenes/MainMenu.tscn`: title screen and controls info
- `scenes/Game.tscn`: match scene that composes the arena, players, and HUD
- `scenes/arenas/*.tscn`: reusable hand-built arenas with backgrounds, gameplay geometry, spawns, pickups, and future gimmick placeholders
- `scenes/Player.tscn`: reusable fighter scene
- `scenes/HUD.tscn`: health bars, scores, round display
- `scenes/WinScreen.tscn`: final match winner screen
- `scripts/player.gd`: player movement, shooting, health, knockback
- `scripts/bullet.gd`: bullet movement and hit detection
- `scripts/game_manager.gd`: round flow, scoring, win condition
- `scripts/hud.gd`: HUD updates
- `scripts/main_menu.gd`: menu behavior
- `scripts/win_screen.gd`: win screen behavior
- `scripts/game_state.gd`: small autoload used to pass winner name between scenes

## Formal Project Description

Pixel Duel Arena is a 2D local multiplayer arena game made in a pixel-art style. Two players compete in a single-screen arena using movement, jumping, and gun shooting. The objective is to reduce the opponent's health to zero and win a set number of rounds. The project demonstrates player input handling, projectile collision detection, combat logic, UI/HUD updates, scene management, and win/lose conditions.
