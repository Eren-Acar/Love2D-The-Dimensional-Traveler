local Enemy = {}
Enemy.__index = Enemy

local Player = require("objects.player")

local ActiveEnemies = {}

local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and
          x2 < x1 + w1 and
          y1 < y2 + h2 and
          y2 < y1 + h1
end

function Enemy.removeAll()
   for _, enemy in ipairs(ActiveEnemies) do
      if enemy.physics and enemy.physics.body then
         enemy.physics.body:destroy()
      end
   end

   ActiveEnemies = {}
end

function Enemy.new(x, y)
   local instance = setmetatable({}, Enemy)

   instance.x = x
   instance.y = y
   instance.offsetY = -8
   instance.r = 0

   instance.speed = 100
   instance.speedMod = 1
   instance.xVel = instance.speed

   instance.minX = 1105
   instance.maxX = 1419
   instance.fixedY = y

   instance.rageCounter = 0
   instance.rageTrigger = 3

   instance.damage = 1
   instance.health = 3
   instance.dead = false

   instance.state = "walk"

   instance.animation = { timer = 0, rate = 0.1 }
   instance.animation.run = { total = 4, current = 1, img = Enemy.runAnim }
   instance.animation.walk = { total = 4, current = 1, img = Enemy.walkAnim }
   instance.animation.draw = instance.animation.walk.img[1]

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
   instance.physics.body:setFixedRotation(true)
   instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.4, instance.height * 0.75)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.body:setMass(25)

   table.insert(ActiveEnemies, instance)
end

function Enemy.loadAssets()
   Enemy.runAnim = {}
   for i = 1, 4 do
      Enemy.runAnim[i] = love.graphics.newImage("assets/enemy/run/" .. i .. ".png")
   end

   Enemy.walkAnim = {}
   for i = 1, 4 do
      Enemy.walkAnim[i] = love.graphics.newImage("assets/enemy/walk/" .. i .. ".png")
   end

   Enemy.width = Enemy.runAnim[1]:getWidth()
   Enemy.height = Enemy.runAnim[1]:getHeight()
end

function Enemy:update(dt)
   if self.dead then
      return
   end

   self:syncPhysics()
   self:checkBounds()
   self:animate(dt)
end

function Enemy:incrementRage()
   self.rageCounter = self.rageCounter + 1

   if self.rageCounter > self.rageTrigger then
      self.state = "run"
      self.speedMod = 3
      self.rageCounter = 0
   else
      self.state = "walk"
      self.speedMod = 1
   end
end

function Enemy:flipDirection()
   self.xVel = -self.xVel
end

function Enemy:checkBounds()
   if self.x >= self.maxX and self.xVel > 0 then
      self:flipDirection()
   elseif self.x <= self.minX and self.xVel < 0 then
      self:flipDirection()
   end
end

function Enemy:takeDamage(amount)
   self.health = self.health - amount

   if self.health <= 0 then
      self.dead = true

      if self.physics and self.physics.body then
         self.physics.body:destroy()
      end
   end
end

function Enemy:animate(dt)
   self.animation.timer = self.animation.timer + dt

   if self.animation.timer > self.animation.rate then
      self.animation.timer = 0
      self:setNewFrame()
   end
end

function Enemy:setNewFrame()
   local anim = self.animation[self.state]

   if anim.current < anim.total then
      anim.current = anim.current + 1
   else
      anim.current = 1
   end

   self.animation.draw = anim.img[anim.current]
end

function Enemy:syncPhysics()
   local x, _ = self.physics.body:getPosition()
   self.physics.body:setPosition(x, self.fixedY)

   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.xVel * self.speedMod, 0)
end

function Enemy:draw()
   if self.dead then
      return
   end

   local scaleX = 1
   if self.xVel < 0 then
      scaleX = -1
   end

   love.graphics.draw(
      self.animation.draw,
      self.x,
      self.y + self.offsetY,
      self.r,
      scaleX,
      1,
      self.width / 2,
      self.height / 2
   )
end

function Enemy.updateAll(dt)
   for _, instance in ipairs(ActiveEnemies) do
      instance:update(dt)
   end
end

function Enemy.drawAll()
   for _, instance in ipairs(ActiveEnemies) do
      instance:draw()
   end
end

function Enemy.cleanupDead()
   for i = #ActiveEnemies, 1, -1 do
      if ActiveEnemies[i].dead then
         table.remove(ActiveEnemies, i)
      end
   end
end

function Enemy.checkBulletHits(bullets)
   for i = #bullets, 1, -1 do
      local bullet = bullets[i]
      local bx, by, bw, bh = bullet:getRect()
      local hit = false

      for _, enemy in ipairs(ActiveEnemies) do
         if not enemy.dead then
            local ex = enemy.x - enemy.width / 2
            local ey = enemy.y + enemy.offsetY - enemy.height / 2
            local ew = enemy.width
            local eh = enemy.height

            if checkCollision(bx, by, bw, bh, ex, ey, ew, eh) then
               enemy:takeDamage(1)
               hit = true
               break
            end
         end
      end

      if hit then
         table.remove(bullets, i)
      end
   end

   Enemy.cleanupDead()
end

function Enemy.beginContact(a, b, collision)
   for _, instance in ipairs(ActiveEnemies) do
      if not instance.dead and (a == instance.physics.fixture or b == instance.physics.fixture) then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
         end

         instance:incrementRage()
      end
   end
end

return Enemy