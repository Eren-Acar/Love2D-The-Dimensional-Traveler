local Player = {}
local Bullet = require("objects.bullet")

function Player:load()
   self.x = 100
   self.y = 0
   self.startX = self.x
   self.startY = self.y

   self.width = 20
   self.height = 60

   self.xVel = 0
   self.yVel = 0
   self.maxSpeed = 200
   self.acceleration = 4000
   self.friction = 3500
   self.gravity = 1500
   self.jumpAmount = -500

   self.coins = 0
   self.health = { current = 5, max = 5 }

   self.bullets = {}
   self.shootCooldown = 0.35
   self.shootTimer = 0
   self.facing = 1

   self.color = {
      red = 1,
      green = 1,
      blue = 1,
      speed = 3
   }

   self.graceTime = 0
   self.graceDuration = 0.1

   self.alive = true
   self.dead = false
   self.grounded = false
   self.hasDoubleJump = true

   self.direction = "right"
   self.state = "idle"

   self.isShooting = false
   self.shootAnimationFinished = false
   self.shootAnimationRate = 0.035

   self:loadAssets()

   self.physics = {}
   self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
   self.physics.body:setFixedRotation(true)
   self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
   self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
   self.physics.body:setGravityScale(0)

   self.sounds = {}
   self.sounds.jump = love.audio.newSource("assets/sfx/jump.wav", "static")
   self.sounds.hit = love.audio.newSource("assets/sfx/hit.wav", "static")
end

function Player:loadAssets()
   self.animation = { timer = 0, rate = 0.1 }

   self.animation.run = { total = 8, current = 1, img = {} }
   for i = 1, self.animation.run.total do
      self.animation.run.img[i] = love.graphics.newImage("assets/player/run/" .. i .. ".png")
   end

   self.animation.idle = { total = 7, current = 1, img = {} }
   for i = 1, self.animation.idle.total do
      self.animation.idle.img[i] = love.graphics.newImage("assets/player/idle/" .. i .. ".png")
   end

   self.animation.air = { total = 4, current = 1, img = {} }
   for i = 1, self.animation.air.total do
      self.animation.air.img[i] = love.graphics.newImage("assets/player/air/" .. i .. ".png")
   end

   self.animation.shoot = {total = 7, current = 1, img = {}}
   for i = 1, self.animation.shoot.total do
      self.animation.shoot.img[i] = love.graphics.newImage("assets/player/shoot/" .. i .. ".png")
   end

   self.animation.draw = self.animation.idle.img[1]
   self.animation.width = self.animation.draw:getWidth()
   self.animation.height = self.animation.draw:getHeight()
end

function Player:takeDamage(amount)
   self:tintRed()

   if self.health.current - amount > 0 then
      self.health.current = self.health.current - amount
   else
      self.health.current = 0
      self:die()
   end
   self.sounds.hit:stop()
   self.sounds.hit:play()
end

function Player:die()
   self.alive = false
   self.dead = true
end


function Player:resetPosition()
   self.physics.body:setPosition(self.startX, self.startY)
end

function Player:tintRed()
   self.color.green = 0
   self.color.blue = 0
end

function Player:incrementCoins()
   self.coins = self.coins + 1
end

function Player:update(dt)
   if self.dead then
      return
   end

   self:unTint(dt)
   self:setState()
   self:setDirection()
   self:animate(dt)
   self:decreaseGraceTime(dt)
   self:syncPhysics()
   self:move(dt)
   self:applyGravity(dt)
   self:updateShootTimer(dt)
   self:updateBullets(dt)
end

function Player:updateShootTimer(dt)
   if self.shootTimer > 0 then
      self.shootTimer = self.shootTimer - dt
      if self.shootTimer < 0 then
         self.shootTimer = 0
      end
   end
end

function Player:updateBullets(dt)
   for i = #self.bullets, 1, -1 do
      local bullet = self.bullets[i]
      bullet:update(dt)

      if bullet.x < -200 or bullet.x > 5000 then
         table.remove(self.bullets, i)
      end
   end
end

function Player:unTint(dt)
   self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
   self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
   self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Player:setState()
   if self.isShooting then
      self.state = "shoot"
   elseif not self.grounded then
      self.state = "air"
   elseif self.xVel == 0 then
      self.state = "idle"
   else
      self.state = "run"
   end
end

function Player:setDirection()
   if self.xVel < 0 then
      self.direction = "left"
      self.facing = -1
   elseif self.xVel > 0 then
      self.direction = "right"
      self.facing = 1
   end
end

function Player:animate(dt)
   local currentRate = self.animation.rate

   if self.state == "shoot" then
      currentRate = self.shootAnimationRate
   end

   self.animation.timer = self.animation.timer + dt
   if self.animation.timer > currentRate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Player:setNewFrame()
   local anim = self.animation[self.state]

   if self.state == "shoot" then
      if anim.current < anim.total then
         anim.current = anim.current + 1
         self.animation.draw = anim.img[anim.current]
      else
         self.isShooting = false
         anim.current = 1
         local nextAnim = self.animation.idle
         self.animation.draw = nextAnim.img[nextAnim.current]
      end
   else
      if anim.current < anim.total then
         anim.current = anim.current + 1
      else
         anim.current = 1
      end
      self.animation.draw = anim.img[anim.current]
   end
end

function Player:decreaseGraceTime(dt)
   if not self.grounded then
      self.graceTime = self.graceTime - dt
   end
end

function Player:applyGravity(dt)
   if not self.grounded then
      self.yVel = self.yVel + self.gravity * dt
   end
end

function Player:move(dt)
   if love.keyboard.isDown("d", "right") then
      self.xVel = math.min(self.xVel + self.acceleration * dt, self.maxSpeed)
   elseif love.keyboard.isDown("a", "left") then
      self.xVel = math.max(self.xVel - self.acceleration * dt, -self.maxSpeed)
   else
      self:applyFriction(dt)
   end
end

function Player:applyFriction(dt)
   if self.xVel > 0 then
      self.xVel = math.max(self.xVel - self.friction * dt, 0)
   elseif self.xVel < 0 then
      self.xVel = math.min(self.xVel + self.friction * dt, 0)
   end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:beginContact(a, b, collision)
   if self.grounded == true then
      return
   end

   local nx, ny = collision:getNormal()

   if a == self.physics.fixture then
      if ny > 0 then
         self:land(collision)
      elseif ny < 0 then
         self.yVel = 0
      end
   elseif b == self.physics.fixture then
      if ny < 0 then
         self:land(collision)
      elseif ny > 0 then
         self.yVel = 0
      end
   end
end

function Player:land(collision)
   self.currentGroundCollision = collision
   self.yVel = 0
   self.grounded = true
   self.hasDoubleJump = true
   self.graceTime = self.graceDuration
end

function Player:jump(key)
   if key == "w" or key == "up" then
      if self.grounded or self.graceTime > 0 then
         self.yVel = self.jumpAmount
         self.graceTime = 0

         self.sounds.jump:stop()
         self.sounds.jump:play()

      elseif self.hasDoubleJump then
         self.hasDoubleJump = false
         self.yVel = self.jumpAmount * 0.8

         self.sounds.jump:stop()
         self.sounds.jump:play()
      end
   end
end

function Player:endContact(a, b, collision)
   if a == self.physics.fixture or b == self.physics.fixture then
      if self.currentGroundCollision == collision then
         self.grounded = false
      end
   end
end

function Player:shoot()
   if self.shootTimer > 0 then
      return
   end

   local bulletX
   if self.facing == 1 then
      bulletX = self.x + self.width
   else
      bulletX = self.x - self.width
   end

   local bulletY = self.y * 1.05

   table.insert(self.bullets, Bullet.create(bulletX, bulletY, self.facing))
   self.shootTimer = self.shootCooldown

   self.isShooting = true
   self.shootAnimationFinished = false
   self.animation.shoot.current = 1
   self.animation.timer = 0
end

function Player:draw()
   local scaleX = 1
   if self.direction == "left" then
      scaleX = -1
   end

   for _, bullet in ipairs(self.bullets) do
      bullet:draw()
   end

   love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
   love.graphics.draw(
      self.animation.draw,
      self.x,
      self.y,
      0,
      scaleX,
      1,
      self.animation.width / 2,
      self.animation.height / 2
   )
   love.graphics.setColor(1, 1, 1, 1)
end

return Player