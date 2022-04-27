import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics


Bobble = {}
Bobble.__index = Bobble

function Bobble:create(type)
    local bble = {}

    local bobbleImage = gfx.image.new("images/bobble" .. tostring(type))
    assert( bobbleImage ) -- make sure the image was where we thought
    
    setmetatable(bble, Bobble)
    -- Type is an integer that can only be 1,2 or 3
    bble.type = type
    bble.angle = 0
    bble.bobbleSprite = gfx.sprite.new( bobbleImage )
    
    bble.bobbleSprite:moveTo( 200, 120 )
    bble.bobbleSprite:add()

    return bble
end

function Bobble:create(type, x, y, angle)
    local bble = {}

    local bobbleImage = gfx.image.new("images/bobble" .. tostring(type))
    assert( bobbleImage ) -- make sure the image was where we thought
    
    setmetatable(bble, Bobble)
    -- Type is an integer that can only be 1,2 or 3
    bble.type = type
    bble.angle = angle
    bble.bobbleSprite = gfx.sprite.new( bobbleImage )
    bble.speedX = 2
    bble.speedY = 2
    
    bble.bobbleSprite:moveTo( x, y ) 
    bble.bobbleSprite:add()
    bble.bobbleSprite:setCollideRect(0, 0, bble.bobbleSprite:getSize())
    bble.bobbleSprite:setGroups(1)
    bble.bobbleSprite:setCollidesWithGroups({2})
    --bble.bobbleSprite.collisionResponse = gfx.sprite.kCollisionTypeFreeze

    return bble
end

function Bobble:getType()
    return self.type
end

function Bobble:move(deltaTime)
    local velocX = -math.cos(math.rad(self.angle)) * self.speedX-- * deltaTime
    local velocY = -math.sin(math.rad(self.angle)) * self.speedY-- * deltaTime
    local spriteX, spriteY, spriteWidth, spriteHeight = self.bobbleSprite:getPosition()
    local actualX, actualY, collisions, collisionCount = self.bobbleSprite:moveWithCollisions(spriteX + velocX, spriteY + velocY)
    --self.bobbleSprite:moveBy(velocX, velocY)
    for i=1, collisionCount do
        local collision = collisions[i]
        -- when a player or monster collides with anything just bounce off of it
        if collision.normal.x ~= 0 then -- hit something in the X direction
            self.speedX = -self.speedX
        end
        if collision.normal.y ~= 0 then -- hit something in the Y direction
            self.speedY = -self.speedY
        end

                --if ( s.type == kPlayerType and collision.other.type == kMonsterType ) or
                --   ( s.type == kMonsterType and collision.other.type == kPlayerType ) then
                        -- a player and monster collided with each other!
                --        s:hit()
                --        collision.other:hit()
                --end
    end
end