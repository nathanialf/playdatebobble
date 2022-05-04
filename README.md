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
- Have grouped up bobbles and their "children" drop off the screen
  - May not happen
- Levels
  - prompt user to retry or go to level select
    - view = 2 for Level Beat
    - view = 3 for Level failed
    - might be able to do the same view for beat and failed but I don't have a fail state decided
  - store level completion status
- Sprite Updates
  - Barrier sprites update but its pretty boring still
  - Update the arrow sprite
- Improve menuing system to browse through levels in `source/levels/`
  - Make menu columns and rows based on information from a file
  - Style menu to make it more personal than the example
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

### Current Progress

- Works on personal PlayDate console and simulator

<!--![4/27/2022 Screenshot](resource/screenshots/playdate-20220427-233610.png)-->
<!--![4/28/2022 Screenshot](resource/screenshots/playdate-20220428-175705.png)-->
<!--![5/1/2022 In-Game Screenshot](resource/screenshots/playdate-20220501-222305.png)-->
In-Game Screenshot

![5/4/2022 In-Game Screenshot](resource/screenshots/playdate-20220504-012106.png)

Menu Screenshot (see TODO for note about style)

![5/3/2022 Menu Screenshot](resource/screenshots/playdate-20220503-015607.png)

