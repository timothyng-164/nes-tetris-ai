# NES Tetris AI

## Instructions
1. Install FCEUX emulator [here](http://www.fceux.com/web/download.html), which is currently only supported on windows
2. Clone this repository
3. Open FCEUX
4. File -> Open ROM -> select "Tetris (U) [!]"
5. In the game, select game type A and whichever music you want.
6. In the level select screen, hover over level 9   
    * ![tetris level select](/images/save_state_1.png)
7. Save state to 1 (shift + F1)
8. File -> Lua -> New Lua Script Window -> Browse ->
  * To run genetic algorithm, select "lua_scripts/main.lua"
  * To run play the game once with the best heuristics, select "lua_scripts/play_fittest.lua"
  * To run game at normal speed, edit play_game.lua and comment out "emu.speedmode("turbo")"


## Game Mechanics
* 20 x 10 playfield
* 7 Pieces with up to 4 rotations each
* Goal is to clear lines without reaching top of playfield
* Score is increased every time a line clears
  * more lines cleared at once gives more points

## Heuristics
* The AI plays the game by calculating the reward in every possible piece placement and rotation. The best move will give the highest reward.
* Reward = (a * aggregate_height) + (b * complete_lines) + (c * holes) + (d * bumpiness)
  * a) aggergate height - sum of all column heights
  * b) complete lines - number of rows that will be complete
  * c) holes - number of holes in playfield
    * a hole occurs when a cell is empty and at least one cell in the same column is filled above it
  * d) bumpiness - sum of the absolute differences between every pair of adjacent columns
* The coefficient values of the linear function will be determined by a genetic algorithm

## Genetic Algorithm Overview
* The genetic algorithm plays the game numerous times to determine the best coefficients for the heuristics.
* For every generation, the fittest heuristic parameters stay in the population. The weakest ones get replaced with children created by crossover.
* The fitness is determined by the game score because it considers the number of lines cleared at a time


#### Algorithm layout

        randomly initialize first generation
        while (generation limit is not exceeded)
            for (children_size)     // selection and crossover
                select a random percentage of population
                get 2 fittest parents and crossover to create child
                small chance to mutate new child
            remove genomes with lowest fitness from population
            add new children to population


##### Algorithm details
To start the algorithm, we create the initial population that contains genomes with randomly generated heuristic parameters ranging from -1 to 1.

Then until the generation limit is reached, we create new children using selection and crossover and remove the least fit genomes from the current population.

During selection, we get a fixed percentage of randomly selected genomes from current population. Then from the selected genomes, crossover is performed by combining the 2 fittest genomes to create a child. The crossover is weighted by fitness (child will resemble the fitter parent more).

And during crossover, mutation has a small chance of occuring to preserve diversity. When mutation occurs, one parameter will be randomly selected for the child and it random value from -1 to 1 will be added.

When removing genomes with lowest fitness from population, we remove the same amount of the children generated. Then we add new children to population. Once the alorithm terminates, we can analyze the last population the determine the best heuristic parameters to play Tetris.

## Population Analysis
After the algorithm is completed, a csv file of the populations is given.
A python script is used to summarize the data.

![2 tables of population data](/images/population.PNG)

The final reward function is calculated using the fittest 50% of the last generation.

Reward = (-0.860 * aggregate_height) + (0.433 * complete_lines) + (-0.824 * holes) + (-0.343 * bumpiness)


## Possible Improvements
* Utilize tucks and spins to reduce amount of holes in game
* Add new heuristics or improve current ones


## Important Files
* lua_scripts:
    * "play_fittest.lua" - plays the game once with the fittest heuristic coefficients
    * “main.lua” - runs genetic algorithm that finds the fittest heuristic coefficient
        * outputs a csv file of information on each population
        *  uses all lua files below
    * “genetic_alg.lua” - contains functions to implement genetic algorithm
    * “play_game.lua” - contains main logic for AI to play the game once
        * must be given heuristic coefficients
        * returns the score of a single play-through after game over or move limit exceeded
    * “playfield.lua” -  contains functions to read and analyze the playfield
    * “pieces.lua” - contains information about the game pieces including piece rotation, pieces represented as 2D arrays, and starting column where each piece drops
    * “best_move.lua” - contains functions the determine the best move based on the playfield and current piece
* "process-populations.py" - analyzes populations outputted by main.lua
    * prints a table showing the standard deviation and average of each heuristic coefficient
    * this program needs the population csv file outputted by main.lua as the first argument
* “Tetris (U) [!].zip” - the game rom used by the emulator


## References
* Borrowed heuristics model from [Yiyuan Lee](https://codemyroad.wordpress.com/2013/04/14/tetris-ai-the-near-perfect-player/)
* NES Tetris memory [addresses](http://www.thealmightyguru.com/Games/Hacking/Wiki/index.php?title=Tetris)
* FCEUX Lua scripting [guide](http://www.fceux.com/web/help/fceux.html?LuaScripting.html)
* Lua scripting [documentation](http://www.lua.org/pil/contents.html)
* FCEUX Emulator [download](http://www.fceux.com/web/download.html)
