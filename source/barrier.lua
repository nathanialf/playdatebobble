import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics

class('Barrier').extends(playdate.graphics.sprite)

-- Constructor
function Barrier:create(x, y, isHorizontal, isSticky)
    local barr = Barrier()

    local barrierImage
    if isSticky then
        barrierImage = gfx.image.new("images/borderSticky")
    else
        barrierImage = gfx.image.new("images/border")
    end

    assert( barrierImage ) -- make sure the image was where we thought
    
    barr.isHorizontal = isHorizontal
    barr:setImage( barrierImage )
    barr.isSticky = isSticky

    -- Sets opacity
    -- Unused but just in case it ends up being used and I forget
    barr:setOpaque(true)

    barr:moveTo( x, y ) 
    barr:addSprite()
    
    -- used to tell what the object is during collisions
    barr.entity = kBARRIER

    -- sets the collision group this object is in
    barr:setGroups(kBARRIER)
    if not isHorizontal then
        barr:setRotation(90)
    end

    -- collision rect is set to the sprites location and dimensions
    barr:setCollideRect(0, 0, barr:getSize())

    -- sets the collision type depending on the if it is sticky or not
    if isSticky then
        barr.collisionResponse = gfx.sprite.kCollisionTypeFreeze
    else
        barr.collisionResponse = gfx.sprite.kCollisionTypeBounce
    end

    return barr
end