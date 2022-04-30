import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics

Bobble = {}
Bobble.__index = Bobble

local kBobble = 1
local kBarrier = 2

-- constructor for level bobbles
function Bobble:createStationary(type, x, y)
    local bble = {}
    
    setmetatable(bble, Bobble)
    --ensures the bobbles wont move
    bble.isMoving = false
    bble.angle = 0
    bble.speedX = 0
    bble.speedY = 0
    bble.type = type

    bble.bobbleSprite = createBobbleSprite(type)
    
    bble.bobbleSprite:moveTo( x, y ) 
    bble.bobbleSprite:add()
end

-- constructor for the fired bobbles
function Bobble:create(type, x, y, angle)
    local bble = {}
    
    setmetatable(bble, Bobble)
    -- firing angle the bobble will move at
    bble.angle = angle
    -- speed the bobble will move at in each axis
    bble.speedX = .2
    bble.speedY = .2
    bble.type = type

    bble.isMoving = true

    bble.bobbleSprite = createBobbleSprite(type)
    
    bble.bobbleSprite:moveTo( x, y ) 
    bble.bobbleSprite:add()

    return bble
end

function createBobbleSprite(type)

    local bobbleImage = gfx.image.new("images/bobble" .. tostring(type))
    assert( bobbleImage ) -- make sure the image was where we thought
    bobbleSprite = gfx.sprite.new( bobbleImage )
    
    -- Type is an integer that can only be 1,2 or 3
    bobbleSprite.type = type

    -- used to tell what the object is during collisions
    bobbleSprite.entity = kBobble

    -- UUID
    bobbleSprite.UUID = playdate.string.UUID(15)

    -- collision rect is set to the sprites location and dimensions
    bobbleSprite:setCollideRect(0, 0, bobbleSprite:getSize())
    -- sets the collision group this object is in
    bobbleSprite:setGroups(kBobble)
    -- sets what collision groups this object can collide
    bobbleSprite:setCollidesWithGroups({kBobble, kBarrier})
    -- sets if we can should try to pop the bobble
    bobbleSprite.poppable = false

    -- Neighbors of bobbles to check for popping
    bobbleSprite.neighbors = {}

    return bobbleSprite
end

function playdate.graphics.sprite:setPoppableOnCollision()

    -- NEW IDEA
    -- Add a try to Pop variable to the bobbles through the network of neighbors.
    -- Check in main.lua through all the bobbles in the array to see if the amount to pop is past the threshold
    -- pop them all if past the threshold, reset the try to pop variable otherwise

    -- This isnt going deep. only runs once per impact no matter what
    
    self.poppable = true
    --print(self.poppable)
    for i=1,#(self.neighbors)
    do
        if (not self.neighbors[i].poppable) and (self.neighbors[i].type == self.type) then
            self.neighbors[i]:setPoppableOnCollision()
        end
    end
end

function Bobble:move(deltaTime)
    -- movement
    if self.isMoving then
        local velocX = -math.cos(math.rad(self.angle)) * self.speedX * deltaTime
        local velocY = -math.sin(math.rad(self.angle)) * self.speedY * deltaTime
        local spriteX, spriteY, spriteWidth, spriteHeight = self.bobbleSprite:getPosition()
        local actualX, actualY, collisions, collisionCount = self.bobbleSprite:moveWithCollisions(spriteX + velocX, spriteY + velocY)
        
        for i=1, collisionCount do
            local collision = collisions[i]
    
            if collision.other.entity == kBarrier and not collision.other.isSticky then
                -- when a player or monster collides with anything just bounce off of it
                if collision.normal.x ~= 0 then -- hit something in the X direction
                    self.speedX = -self.speedX
                end
                if collision.normal.y ~= 0 then -- hit something in the Y direction
                    self.speedY = -self.speedY
                end
            else
                self.isMoving = false
                -- Check Collisions for popping bobbles
                if collision.other.entity == kBobble then
                    -- Add to neighborhood
                    self.bobbleSprite.neighbors[#self.bobbleSprite.neighbors + 1] = collision.other
                    collision.other.neighbors[#collision.other.neighbors + 1] = self.bobbleSprite
                    -- Check for pops
                    self.bobbleSprite:setPoppableOnCollision()
                end
            end
        end
    end
end