A puzzle bobble-like game for the Playdate Console.

I got the [Playdate](https://play.date) Console in my hands and thought it would be fun to learn to develop something for the device. It was also a chance for me to learn Lua since I've seen mentions of it for a long time but never had a reason to try to learn it.

### Game Contents
Not much, to be honest.

- It boots into the Level Select and has a couple of test levels to choose from.
- You play the game by aiming an arm to shoot and destroy all bobbles. Aiming is done with the crank on the console.
- Completing the level gives you a score based on the number of shots fired. The lowest score is saved and displayed in level select.
- Options to restart the level, go back to level select and delete save game data are found when pressing the "Menu" button on the device or simulator.

New levels should definitely be made, but manually setting up the file is cumbersome. Building a level editor is a stretch goal.

Continued additions and goals are listed further down.

### Current Progress

- Works on personal PlayDate console and simulator

Tutorial Screenshot

![5/12/2022 Tutorial Screenshot](resource/screenshots/playdate-20220512-152435.png)

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

### Compile
- Set up PlayDate SDK - https://play.date/dev/
- From the root directory of the repo
```
pdc -v source build/playdatebobble.pdx
```
- Drag pdx file into the simulator to start playing or to sideload to physical device

Fun fact: Running the pdx file in the simulator from a network share does NOT work. The errors don't make sense.

### TODO
- Code Quality
  - Add safegaurds for malformed level files
- Art
  - Sprite Updates
    - Barrier sprites update but its pretty boring still
    - Update the arrow sprite
    - Launch Images/Cards
  - Replace SDK Example Assets
    - Make Font bigger
      - Totally fine looking on simulator but not very clear on hardware
      - https://play.date/caps/
  - Tutorial images will need to be made for illustrating controls. 
  - Proper card image
- Sounds
  - https://play.date/pulp/ For quick and easy (allegedly) sound creation
  - Needed assets
    - Sounds when hitting a barrier
    - Sounds when hitting a bobble
    - Sounds when popping bobbles
    - Song to play in the background
    - Menuing sounds
      - Move cursor/change level
      - Selecting an option/level
- Add more levels (Possibly through Level editor in Stretch Goals section)

### Stretch Goals
Extra stuff that would be nice to do but not currently in the scope of the project
- Have grouped up bobbles and their "children" drop off the screen
  - Have a boolean on bobble if its collided with a sticky wall turn true
  - Add support for said boolean in the level files to set initial sticky bobbles
  - Search each bobble to see if there are any sets of bobbles disconnected from the wall
- Add extra barriers in level files
- Build a level editor
    - PC based, not playdate based
    - Building by hand is far too time consuming when adding all neighbor pairs
- Display current score and level on the menu image
  - https://sdk.play.date/1.10.0/Inside%20Playdate.html#f-setMenuImage
- Add pop-ups when you try to use menu items outside of their intended view
  - Example: "Unable to Delete Scores, please try again from Level Select" when in a level
