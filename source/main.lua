import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import "constants"
import "bobble"
import "barrier"

local gfx <const> = playdate.graphics

local playerSprite = nil
local previewSprite = nil

-- Current angle that the arrow is facing and that the bobble will be shot at
local double arrowRotation = 0
-- Prevents the arrow from rotating upwards after reaching the arrowUpLimit
local boolean stopRotatingUp = false
-- Prevents the arrow from rotating downwards after reaching the arrowDownLimit
local boolean stopRotatingDown = false

-- stores the next type of bobble to shot out. randomized after each firing
local integer nextBobble = 1

-- Arrays (tables?) of bobbles and barriers
local bobbles = {}
local barriers = {}

-- Shots fired for tracking score
local shotsFired = 0

-- Used for delta time
local lastTime = playdate.getCurrentTimeMilliseconds()

-- view is the state the game is in at any given moment
-- 0 = Level select
-- 1 = In Level
-- 2 = Level Complete
-- 3 = Tutorial
-- 4 = Settings
local view = 3

-- Menu stuff
-- From Menu example in SDK
-- Asset from SDK Example, will remove when I build a font
local gridFont = gfx.font.new("fonts/blocky")
assert(gridFont)
gridFont:setTracking(1)

gridview = playdate.ui.gridview.new(44, 44)

slice = gfx.nineSlice.new('images/shadowbox', 4, 4, 45, 45)

-- Menu structure
levels = {}
scores = {}
currentLevel = ""

-- OVERRIDE
-- Draws level select cells
function gridview:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
        gfx.setLineWidth(3)
        gfx.drawCircleInRect(x, y, width+1, height+1)
    else
        gfx.setLineWidth(0)
        gfx.drawCircleInRect(x+4, y+4, width-8, height-8)
    end
    local cellText = ""..row.."-"..column

    gfx.setFont(gridFont)
    gfx.drawTextInRect(cellText, x, y+18, width, 20, nil, nil, kTextAlignment.center)
    for i=1,#levels do
        if levels[i][1] == section and
        levels[i][2] == row and
        levels[i][3] == column and
        scores[levels[i][4]] ~= nil then
            gfx.drawTextInRect(""..scores[levels[i][4]], x, y+35, width, 20, nil, nil, kTextAlignment.right)
        end
    end

    if playdate.buttonJustPressed(playdate.kButtonA) and selected then
        -- Check to find the level that matches the selected cell and load it
        for i=1,#levels do
            if levels[i][1] == section and
            levels[i][2] == row and
            levels[i][3] == column then
                loadLevel(levels[i][4])
                break
            end
        end
        
    end
end

-- May read from a file but probably unnecessary for this
sectionNames = {"Test Levels", "Main Game"}
-- OVERRIDE
-- Draws level select section headers from table above
function gridview:drawSectionHeader(section, x, y, width, height)
    gfx.drawText("*"..sectionNames[section].."*", x + 10, y + 8)
end

-- buttons --
function playdate.AButtonUp()
    if view == 2 then
        updateHighScore(currentLevel, shotsFired)
        removeAllBobbles()
        -- Changes back to the level select view
        currentLevel = ""
        shotsFired = 0
        view = 0
    elseif view == 3 then
        view = 0
    end
end

function playdate.BButtonUp()
    if view == 2 then
        updateHighScore(currentLevel, shotsFired)
        removeAllBobbles()
        -- Loads level again
        shotsFired = 0
        loadLevel(currentLevel)
        view = 1
    end
end

function playdate.upButtonUp()
    if view == 0 then
        -- Menu Navigation
        gridview:selectPreviousRow(true)
    elseif view == 1 and #bobbles ~= 0 then
        -- Fires Bobbles
        fireBobble()
    end
end

function playdate.downButtonUp()
    if view == 0 then
        -- Menu Navigation
        gridview:selectNextRow(true)
    elseif view == 1 and #bobbles ~= 0 then
        -- Fires Bobbles
        fireBobble()
    end
end

function playdate.leftButtonUp()
    if view == 0 then
        -- Menu Navigation
        gridview:selectPreviousColumn(true)
    elseif view == 1 and #bobbles ~= 0 then
        -- Fires Bobbles
        fireBobble()
    end
end

function playdate.rightButtonUp()
    if view == 0 then
        -- Menu Navigation
        gridview:selectNextColumn(true)
    elseif view == 1 and #bobbles ~= 0 then
        -- Fires Bobbles
        fireBobble()
    end
end
--

function fireBobble()
    -- Only fires a new bobble if the last bobble is done moving
    if #(bobbles) == 0 or not bobbles[#(bobbles)].isMoving then
        -- new bobble is made and starts moving
        table.insert(
            bobbles, 
            Bobble:create(
                nextBobble, 
                400, 
                120, 
                arrowRotation
            )
        )
        -- resets the preview bobble so it displays accurately
        previewSprite:remove()
        previewSprite = nil
        setUpPreviewBobble()
        shotsFired += 1
    end
end

-- function to setup up the preview bobble (used multiple times)
function setUpPreviewBobble()
    -- picks the type of bobble for the next shot
    if constants.DEBUG then
        nextBobble = 3 -- DEBUG Easy to complete 1-1-1
    else
        nextBobble = math.random(1,3)
    end
    previewSprite = gfx.sprite.new(gfx.image.new("images/bobble" .. tostring(nextBobble)))
    previewSprite:moveTo( 400, 120 )
    previewSprite:add()
end

-- function to load levels. Hardcoded for first draft
function loadLevel(levelFileName)
    local lineNum = 1
    local file = playdate.file.open(levelFileName, playdate.file.kFileRead)
    repeat
        local l = file:readline()
        if l then
            -- Splits string into an array
            -- Line structure in level file should be
            -- Input types:
            -- B = Bobble
            -- B <Bobble Type (1-3)> <X Coordinate> <Y Coordinate>
            -- N = Neighbor
            -- N <Bobble a> <Bobble b>
            ---- Note: You will need to have an entry for N <a> <b> and N <b> <a>
            -- Level will load what it can and spit errors out for incorrect lines
            local result = {};
            for match in (l.." "):gmatch("(.-)".." ") do
                table.insert(result, match);
            end
            -- creates stationary bobble from the data in the line
            if result[1] == "B" then
                if tonumber(result[2]) == nil or
                    tonumber(result[3]) == nil or
                    tonumber(result[4]) == nil then
                    print("ERROR")
                    print("Cannot read bobble on line " .. lineNum)
                    print("Line is incorrectly formatted")
                    print("Expected input:")
                    print("B <Bobble Type (1-3)> <X Coordinate> <Y Coordinate>")
                --elseif coordinates are outside of bounds
                elseif tonumber(result[2]) < 1 or tonumber(result[2]) > 3 then
                    print("ERROR")
                    print("Invalid Bobble type (" .. tonumber(result[2]) .. ") on line " .. lineNum)
                    print("Please set value to 1, 2, or 3")
                else
                    table.insert(
                        bobbles, 
                        Bobble:createStationary(
                            tonumber(result[2]), 
                            tonumber(result[3]), 
                            tonumber(result[4])
                        )
                    )
                end
            elseif result[1] == "N" then
                if tonumber(result[2]) == nil or
                    tonumber(result[3]) == nil then
                    print("ERROR")
                    print("Cannot read neighbor definition on line " .. lineNum)
                    print("Line is incorrectly formatted")
                    print("Expected input:")
                    print("N <Bobble a> <Bobble b>")
                elseif bobbles[tonumber(result[2])] == nil then
                    print("ERROR")
                    print("Bobble A (" .. tonumber(result[2]) .. ") Does not exist earlier in the file than line " .. lineNum)
                    print("Please ensure all bobbles are earlier in the file than the neighbors")
                elseif bobbles[tonumber(result[3])] == nil then
                    print("ERROR")
                    print("Bobble B (" .. tonumber(result[3]) .. ") Does not exist earlier in the file than line " .. lineNum)
                    print("Please ensure all bobbles are earlier in the file than the neighbors")
                else
                    table.insert(
                        bobbles[tonumber(result[2])].neighbors, 
                        bobbles[tonumber(result[3])]
                    )
                end
            elseif string.sub(result[1], 1, 1) == "#" then
                -- Commented Line
                -- continue
            else
                print("ERROR")
                print("Invalid line on line " .. lineNum)
            end
        end
        lineNum += 1
    until l == nil

    file:close()
    
    currentLevel = levelFileName
    arrowRotation = 0
    view = 1

    -- resets the preview bobble so it displays accurately
    previewSprite:remove()
    previewSprite = nil
    setUpPreviewBobble()
end

function removeAllBobbles()
    -- Removes bobbles
    for i=#bobbles,1,-1 do
        for j=#bobbles[i].neighbors,1,-1
        do
            bobbles[i].neighbors[j]:remove()
            table.remove(bobbles[i].neighbors, j)
        end
        bobbles[i]:remove()
        table.remove(bobbles, i)
    end
end

-- Updates the high scores in the table and saves to the datastore
function updateHighScore(currentLevel, shotsFired)
    if scores[currentLevel] == nil or shotsFired < scores[currentLevel] then
        scores[currentLevel] = shotsFired
        playdate.datastore.write(scores)
    end
end

-- A function to set up our game environment.
function myGameSetUp()
    -- sets the seed to use for random number generation
    math.randomseed(playdate.getSecondsSinceEpoch())

    -- Starts Crank Indicator
    playdate.ui.crankIndicator:start()

    local playerImage = gfx.image.new("images/arrow")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )

    -- Sets opacity
    playerSprite:setOpaque(false)

    playerSprite:moveTo( 400, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!

    setUpPreviewBobble()

    -- Four walls to prevent the balls from escaping
    barriers[1] = Barrier:create(10, 120, false, true)
    barriers[2] = Barrier:create(200, 230, true, false)
    barriers[3] = Barrier:create(200, 10, true, false)

    -- We want an environment displayed behind our sprite.
    -- There are generally two ways to do this:
    -- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
    -- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
    --       and call :setZIndex() with some low number so the background stays behind
    --       your other sprites.

    local backgroundImage = gfx.image.new( "images/background" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
            backgroundImage:draw( 0, 0 )
            gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
        end
    )

    -- Scores table
    -- {<filename>: <lowest score>}
    -- If it exists in the datastore, we will use it as the scores table and update during play,
    -- if not, it will remain an empty table.
    -- nil checks are made when checking for score update
    if playdate.datastore.read() ~= nil then
        scores = playdate.datastore.read()
    end

    local biggestCol = 0
    local rowCount = {}

    -- Reads from levels/menu.lvl which level to load based on the selected cell
    local file = playdate.file.open("levels/menu.lvl", playdate.file.kFileRead)
    repeat
        local l = file:readline()
        if l then
            --<section> <row> <column> <filename>
            local result = {};
            for match in (l.." "):gmatch("(.-)".." ") do
                table.insert(result, match);
            end

            table.insert(
                levels, 
                {
                    tonumber(result[1]),
                    tonumber(result[2]),
                    tonumber(result[3]),
                    result[4],
                }
            )
            -- Finds the largest column number because we can only set it for across the whole gridview for some reason
            if tonumber(result[3]) > biggestCol then
                biggestCol = tonumber(result[3])
            end
            -- Grabs the largest row number for each section
            if rowCount[tonumber(result[1])] == nil or tonumber(result[2]) > rowCount[tonumber(result[1])] then
                rowCount[tonumber(result[1])] = tonumber(result[2])
            end
        end
    until l == nil
    file:close()

    -- Level Select cell data
    -- GRIPE: Cant set Number of Columns by section
    gridview.backgroundImage = slice
    gridview:setNumberOfColumns(biggestCol)
    --gridview:setNumberOfRows(1, 1) -- number of sections is set automatically
    for i=1,#rowCount
    do
        if rowCount[i] ~= nil then
            gridview:setNumberOfRowsInSection(i, rowCount[i])
        end
    end
    gridview:setSectionHeaderHeight(28)
    gridview:setContentInset(1, 4, 1, 4)
    gridview:setCellPadding(4, 4, 4, 4)
    gridview.changeRowOnColumnWrap = true
end

myGameSetUp()

-- Runs every frame
function playdate.update()
    -- calculates deltatime
    local currentTime = playdate.getCurrentTimeMilliseconds()
    local deltaTime = currentTime - lastTime
    lastTime = currentTime

    if view == 0 then
        -- Level select
    elseif view == 1 then
        -- In Level
        -- sets the arrow to rotate to the position we want to shoot the bobble at
        playerSprite:setRotation(arrowRotation)
    
        -- prevents the angle from exceeding 360 for ease of use
        arrowRotation = arrowRotation % 360
    
        -- moves the bobbles if they should be moving
        -- possibly refactoring to update since it handles collisions as well
        for i=1,#(bobbles) 
        do
            bobbles[i]:move(deltaTime)
        end
    
        -- Won't let you play if you have completed the level
        -- Conditional will probably change to if in a game and beating the game will take you into a menu to remove interaction
        if #bobbles ~= 0 then            
            -- prevents the angle we want to shoot at from going above or below a certain threshold
            if arrowRotation >= constants.ARROW_UP_LIMIT and arrowRotation < 180 then
                stopRotatingUp = true
                arrowRotation = constants.ARROW_UP_LIMIT
            else
                stopRotatingUp = false
            end
            if arrowRotation <= constants.ARROW_DOWN_LIMIT and arrowRotation >= 180 then
                stopRotatingDown = true
                arrowRotation = constants.ARROW_DOWN_LIMIT
            else
                stopRotatingDown = false
            end
        
            -- Rotates the arrow when the crank is rotated
            if (playdate.getCrankChange() > 0 and not stopRotatingUp) then
                arrowRotation += playdate.getCrankChange();
            elseif (playdate.getCrankChange() < 0 and not stopRotatingDown) then
                arrowRotation += playdate.getCrankChange();
            end        
        end
    
        -- This is admittedly kinda hacky. 
        local count = 0
        for i=1,#bobbles
        do
            if bobbles[i].poppable then
                count = count + 1
            end
        end
        if count >=3 then
            -- Remove from neighbors arrays
            for i=1,#bobbles
            do
                for j=#bobbles[i].neighbors,1,-1
                do
                    if bobbles[i].neighbors[j].poppable then
                        bobbles[i].neighbors[j]:remove()
                        table.remove(bobbles[i].neighbors, j)
                    end
                end
            end
            -- Remove from bobbles array
            for i=#bobbles,1,-1
            do
                if bobbles[i].poppable then
                    bobbles[i]:remove()
                    table.remove(bobbles, i)
                end
            end
            for i=1,#bobbles
            do
                bobbles[i].poppable = false
                for j=1,#bobbles[i].neighbors
                do
                    bobbles[i].neighbors[j].poppable = false
                end
            end
            -- Check for free hanging bobbles (not attached to a sticky wall) and remove them
        else
            for i=1,#bobbles
            do
                bobbles[i].poppable = false
                for j=1,#bobbles[i].neighbors
                do
                    bobbles[i].neighbors[j].poppable = false
                end
            end 
        end
    elseif view == 2 then
        -- Game Complete
    end

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

    -- Check for end of level
    if view == 0 then
        -- draw the level select view
        gridview:drawInRect(10, 10, 380, 220)
    elseif view == 1 then
        -- In level UI
        gfx.drawText(""..shotsFired, 5, 5)
        if #bobbles == 0 then
            -- LEVEL IS BEAT
            view = 2
        else 
            -- Displays the crank indicator
            -- NOTE: This needs to be placed after the updateTimers()
            if playdate.isCrankDocked() then
                playdate.ui.crankIndicator:update()
            end
        end
    elseif view == 2 then
        -- Game Complete UI
        -- Draw Nineslice
        slice:drawInRect(40,40,320,160)
        --gfx.drawText(, 200,120, kTextAlignment.center)

        gfx.drawTextInRect("LEVEL COMPLETE", 40, 75, 320, 160, nil, nil, kTextAlignment.center)
        if scores[currentLevel] == nil or shotsFired < scores[currentLevel] then
            gfx.drawTextInRect("NEW HIGH SCORE: "..shotsFired, 40, 105, 320, 160, nil, nil, kTextAlignment.center)
        else
            gfx.drawTextInRect("SCORE: "..shotsFired, 40, 105, 320, 160, nil, nil, kTextAlignment.center)
        end

        -- Draw Level Select
        if playdate.buttonIsPressed(playdate.kButtonA) then
            -- Draws black box underneath selected option when button is down
            gfx.fillRoundRect(63, 130, 110, 50, 4)
        end
        buttonA = gfx.image.new("images/buttonA")
        buttonA:draw(110, 140)
        gfx.drawTextInRect("LEVEL SELECT ", 40, 165, 160, 160, nil, nil, kTextAlignment.center)
        
        -- Draw Retry Level
        if playdate.buttonIsPressed(playdate.kButtonB) then
            -- Draws black box underneath selected option when button is down
            gfx.fillRoundRect(223, 130, 110, 50, 4)
        end
        buttonB = gfx.image.new("images/buttonB")
        buttonB:draw(270, 140)
        gfx.drawTextInRect("RETRY LEVEL ", 160, 165, 240, 160, nil, nil, kTextAlignment.center)
    elseif view == 3 then
        slice:drawInRect(40,40,320,160)
        gfx.drawTextInRect("USE THE CRANK TO AIM", 40, 75, 320, 160, nil, nil, kTextAlignment.center)
        gfx.drawTextInRect("USE D-PAD TO FIRE THE BOBBLE", 40, 100, 320, 160, nil, nil, kTextAlignment.center)
        gfx.drawTextInRect("PRESS A TO DISMISS", 40, 150, 320, 160, nil, nil, kTextAlignment.center)
        --playdate.ui.crankIndicator:update()
    end
end

-- Sets menu button items
-- Investigate if they can change during runtime
local menu = playdate.getSystemMenu()

-- Restarts the level if in game
local menuItem, error = menu:addMenuItem("Restart Level", function()
    if view == 1 then
        print("Restart Level")
        removeAllBobbles()
        -- Loads level again
        shotsFired = 0
        loadLevel(currentLevel)
    end
end)

-- Switches back to level select if in game
local menuItem, error = menu:addMenuItem("Level Select", function()
    if constants.DEBUG then
        view = 2 -- DEBUG easy access to level complete screen
                 -- Retry Level button will NOT work when accessing this way
    end
    if view == 1 then
        print("Level Select")
        removeAllBobbles()
        -- Changes back to the level select view
        currentLevel = ""
        shotsFired = 0
        view = 0
    end
end)

-- Delete level scores
local menuItem, error = menu:addMenuItem("Settings", function()
    view = 4
    -- Old code for delete save information. Saving for future use
    if view == 0 then
        print("Delete Scores")
        playdate.datastore.delete()
        scores = {}
    end
end)
