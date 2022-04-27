import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics

Barrier = {}
Barrier.__index = Barrier

local kBobble = 1
local kBarrier = 2

function Barrier:create(x, y, isHorizontal, isSticky)
    local barr = {}

    local barrierImage = gfx.image.new("images/border")
    assert( barrierImage ) -- make sure the image was where we thought
    
    setmetatable(barr, Barrier)
    barr.isHorizontal = isHorizontal
    barr.barrierSprite = gfx.sprite.new( barrierImage )
    barr.barrierSprite.entity = kBarrier
    barr.barrierSprite.isSticky = isSticky

    barr.barrierSprite:moveTo( x, y ) 
    barr.barrierSprite:add()
    barr.barrierSprite:setGroups(2)
    if not isHorizontal then
        barr.barrierSprite:setRotation(90)
    end
    barr.barrierSprite:setCollideRect(0, 0, barr.barrierSprite:getSize())
    if isSticky then
        barr.barrierSprite.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    else
        barr.barrierSprite.collisionResponse = gfx.sprite.kCollisionTypeBounce
    end
end