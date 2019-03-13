-- bestmove.lua
--

require("playfield")
require("pieces")

--// --------------------------------------------------------
--// Search for the best move given playfield, piece, next_piece

piece_addr = 0x0062
next_piece_addr = 0x00BF


function get_best_move()
  local start_playfield = init_playfield()
  start_playfield.field = read_field()
  start_playfield = set_heuristics(start_playfield)

  local piece_val = memory.readbyte(piece_addr)
  local next_piece_val = memory.readbyte(next_piece_addr)

  -- get all field combinations of current piece and next piece
  local fields_list = { {start_playfield, {}, {}} }
  fields_list = get_possible_fields(fields_list, piece_val)
  fields_list = get_possible_fields(fields_list, next_piece_val)

  local max_reward = -10000000000
  local index = 0
  -- search for move with highest reward
  for i=1, #fields_list do
    curr_playfield = fields_list[i][1]
    reward = get_reward(curr_playfield, -1, 1, -2, -1)
    if (reward > max_reward) then
      max_reward = reward
      index = i
    end
  end

  local best_move = fields_list[index][2][1]
  local rotation = fields_list[index][3][1]
  local best_field = fields_list[index][1].field
  return {best_move, piece_val, rotation, best_field}
end


--// --------------------------------------------------------
--// Functions for getting all combinations of field and piece

-- given a list of fields and piece,
-- return a list of all combinations of fields and pieces
-- list of fields = {{field, {piece_col}, {piece_rot}}, ...}
function get_possible_fields(fields_list, piece_val)
  new_fields_list = {}
  local piece_rotations = all_rotations[piece_val]

  for i=1, #fields_list do
    -- iterate through rotations of currnet piece
    for j=1, #piece_rotations do
      local piece = pieces[piece_rotations[j]]
      -- test all colummn drops for each piece rotation
      for col=1, (num_cols - #piece[1] + 1) do
        local col_list = deepcopy(fields_list[i][2])
        table.insert(col_list, col)
        local rot_list = deepcopy(fields_list[i][3])
        table.insert(rot_list, piece_rotations[j])
        local playfield_1 = deepcopy(fields_list[i][1])
        playfield_1.field = drop_piece(playfield_1, piece, col)
        playfield_1 = set_heuristics(playfield_1)
        table.insert(new_fields_list, {playfield_1, col_list, rot_list})
      end
    end
  end
  return new_fields_list
end

function print_possible_fields(fields_list)
  for i=1, #fields_list do
    print("cols:", fields_list[i][2])
    print("rots:", fields_list[i][3])
    print_field(fields_list[i][1].field)
    print("\n")
  end
end


--// --------------------------------------------------------
--// Functions for combining field and piece

-- return 2D table after merging piece into field
function drop_piece(playfield, piece, col)
  local sums = {}   -- sums of piece bottom and col heights
  local bottoms, offset = unpack(get_piece_bottom(piece))
  -- initialize sums
  for i=col, #piece[1]+col-1 do
    table.insert(sums, playfield.col_heights[i] + bottoms[i-col+1])
  end
  -- row = max of sums + 1 + offset
  local row = math.max(unpack(sums)) + offset
  return merge_tables(playfield.field, piece, col, 21-row)
end

function get_piece_bottom(piece)
  local row = piece[#piece]
  local bottom = row
  local offset = 0
  local rows_equal = true

  for i=#piece-1, 1, -1 do
    if (tables_equal(piece[i], row) and rows_equal) then
      bottom = add_tables(bottom, piece[i])
    else
      offset = offset + 1
      rows_equal = false
    end
  end
  return {bottom, offset}

end



--// --------------------------------------------------------
--// Table/Array functions


-- merge piece into field at [row][col], return resulting field
function merge_tables(field, piece, col, row)
  for i=1, #piece do
    for j=1, #piece[1] do
      -- set field cells to piece cells
      if (piece[i][j] == 1) then
        field[row+i-1][col+j-1] = piece[i][j]
      end
    end
  end
  return field
end

-- check if 1D tables have same values in same positions
function tables_equal(t1, t2)
  if (#t1 ~= #t2) then
    return false
  end
  for i=1, #t1 do
    if (t1[i] ~= t2[i]) then
      return false
    end
  end
  return true
end


-- adds values in tables, returns resulting table
function add_tables(t1, t2)
  local table = {}
  local len = math.min(#t1, #t2)
  for i=1, len do
    table[i] = t1[i] + t2[i]
  end
  return table
end
