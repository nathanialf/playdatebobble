Building a puzzle bobble-like game for the Playdate Console.

Learning how to use lua during the process as well

To Compile:
- Set up PlayDate SDK - https://play.date/dev/
- From the root directory of the repo
```
pdc -v source build/MyGame.pdx
```

Fun fact: Running the pdx file in the simulator from a network share does NOT work. The errors don't make sense.

TODO:
- Clean up comments
- Add delay for firing bobbles to avoid mid air collisions of bobbles
  - Option 1: Wait until previous bobble is done moving
  - Option 2: Some set amount of time between bobble shots
- Have grouped up bobbles and their "children" drop off the screen
- Set up some levels
- Add some pictures/details in this README