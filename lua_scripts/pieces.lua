-- pieces.lua
-- tables that contain info on each piece

-- Memory address values of pieces:
  -- 00 - T Up
  -- 01 - T Right
  -- 02 - T Down
  -- 03 - T Left
  -- 04 - J Left
  -- 05 - J Up
  -- 06 - J Right
  -- 07 - J Down
  -- 08 - Z
  -- 09 - Z Rotated
  -- 10 - O
  -- 11 - S
  -- 12 - S Rotated
  -- 13 - L Right
  -- 14 - L Down
  -- 15 - L Left
  -- 16 - L Up
  -- 17 - I
  -- 18 - I Rotated


-- list of all possible rotations of a piece
all_rotations = {
  [2] = {0, 1, 2, 3},       -- T
  [7] = {4, 5, 6, 7},       -- J
  [8] = {8, 9},             -- Z
  [10] = {10},              -- O
  [11] = {11, 12},          -- S
  [14] = {13, 14, 15, 16},  -- L
  [18] = {17, 18}           -- I
}


-- tables that contain the shape of a pieces
pieces = {

  [0] = { {0, 1, 0},        -- 00 - T Up
          {1, 1, 1} },

  [1] = { {1, 0},           -- 01 - T Right
          {1, 1},
          {1, 0} },

  [2] = { {1, 1, 1},        -- 02 - T Down
          {0, 1, 0} },

  [3] = { {0, 1},           -- 03 - T Left
          {1, 1},
          {0, 1} },

  [4] = { {0, 1},           -- 04 - J Left
          {0, 1},
          {1, 1} },

  [5] = { {1, 0, 0},        -- 05 - J Up
          {1, 1, 1} },

  [6] = { {1, 1},           -- 06 - J Right
          {1, 0},
          {1, 0} },

  [7] = { {1, 1, 1},         -- 07 - J Down
          {0, 0, 1} },

  [8] = { {1, 1, 0},         -- 08 - Z
          {0, 1, 1} },

  [9] = { {0, 1},            -- 09 - Z Rotated
          {1, 1},
          {1, 0} },

  [10] = { {1, 1},            -- 10 - O
           {1, 1} },

  [11] = { {0, 1, 1},         -- 11 - S
           {1, 1, 0} },

  [12] = { {1, 0},            -- 12 - S Rotated
           {1, 1},
           {0, 1} },

  [13] = { {1, 0},            -- 13 - L Right
           {1, 0},
           {1, 1} },

  [14] = { {1, 1, 1},         -- 14 - L Down
           {1, 0, 0} },

  [15] = { {1, 1},            -- 15 - L Left
           {0, 1},
           {0, 1} },

  [16] = { {0, 0, 1},          -- 16 - L Up
           {1, 1, 1} },

  [17] = { {1},                 -- 17 - I
           {1},
           {1},
           {1}},

  [18] = { {1, 1, 1, 1} }       -- 18 - I Rotated

}

-- starting drop column from left side of a piece
start_columns = {
  [0] = 5,   -- T Up
  [1] = 6,   -- T Right
  [2] = 5,   -- T Down
  [3] = 5,   -- T Left
  [4] = 5,   -- J Left
  [5] = 5,   -- J Up
  [6] = 6,   -- J Right
  [7] = 5,   -- J Down
  [8] = 5,   -- Z
  [9] = 6,   -- Z Rotated
  [10] = 5,  -- O
  [11] = 5,  -- S
  [12] = 6,  -- S Rotated
  [13] = 6,  -- L Right
  [14] = 5,  -- L Down
  [15] = 5,  -- L Left
  [16] = 5,  -- L Up
  [17] = 6,  -- I
  [18] = 4   -- I Rotated
}
