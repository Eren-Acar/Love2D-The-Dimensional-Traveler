local Bullet = {}
Bullet.__index = Bullet

Bullet.image = love.graphics.newImage("assets/bullet/1.png")

function Bullet.create(x, y, direction)
    local self = setmetatable({}, Bullet)

    self.x = x
    self.y = y
    self.width = Bullet.image:getWidth()
    self.height = Bullet.image:getHeight()
    self.speed = 320
    self.direction = direction or 1
    self.dead = false

    return self
end

function Bullet:update(dt)
    self.x = self.x + self.speed * self.direction * dt
end

function Bullet:draw()
    local scaleX = self.direction

    love.graphics.draw(
        Bullet.image,
        self.x,
        self.y,
        0,
        scaleX,
        1,
        self.width / 2,
        self.height / 2
    )
end

function Bullet:getRect()
    return self.x - self.width / 2,
           self.y - self.height / 2,
           self.width,
           self.height
end

return Bullet