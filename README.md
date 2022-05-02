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
  - Add end state to levels (Kinda implemented)
    - Kinda implemented, displays text to the user
    - Need to set a flag to prevent user action once the level is beat
  - store level completion status
- Add an actual barrier sprite
- Add menuing system to browse through levels in `levels/`
  - https://sdk.play.date/1.10.0/Inside%20Playdate.html#C-ui.gridview
- Maybe add sounds

### Current Progress

- Works on personal PlayDate console and simulator

<!--![4/27/2022 Screenshot](resource/screenshots/playdate-20220427-233610.png)-->
<!--![4/28/2022 Screenshot](resource/screenshots/playdate-20220428-175705.png)-->
![5/1/2022 Screenshot](resource/screenshots/playdate-20220501-222305.png)

