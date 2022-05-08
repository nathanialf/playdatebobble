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
- BUGS
  - 1px black line appeared horizontally across the screen around firing the 70th bobble on 1-1-2
- QOL
  - Make Font bigger
    - Totally fine looking on simulator but not very clear on hard ware
- Tutorial
  - Add view for display how to play the game
- Code Quality
  - Add safegaurds for malformed level files
  - Change bobbles and barriers to extend sprites and cut out some unnecessary complications with the objects and collisions
- Sprite Updates
  - Barrier sprites update but its pretty boring still
  - Update the arrow sprite
  - Launch Images/Cards
- Art/Sound
  - Replace SDK Example Assets
  - https://play.date/pulp/ For quick and easy (allegedly) sound creation
  - Needed
    - Sounds when hitting a barrier
    - Sounds when hitting a bobble
    - Sounds when popping bobbles
    - Song to play in the background
    - Menuing sounds
      - Move cursor/change level
      - Selecting an option/level
- Investigations
  - Changing the menu button items during runtime
  - Setting column count by section or row instead of the whole gridview
- Add more levels (Possibly through Level editor in Stretch Goals section)

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
<!--![5/6/2022 Level Complete Screenshot](resource/screenshots/playdate-20220506-013302.png)-->
![5/6/2022 Level Complete Screenshot](resource/screenshots/playdate-20220506-145714.png)

*(see TODO for note about SDK Assets)*

### Stretch Goals
Extra stuff that would be nice to do but not currently in the scope of the project
- Have grouped up bobbles and their "children" drop off the screen
  - Have a boolean on bobble if its collided with a sticky wall turn true
  - Search each bobble to see if there are any sets of bobbles disconnected from the wall
  - BLOCKED BY: Change bobble and barrier objects to extend sprites
    - No sense in trying to continue to add on to issues with this system when i can clean it up first
- Add extra barriers in level files
- Build a level editor
    - PC based, not playdate based
    - Building by hand is far too time consuming when adding all neighbor pairs
- Display current score and level on the menu image
  - https://sdk.play.date/1.10.0/Inside%20Playdate.html#f-setMenuImage
- Add pop-ups when you try to use menu items outside of their intended view
  - Example: "Unable to Delete Scores, please try again from Level Select" when in a level
