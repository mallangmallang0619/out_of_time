extends Node

# --- Ability inventory ---
var has_gun: bool = false
var has_sword: bool = false
var has_shield: bool = false

# --- Run stats ---
var x: int = 0
var y: int = 0
var best_x: int = -1000000

# --- End game payload ---
var end_title: String = "Game Over"
var end_detail: String = ""
var end_final_score: int = 0
