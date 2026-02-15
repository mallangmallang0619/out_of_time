# Project Overview

Out of Time is a platformmer based around the idea of one-time powerups. The player must get to the end in the time-allocated to beat the game.

---

## Project Structure

```
assets/        # Art, backgrounds, sprites, audio, etc.
scenes/        # Godot scene files (.tscn)
scripts/       # GDScript files used by scenes
.gitignore     # Git ignore rules
project.godot  # Godot project configuration
```

---

## Scenes

This project is built using multiple scenes, each responsible for a specific part of gameplay, UI, or game flow. Below is a detailed breakdown of some of the more important scenes on our game:

`main_menu.tscn`

Entry point for the game. Contains the main-menu where the player can start a new game or quit the game.

`killzone.tscn`

Detects when the player falls or touches a lethal zone. Triggers player death and endgame logic.
---

## Scripts

All game logic is located in the `scripts/` directory.

Typical responsibilities include:

* Player or enemy behavior (e.g., slime movement or AI)
* Scene transitions
* Game state handling (start, endgame, restart)

---

## Assets

The `assets/` folder contains visual and/or audio resources used by the game.

Examples:

* Backgrounds
* Sprites
* UI elements

---

## Getting Started

1. Install **Godot** (version should match the one used to create the project).
2. Open Godot and click **Import**.
3. Select the `project.godot` file.
4. Press **Play** to run the game.

---

---

## Future Improvements

* Expand slime behavior or enemy variety
* Add sound effects onto movement options
* Improve UI/UX of the main menu
* Add more levels/expand level

---

## License

MIT License

---

## Author

Damian Kim, Eric Lee, Reese Sanchez, Clarenz Antioquia, Suhyun Song
