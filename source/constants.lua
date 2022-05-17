-- NOTES:
-- PLAYDATE DISPLAY SIZE
-- 400 x 240

-- Entity codes for collisions
kBOBBLE = 1
kBARRIER = 2
-- Turns on all DEBUG changes for testing
DEBUG = true

-- For the next two variables, 0 degrees is pointing left, 90 is point up, and 270 is pointing down
-- angle of the upper limit for the arrow to rotate to
ARROW_UP_LIMIT = 80
-- angle of the lower limit for the arrow to rotate to
ARROW_DOWN_LIMIT = 280

-- Boundary limits for bobbles to be placed
X_BOBBLE_LOWER_BOUND = 28 -- 20 for the barrier and 8 is halfway through the bobble
X_BOBBLE_UPPER_BOUND = 372 -- 400 Screen width, 20 for the barrier and 8 is halfway through the bobble
Y_BOBBLE_LOWER_BOUND = 28 -- 20 for the barrier and 8 is halfway through the bobble
Y_BOBBLE_UPPER_BOUND = 212 -- 240 screen width, 20 for the barrier and 8 is halfway through the bobble

X_BARRIER_LOWER_BOUND = 30 -- 20 for the static barrier and 10 is halfway through the placed barrier
X_BARRIER_UPPER_BOUND = 370 -- 400 Screen width, 20 for the static barrier and 10 is halfway through the placed barrier
Y_BARRIER_LOWER_BOUND = 30 -- 20 for the static barrier and 10 is halfway through the placed barrier
Y_BARRIER_UPPER_BOUND = 210 -- 240 screen width, 20 for the static barrier and 10 is halfway through theplaced barrier

-- Menu Strings
SETTINGS_MENU_OPTIONS = {"VIEW TUTORIAL", "DELETE SCORES", "INVERT COLORS", "EXIT"}
LEVEL_SECTION_NAMES = {"Test Levels", "Level Select"}
DEBUG_LEVEL_SECTION_NAMES = {"Test Levels", "Malformed Levels", "Level Select"}

-- Table to return a boolean for a string of the value desired
STRING_TO_BOOLEAN={ ["true"]=true, ["false"]=false }
