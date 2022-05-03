-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import "bobble"
import "barrier"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil
local previewSprite = nil

-- Current angle that the arrow is facing and that the bobble will be shot at
local double arrowRotation = 0
-- Prevents the arrow from rotating upwards after reaching the arrowUpLimit
local boolean stopRotatingUp = false
-- Prevents the arrow from rotating downwards after reaching the arrowDownLimit
local boolean stopRotatingDown = false
-- For the next two variables, 0 degrees is pointing left, 90 is point up, and 270 is pointing down
-- angle of the upper limit for the arrow to rotate to
local double arrowUpLimit = 80
-- angle of the lower limit for the arrow to rotate to
local double arrowDownLimit = 280

-- stores the next type of bobble to shot out. randomized after each firing
local integer nextBobble = 1

-- has the crankIndicator been started
local boolean crankIndicatorStarted = false

-- Arrays (tables?) of bobbles and barriers
local bobbles = {}
local barriers = {}

-- Used for delta time
local lastTime = playdate.getCurrentTimeMilliseconds()

-- view is the state the game is in at any given moment
-- 0 = Level select
-- 1 = In Level
-- 2 = Level Complete
-- 3 = Level Failed
local view = 0

-- Menu stuff
-- From Menu example in SDK

local gridFont = gfx.font.new("fonts/blocky")
assert(gridFont)
gridFont:setTracking(1)

gridview = playdate.ui.gridview.new(44, 44)


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

    if playdate.buttonJustPressed(playdate.kButtonA) and selected then
        if section == 1 and row == 1 and column == 1 then
            loadLevel("levels/test_easy.lvl")
        end
        if section == 1 and row == 1 and column == 2 then
            loadLevel("levels/test.lvl")
        end
    end

end

function gridview:drawSectionHeader(section, x, y, width, height)
    gfx.drawText("*Section ".. section .. "*", x + 10, y + 8)
end

-- buttons --
function playdate.AButtonUp()
    --toggleSelection()
end
function playdate.BButtonUp()
    --toggleSelection()
end

function playdate.upButtonUp()
    if view == 0 then
        gridview:selectPreviousRow(true)
    end
end

function playdate.downButtonUp()
    if view == 0 then
        gridview:selectNextRow(true)
    end
end

function playdate.leftButtonUp()
    if view == 0 then
        gridview:selectPreviousColumn(true)
    end
end

function playdate.rightButtonUp()
    if view == 0 then
        gridview:selectNextColumn(true)
    end
end
--

-- function to setup up the preview bobble (used multiple times)
function setUpPreviewBobble()
    previewSprite = gfx.sprite.new(gfx.image.new("images/bobble" .. tostring(nextBobble)))
    previewSprite:moveTo( 400, 120 )
    previewSprite:add()
end

-- function to load levels. Hardcoded for first draft
function loadLevel(levelFileName)
    local file = playdate.file.open(levelFileName, playdate.file.kFileRead)
    repeat
        local l = file:readline()
        if l then
            --splits string into an array
            --Line structure in level file should be
            --Input types:
            --B = Bobble
            --B <Bobble Type (1-3)> <X Coordinate> <Y Coordinate>
            --N = Neighbor
            --N <Bobble a> <Bobble b>
            ----Note: You will need to have an entry for N <a> <b> and N <b> <a>
            local result = {};
            for match in (l.." "):gmatch("(.-)".." ") do
                table.insert(result, match);
            end
            -- creates stationary bobble from the data in the line
            if result[1] == "B" then
                table.insert(
                    bobbles, 
                    Bobble:createStationary(
                        tonumber(result[2]), 
                        tonumber(result[3]), 
                        tonumber(result[4])
                    )
                )
            elseif result[1] == "N" then
                table.insert(
                    bobbles[tonumber(result[2])].bobbleSprite.neighbors, 
                    bobbles[tonumber(result[3])].bobbleSprite
                )
            end
        end
    until l == nil

    file:close()
    
    arrowRotation = 0
    view = 1
end

-- A function to set up our game environment.

function myGameSetUp()
    -- sets the seed to use for random number generation
    math.randomseed(playdate.getSecondsSinceEpoch())
    -- starts with a random number for the bobble and is rolled again after every shot
    nextBobble = math.random(1,3)

    -- Starts Crank Indicator
    playdate.ui.crankIndicator:start()

    -- Set up the player sprite.
    -- The :setCenter() call specifies that the sprite will be anchored at its center.
    -- The :moveTo() call moves our sprite to the center of the display.

    local playerImage = gfx.image.new("images/arrow")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )

    -- Sets opacity
    playerSprite:setOpaque(false)

    playerSprite:moveTo( 400, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!

    setUpPreviewBobble()

    local borderImage = gfx.image.new("images/border")
    assert( borderImage ) -- make sure the image was where we thought

    -- Four walls to prevent the balls from escaping
    barriers[1] = Barrier:create(10, 120, false, true)
    barriers[2] = Barrier:create(200, 230, true, false)
    barriers[3] = Barrier:create(200, 10, true, false)
    barriers[4] = Barrier:create(420, 120, false, false)

    -- loads a level
    --loadLevel("levels/test.lvl")
    --loadLevel("levels/test_easy.lvl")

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

    gridview.backgroundImage = playdate.graphics.nineSlice.new('images/shadowbox', 4, 4, 45, 45)
    gridview:setNumberOfColumns(2)
    gridview:setNumberOfRows(1, 1, 1, 1) -- number of sections is set automatically
    gridview:setSectionHeaderHeight(28)
    gridview:setContentInset(1, 4, 1, 4)
    gridview:setCellPadding(4, 4, 4, 4)
    gridview.changeRowOnColumnWrap = false

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

    -- Poll the d-pad and move our player accordingly.
    -- (There are multiple ways to read the d-pad; this is the simplest.)
    -- Note that it is possible for more than one of these directions
    -- to be pressed at once, if the user is pressing diagonally.

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
            -- when pressing the up d-pad
            if playdate.buttonJustPressed(playdate.kButtonA) then
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
                    -- picks the type of bobble for the next shot
                    nextBobble = math.random(1,3)
                    --nextBobble = 3 --debug
                    -- resets the preview bobble so it displays accurately
                    previewSprite:remove()
                    previewSprite = nil
                    setUpPreviewBobble()
                end
            end
            
            -- prevents the angle we want to shoot at from going above or below a certain threshold
            if arrowRotation >= arrowUpLimit and arrowRotation < 180 then
                stopRotatingUp = true
                arrowRotation = arrowUpLimit
            else
                stopRotatingUp = false
            end
            if arrowRotation <= arrowDownLimit and arrowRotation >= 180 then
                stopRotatingDown = true
                arrowRotation = arrowDownLimit
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
            if bobbles[i].bobbleSprite.poppable then
                count = count + 1
            end
        end
        if count >=3 then
            -- Remove from neighbors arrays
            for i=1,#bobbles
            do
                for j=#bobbles[i].bobbleSprite.neighbors,1,-1
                do
                    if bobbles[i].bobbleSprite.neighbors[j].poppable then
                        bobbles[i].bobbleSprite.neighbors[j]:remove()
                        table.remove(bobbles[i].bobbleSprite.neighbors, j)
                    end
                end
            end
            -- Remove from bobbles array
            for i=#bobbles,1,-1
            do
                if bobbles[i].bobbleSprite.poppable then
                    bobbles[i].bobbleSprite:remove()
                    table.remove(bobbles, i)
                end
            end
            for i=1,#bobbles
            do
                bobbles[i].bobbleSprite.poppable = false
                for j=1,#bobbles[i].bobbleSprite.neighbors
                do
                    bobbles[i].bobbleSprite.neighbors[j].poppable = false
                end
            end 
        else
            for i=1,#bobbles
            do
                bobbles[i].bobbleSprite.poppable = false
                for j=1,#bobbles[i].bobbleSprite.neighbors
                do
                    bobbles[i].bobbleSprite.neighbors[j].poppable = false
                end
            end 
        end
    elseif view == 2 then
        -- Game Complete
    elseif view == 3 then
        -- Game Failed
    end

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

    -- Check for end of level
    if view == 0 then
        -- draw the level select view
        gridview:drawInRect(20, 20, 360, 200)
    elseif view == 1 then
        -- In level UI
        if #bobbles == 0 then
            -- LEVEL IS BEAT
            -- Apply score to a file
            -- Score isnt defined yet, probably will be time and shots fired
            -- NOTE: This needs to be placed after the  gfx.sprite.update()
            gfx.drawText("*Level Complete*", 40, 40)
            view = 0
            --print("Level Complete") -- Debug
        else 
            -- Displays the crank indicator
            -- NOTE: This needs to be placed after the updateTimers()
            if playdate.isCrankDocked() then
                playdate.ui.crankIndicator:update()
            end
        end
    elseif view == 2 then
        -- Game Complete UI
    elseif view == 3 then
        -- Game Failed UI
    end
end
