-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

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

local double arrowRotation = 0
local boolean stopRotatingUp = false
local boolean stopRotatingDown = false
local double arrowUpLimit = 80
local double arrowDownLimit = 280

local integer nextBobble = 1

local bobbles = {}
local barriers = {}

-- A function to set up our game environment.

function myGameSetUp()

    math.randomseed(playdate.getSecondsSinceEpoch())
    nextBobble = math.random(1,3)

    -- Set up the player sprite.
    -- The :setCenter() call specifies that the sprite will be anchored at its center.
    -- The :moveTo() call moves our sprite to the center of the display.

    local playerImage = gfx.image.new("images/arrow")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 400, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!

    previewSprite = gfx.sprite.new( gfx.image.new("images/bobble" .. tostring(nextBobble)) )
    previewSprite:moveTo( 400, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    previewSprite:add() -- This is critical!

    local borderImage = gfx.image.new("images/border")
    assert( borderImage ) -- make sure the image was where we thought

    barriers[1] = Barrier:create(200, 10, true, false)
    barriers[2] = Barrier:create(200, 230, true, false)
    barriers[3] = Barrier:create(10, 120, false, true)
    barriers[3] = Barrier:create(420, 120, false, false)

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

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.
local lastTime = playdate.getCurrentTimeMilliseconds()

function playdate.update()

    -- Poll the d-pad and move our player accordingly.
    -- (There are multiple ways to read the d-pad; this is the simplest.)
    -- Note that it is possible for more than one of these directions
    -- to be pressed at once, if the user is pressing diagonally.

    -- TODO: Crank Alert
    -- https://sdk.play.date/1.10.0/Inside%20Playdate.html#C-ui.crankIndicator

    local currentTime = playdate.getCurrentTimeMilliseconds()
    local deltaTime = currentTime - lastTime
    lastTime = currentTime

    playerSprite:setRotation(arrowRotation)

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

    if (playdate.getCrankChange() > 0 and not stopRotatingUp) then
        arrowRotation += playdate.getCrankChange();
    elseif (playdate.getCrankChange() < 0 and not stopRotatingDown) then
        arrowRotation += playdate.getCrankChange();
    end

    arrowRotation = arrowRotation % 360

    for i=1,#(bobbles) 
    do
        -- add a conditional for if the latest bobble is moving
        bobbles[i]:move(deltaTime)
    end

    if playdate.buttonJustPressed(playdate.kButtonUp) then
        local num = #(bobbles) + 1
        if #(bobbles) == 0 or not bobbles[#(bobbles)].isMoving then
            bobbles[num] = Bobble:create(nextBobble, 400, 120, arrowRotation)
            nextBobble = math.random(1,3)
            previewSprite:remove()
            previewSprite = nil
            previewSprite = gfx.sprite.new( gfx.image.new("images/bobble" .. tostring(nextBobble)) )
            previewSprite:moveTo( 400, 120 )
            previewSprite:add()
        end
    end

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

    --gfx.drawText(tostring(stopRotatingDown), 10, 10)
    --gfx.drawText(tostring(playdate.getCrankChange()), 10, 30)

end
