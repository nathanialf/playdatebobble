import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

local gfx <const> = playdate.graphics

class('Bobble').extends(playdate.graphics.sprite)

-- constructor for level bobbles
function Bobble:createStationary(type, x, y, attachedToWall)
    local bble = Bobble()

    --ensures the bobbles wont move
    bble.isMoving = false
    bble.angle = 0
    bble.speedX = 0
    bble.speedY = 0
    bble.type = type
    bble.attachedToWall = attachedToWall

    bble:createSprite(type)
    
    bble:moveTo( x, y ) 
    bble:addSprite()

    return bble
end

-- constructor for the fired bobbles
function Bobble:create(type, x, y, angle)
    local bble = Bobble()
    
    -- firing angle the bobble will move at
    bble.angle = angle
    -- speed the bobble will move at in each axis
    bble.speedX = .4
    bble.speedY = .4
    bble.type = type
    bble.attachedToWall = false

    bble.isMoving = true

    bble:createSprite(type)
    
    bble:moveTo( x, y ) 
    bble:addSprite()

    return bble
end

function Bobble:createSprite(type)

    local bobbleImage = gfx.image.new("images/bobble" .. tostring(type))
    assert( bobbleImage ) -- make sure the image was where we thought
    self:setImage( bobbleImage )
    
    -- Type is an integer that can only be 1,2 or 3
    self.type = type

    -- used to tell what the object is during collisions
    self.entity = constants.kBOBBLE

    -- Sets opacity
    self:setOpaque(false)

    -- collision rect is set to the sprites location and dimensions
    self:setCollideRect(0, 0, self:getSize())
    -- sets the collision group this object is in
    self:setGroups(constants.kBOBBLE)
    -- sets what collision groups this object can collide
    self:setCollidesWithGroups({constants.kBOBBLE, constants.kBARRIER})
    -- sets if we can should try to pop the bobble
    self.poppable = false

    -- Neighbors of bobbles to check for popping
    self.neighbors = {}
end

-- called when the bobble collides with another of the same type
function Bobble:setPoppableOnCollision()
    self.poppable = true
    -- Sets poppable to be true on all neighbors of the same type
    for i=1,#(self.neighbors)
    do
        if self.neighbors[i] ~= nil then
            if (not self.neighbors[i].poppable) and (self.neighbors[i].type == self.type) then
                self.neighbors[i]:setPoppableOnCollision()
            elseif not self.neighbors[i].poppable and self.neighbors[i].type ~= self.type then
                -- Set a variable here for checking for floating. Will be used
            end
        end
    end
end

function Bobble:move(deltaTime)
    -- movement
    if self.isMoving then
        local velocX = -math.cos(math.rad(self.angle)) * self.speedX * deltaTime
        local velocY = -math.sin(math.rad(self.angle)) * self.speedY * deltaTime
        local spriteX, spriteY, spriteWidth, spriteHeight = self:getPosition()
        local actualX, actualY, collisions, collisionCount = self:moveWithCollisions(spriteX + velocX, spriteY + velocY)
        
        for i=1, collisionCount do
            local collision = collisions[i]
    
            if collision.other.entity == constants.kBARRIER and not collision.other.isSticky then
                -- when a player or monster collides with anything just bounce off of it
                if collision.normal.x ~= 0 then -- hit something in the X direction
                    self.speedX = -self.speedX
                end
                if collision.normal.y ~= 0 then -- hit something in the Y direction
                    self.speedY = -self.speedY
                end
            elseif collision.other.entity == constants.kBARRIER and collision.other.isSticky then
                self.isMoving = false
                self.attachedToWall = true
            else
                self.isMoving = false
                -- Check Collisions for popping bobbles
                if collision.other.entity == constants.kBOBBLE then
                    -- Add to neighborhood
                    self.neighbors[#self.neighbors + 1] = collision.other
                    collision.other.neighbors[#collision.other.neighbors + 1] = self
                    -- Check for pops
                    self:setPoppableOnCollision()
                end
            end
        end
    end
end
