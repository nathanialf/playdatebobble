Building a puzzle bobble-like game for the Playdate Console.

Learning how to use lua during the process as well

### Compile
- Set up PlayDate SDK - https://play.date/dev/
- From the root directory of the repo
```
pdc -v source build/playdatebobble.pdx
```

Fun fact: Running the pdx file in the simulator from a network share does NOT work. The errors don't make sense.

### TODO
- Add safegaurds for malformed level files
- Levels
  - view = 3 for Level failed
    - might be able to do the same view for beat and failed but I don't have a fail state decided yet
  - Save high score (pseudo-coded in updateHighScore)
- Sprite Updates
  - Barrier sprites update but its pretty boring still
  - Update the arrow sprite
- Improve menuing system
  - Replace SDK Example Assets
- Add sounds
  - https://play.date/pulp/ For quick and easy (allegedly) sound creation
  - Needed
    - Sounds when hitting a barrier
    - Sounds when hitting a bobble
    - Sounds when popping bobbles
    - Song to play in the background
    - Menuing sounds
      - Move cursor/change level
      - Selecting an option/level
- Change bobbles and barriers to extend sprites and cut out some unnecessary complications with the objects and collisions
- Investigations
  - Changing the menu button items during runtime
  - Setting column count by section or row instead of the whole gridview

### Current Progress

- Works on personal PlayDate console and simulator

In-Game Screenshot
<!--![4/27/2022 Screenshot](resource/screenshots/playdate-20220427-233610.png)-->
<!--![4/28/2022 Screenshot](resource/screenshots/playdate-20220428-175705.png)-->
<!--![5/1/2022 In-Game Screenshot](resource/screenshots/playdate-20220501-222305.png)-->
![5/4/2022 In-Game Screenshot](resource/screenshots/playdate-20220504-012106.png)

Level Select Screenshot 

<!--![5/3/2022 Menu Screenshot](resource/screenshots/playdate-20220503-015607.png)-->
<!--![5/4/2022 Menu Screenshot](resource/screenshots/playdate-20220504-014448.png)-->
![5/4/2022 Menu Screenshot](resource/screenshots/playdate-20220504-232925.png)

Level Complete Screenshot

<!--![5/5/2022 Level Complete Screenshot](resource/screenshots/playdate-20220505-235113.png)-->
![5/6/2022 Level Complete Screenshot](resource/screenshots/playdate-20220506-013302.png)

*(see TODO for note about SDK Assets)*

### Stretch Goals
Extra stuff that would be nice to do but not currently in the scope of the project
- Have grouped up bobbles and their "children" drop off the screen
- Add extra barriers in level files
- Build a level editor
    - PC based, not playdate based
    - Building by hand is far too time consuming when adding all neighbor pairs
- Display current score and level on the menu image
  - https://sdk.play.date/1.10.0/Inside%20Playdate.html#f-setMenuImage
