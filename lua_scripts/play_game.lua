require("playfield")
require("best_move")
require("pieces")
-- require("genetic_alg")


game_state_addr = 0x00C4
rand_seed_addr_1 = 0x0017
rand_seed_addr_2 = 0x0018
level_addr = 0x0064
speed_addr = 0x00AF

score_addr_right = 0x0073
score_addr_mid = 0x0074
score_addr_left = 0x0075


--//-------------------------------------------------------------------
--// functions

function set_random_addr()
  memory.writebyte(rand_seed_addr_1, math.random(0, 255))
  memory.writebyte(rand_seed_addr_2, math.random(0, 255))
end

-- loads game state 1 and start game
-- save state should be on level select hovering over level 9
function start_game()
  local start_state = savestate.object(1)
  savestate.load(start_state)
  set_random_addr()
  emu.frameadvance()
  joypad.set(1, { start = true } )
  frame_adv(5)
end


function frame_adv(frames)
  for i = 1, frames do
    emu.frameadvance()
  end
end


function move_piece(best_col, piece, rotation)

  local start_col = start_columns[rotation]
  local move_list = {left = false, right = false, B = false, A = false}
  while (best_col ~= start_col or piece ~= rotation) do
    emu.frameadvance()
    move_list = {left = false, right = false, B = false, A = false}

    -- rotate piece B/A
    if (piece > rotation) then    -- rotate counter-clockwise
      move_list.B = true
      rotation = rotation + 1
    elseif (piece < rotation) then    -- rotate clockwise
      move_list.A = true
      rotation = rotation - 1
    end

    -- move piece left/right
    if (best_col < start_col) then    -- move left
      move_list.left = true
      best_col = best_col + 1
    elseif (best_col > start_col) then   -- move right
      move_list.right = true
      best_col = best_col - 1
    end

    joypad.set(1, move_list)
    emu.frameadvance()
  end

end

function game_over()
  local field = read_field()
  for i=1, #field do
    for j=1, #field[i] do
      if field[i][j] == 0 then return false end
    end
  end
  return true
end


function dec_to_hex(dec_val)
  local total = 0
  local base = 1
  while (dec_val > 0) do
    total = total + (dec_val % 16) * base
    dec_val = math.floor(dec_val / 16)
    base = base * 10
  end
  return total
end

function get_score()
  local score_left = memory.readbyte(score_addr_left)
  local score_mid = memory.readbyte(score_addr_mid)
  local score_right = memory.readbyte(score_addr_right)

  return (dec_to_hex(score_left)  * 10000 +
        dec_to_hex(score_mid) * 100 +
        dec_to_hex(score_right) )
end


--//-------------------------------------------------------------------
--// play_game
--// play a single game using certain heuristics and return score after
--// game over if move limit exceeded

function play_game(heuristic_parameters, move_limit)
  emu.speedmode("turbo")    -- speed up game
  start_game()
  local move_num = 1
  local old_field = read_field()
  local current_field
  local complete_lines = 0

  -- make first move
  local best_col, piece, rotation = unpack(get_best_move(heuristic_parameters))
  move_piece(best_col, piece, rotation)

  while (not game_over() and move_num <= (move_limit or math.huge)) do
    memory.writebyte(level_addr, 9)   -- set level
    emu.frameadvance()
    current_field = read_field()
    -- move after piece is dropped
    if (not fields_equal(old_field, current_field)) then
      delay = memory.readbyte(speed_addr)
      frame_adv(delay * 2)
      -- delay to compensate for line-clear animation
      if (complete_lines > 0) then
        complete_lines = 0
        frame_adv(6)
      -- calculate and perform best move
      else
        pcall(function()
          best_col, piece, rotation, best_field = unpack(get_best_move(heuristic_parameters))
        end )

        move_piece(best_col, piece, rotation)
        if (best_field) then
          complete_lines = get_complete_lines(best_field)
        end
        old_field = deepcopy(current_field)
        move_num = move_num + 1
      end
    end
  end
  return get_score()
end
