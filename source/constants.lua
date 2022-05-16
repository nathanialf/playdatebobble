-- Entity codes for collisions
kBOBBLE = 1
kBARRIER = 2
-- Turns on all DEBUG changes for testing
DEBUG = false

-- For the next two variables, 0 degrees is pointing left, 90 is point up, and 270 is pointing down
-- angle of the upper limit for the arrow to rotate to
ARROW_UP_LIMIT = 80
-- angle of the lower limit for the arrow to rotate to
ARROW_DOWN_LIMIT = 280

-- Boundary limits for bobbles to be placed
X_LOWER_BOUND = 28 -- 20 for the barrier and 8 is halfway through the bobble
X_UPPER_BOUND = 392 -- 400 Screen width, 20 for the barrier and 8 is halfway through the bobble
Y_LOWER_BOUND = 28 -- 20 for the barrier and 8 is halfway through the bobble
Y_UPPER_BOUND = 212 -- 240 screen width, 20 for the barrier and 8 is halfway through the bobble

-- Menu Strings
SETTINGS_MENU_OPTIONS = {"VIEW TUTORIAL", "DELETE SCORES", "INVERT COLORS", "EXIT"}
LEVEL_SECTION_NAMES = {"Test Levels", "Main Game"}

-- Table to return a boolean for a string of the value desired
STRING_TO_BOOLEAN={ ["true"]=true, ["false"]=false }
