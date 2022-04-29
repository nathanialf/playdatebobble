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
- Finish commenting old changes
  - Add Comments to Barrier
- Add safegaurds for malformed level files
- Have grouped up bobbles and their "children" drop off the screen
- Crank Alert if docked
  - https://sdk.play.date/1.10.0/Inside%20Playdate.html#C-ui.crankIndicator

### Current Progress

<!--![4/27/2022 Screenshot](resource/screenshots/playdate-20220427-233610.png)-->
![4/28/2022 Screenshot](resource/screenshots/playdate-20220428-175705.png)
