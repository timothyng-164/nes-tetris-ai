# NES Tetris AI
## Instructions
1. Install FCEUX emulator [here](http://www.fceux.com/web/download.html), which is currently only supported on windows
2. Clone this repository
3. Open FCEUX
4. File -> Open ROM -> select "Tetris (U) [!]"
5. In the game, go to select game type A and whichever music you want.
6. In the level select screen, hover over level 9   
    * ![i.e.](/images/save_state_1.png)
7. Save state to 1 (shift + F1)
8. File -> Lua -> New Lua Script Window -> Browse -> select "lua_scripts/main.lua"
    * To run game at normal speed, edit main.lua to uncomment "emu.speedmode("turbo")"


## References
* Borrowed heuristics model from [Yiyuan Lee](https://codemyroad.wordpress.com/2013/04/14/tetris-ai-the-near-perfect-player/)
* NES Tetris memory [addresses](http://www.thealmightyguru.com/Games/Hacking/Wiki/index.php?title=Tetris)
* FCEUX Lua scripting [guide](http://www.fceux.com/web/help/fceux.html?LuaScripting.html)
