-- playfield.lua
-- read all pieces on the playfield and calculate heuristic data

field_start_addr = 0x0400
field_end_addr = 0x04C7
num_rows = 20
num_cols = 10

--// --------------------------------------------------------
--// Playfield "class"

function init_playfield()
  local playfield = {
    field = {{}},            -- 10x20 array of all the pieces on the field
    col_heights = {},        -- heights of each column
    aggregate_height = 0,    -- sum of all column heights
    complete_lines = 0,      -- number of complete lines
    holes = 0,               -- number of empty spaces with at least 1 tile above
    bumpiness = 0            -- sum of abs differences between 2 adjacent columns
  }
  return playfield
end

-- return field from current frame of game
function read_field()
  local field = {{}}
  local field_current_addr = field_start_addr

  for row = 1, num_rows do
    field[row] = {}
    for col = 1, num_cols do
      local cell = memory.readbyte(field_current_addr)
      -- initialize cells in field, 239 from memory is an empty cell
      field[row][col] = (cell == 239) and 0 or 1
      field_current_addr = field_current_addr + 1
    end
  end
  field_current_addr = field_start_addr
  return field
end


-- copies and returns playfield
function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end


function fields_equal(field_1, field_2)
  for i=1, num_rows do
    for j=1, num_cols do
      if (field_1[i][j] ~= field_2[i][j]) then
        return false
      end
    end
  end
  return true
end


--// --------------------------------------------------------
--// get heuristics from Playfield


-- set column heights of current field
function get_holes_and_col_heights(field)
  local holes = 0
  local col_heights = {}
  for i=1, num_cols do col_heights[i] = 0 end

  for row = 1, num_rows do
    for col = 1, num_cols do
      local cell = field[row][col]
      -- if cell is empty, check for hole
      if (cell == 0) then
        if (row > 1 and col_heights[col] > 0) then
          holes = holes + 1
        end
      -- if cell is not empty, check for column height
      else
        if (col_heights[col] == 0 and row > 1) then
        col_heights[col] = 21 - row
        end
      end
    end
  end

  return {holes, col_heights}
end


-- get aggregate_height (sum of all column heights)
function get_aggregate_height(col_heights)
  local aggregate_height = 0
  for i=1, num_cols do
    aggregate_height = aggregate_height + col_heights[i]
  end
  return aggregate_height
end


-- given array of col_heights, return bumpiness
function get_bumpiness(col_heights)
  local bump = 0
  for i=1, num_cols-1 do
    bump = bump + math.abs(col_heights[i] - col_heights[i+1])
  end
  return bump
end


-- return total number of rows that are cleared in field (all 1's)
function get_complete_lines(field)
  local comp_lines = 0
  for row=1, num_rows do
    for col=1, num_cols do
      local cell = field[row][col]
      if (cell == 0) then
        break
      end
      if (cell == 1 and col == num_cols) then
        comp_lines = comp_lines + 1
      end
    end
  end
  return comp_lines
end


-- calculate total of heuristics linear function
function set_heuristics(playfield)
  playfield.holes, playfield.col_heights = unpack(get_holes_and_col_heights(playfield.field))
  playfield.aggregate_height = get_aggregate_height(playfield.col_heights)
  playfield.bumpiness = get_bumpiness(playfield.col_heights)
  playfield.complete_lines = get_complete_lines(playfield.field)
  return playfield
end


-- calculate rewards of current field
-- reward = ax + by + cz + dq
function get_reward(playfield, a, b, c, d)
  return (a * playfield.aggregate_height) +
         (b * playfield.complete_lines)   +
         (c * playfield.holes)            +
         (d * playfield.bumpiness)
end



--// --------------------------------------------------------
--// print functions for debugging


function print_field(field)
  print("Table")
  for row = 1, num_rows do
    print(field[row])
  end
end


function print_heuristics_info(playfield)
  print("\nCol Heights")
  print(playfield.col_heights)

  print("\nHoles")
  print(playfield.holes)

  print("\nAggregate Height")
  print(playfield.aggregate_height)

  print("\nBumpiness")
  print(playfield.bumpiness)

  print("\nComplete Lines")
  print(playfield.complete_lines)
end
