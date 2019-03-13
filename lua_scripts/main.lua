-- main.lua

require("playfield")
require("best_move")
require("pieces")


game_state_addr = 0x00C0
rand_seed_addr_1 = 0x0017
rand_seed_addr_2 = 0x0018


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


--//-------------------------------------------------------------------
--// main

emu.speedmode("turbo")    -- speed up game
math.randomseed(os.time())
start_game()
local move_num = 1
local old_field = read_field()
local current_field
local complete_lines = 0

-- make first move
local best_col, piece, rotation = unpack(get_best_move())
move_piece(best_col, piece, rotation)

while (true) do

  emu.frameadvance()
  current_field = read_field()
  -- move after piece is dropped
  if (not fields_equal(old_field, current_field)) then
    -- delay to compensate for line-clear animation
    if (complete_lines > 0) then
      complete_lines = 0
      frame_adv(18)
    -- calculate best move
    else
      print(move_num)
      frame_adv(12)
      local best_col, piece, rotation, best_field = unpack(get_best_move())
      move_piece(best_col, piece, rotation)
      old_field = deepcopy(current_field)
      move_num = move_num + 1
      complete_lines = get_complete_lines(best_field)
    end
  end

end
