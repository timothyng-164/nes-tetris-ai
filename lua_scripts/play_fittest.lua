-- play_once.lua - play game once using custom heursitc coefficients

require("play_game")

heuristic_values = {
  aggregate_height = -0.860,
  complete_lines = 0.433,
  holes = -0.824,
  bumpiness = -0.343,
  fitness = nil
}

print("Score =", play_game(heuristic_values))
