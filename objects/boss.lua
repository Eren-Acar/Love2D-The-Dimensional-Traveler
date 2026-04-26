local Boss = {}
Boss.__index = Boss

Boss.defeated = false

local Player = require("objects.Player")

local ActiveBosses = {}

local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
   return x1 < x2 + w2 and
          x2 < x1 + w1 and
          y1 < y2 + h2 and
          y2 < y1 + h1
end

local BossBullet = {}
BossBullet.__index = BossBullet

function BossBullet.new(x, y, dx, dy)
   local self = setmetatable({}, BossBullet)

   self.frames = {
      love.graphics.newImage("assets/fireball/1.png"),
      love.graphics.newImage("assets/fireball/2.png"),
      love.graphics.newImage("assets/fireball/3.png"),
      love.graphics.newImage("assets/fireball/4.png"),
      love.graphics.newImage("assets/fireball/5.png")
   }

   self.currentFrame = 1
   self.animationTimer = 0
   self.animationSpeed = 0.12

   self.x = x
   self.y = y
   self.dx = dx
   self.dy = dy
   self.speed = 230

   self.width = 64
   self.height = 32

   self.dead = false

   return self
end

function BossBullet:update(dt)
   self.x = self.x + self.dx * self.speed * dt
   self.y = self.y + self.dy * self.speed * dt

   self.animationTimer = self.animationTimer + dt

   if self.animationTimer >= self.animationSpeed then
      self.animationTimer = 0
      self.currentFrame = self.currentFrame + 1

      if self.currentFrame > #self.frames then
         self.currentFrame = 1
      end
   end

   if self.x < -100 or self.x > 5000 or self.y < -100 or self.y > 3000 then
      self.dead = true
   end
end

function BossBullet:draw()
   local sprite = self.frames[self.currentFrame]

   local scaleX = self.width / sprite:getWidth()
   local scaleY = self.height / sprite:getHeight()

   local angle = math.atan2(self.dy, self.dx)

   love.graphics.setColor(1, 1, 1, 1)

   love.graphics.draw(
      sprite,
      self.x,
      self.y,
      angle,
      scaleX,
      scaleY,
      sprite:getWidth() / 2,
      sprite:getHeight() / 2
    )
end

function BossBullet:getRect()
   return self.x - self.width / 2,
          self.y - self.height / 2,
          self.width,
          self.height
end

function Boss.removeAll()
   ActiveBosses = {}
   Boss.defeated = false
end

function Boss.new(x, y)
   local instance = setmetatable({}, Boss)

   instance.sprite = love.graphics.newImage("assets/boss2.png")

   instance.x = x
   instance.y = y
   instance.startX = x
   instance.startY = y

   instance.width = 80
   instance.height = 80

   instance.health = 12
   instance.maxHealth = 12
   instance.phase = 1

   instance.moveSpeed = 70
   instance.yMin = y - 80
   instance.yMax = y + 80
   instance.directionY = 1

   instance.shootTimer = 0
   instance.shootCooldown = 2
   instance.normalShootCooldown = 2
   instance.phaseTwoShootCooldown = 1

   instance.contactDamage = 1
   instance.bulletDamage = 1
   instance.bullets = {}

   instance.detectionRange = 300
   instance.playerDetected = false
   instance.attackDelay = 0.5
   instance.attackDelayTimer = 0
   instance.canAttack = false

   instance.color = {
      red = 1,
      green = 1,
      blue = 1,
      speed = 2
   }

   instance.dead = false

   table.insert(ActiveBosses, instance)
end

function Boss:update(dt)
   self:updatePhase()
   self:move(dt)
   self:updateDetection(dt)
   self:updateShoot(dt)
   self:updateBullets(dt)
   self:checkPlayerBulletHits()
   self:checkPlayerContact()
   self:unTint(dt)
end

function Boss:updatePhase()
   if self.health <= 6 then
      self.phase = 2
      self.contactDamage = 2
      self.bulletDamage = 2
      self.shootCooldown = self.phaseTwoShootCooldown
      self.moveSpeed = 100
   else
      self.phase = 1
      self.contactDamage = 1
      self.bulletDamage = 1
      self.shootCooldown = self.normalShootCooldown
      self.moveSpeed = 70
   end
end

function Boss:move(dt)
   self.y = self.y + self.directionY * self.moveSpeed * dt

   if self.y >= self.yMax then
      self.y = self.yMax
      self.directionY = -1

   elseif self.y <= self.yMin then
      self.y = self.yMin
      self.directionY = 1
   end
end

function Boss:updateDetection(dt)
   local distanceX = math.abs(Player.x - self.x)

   if distanceX <= self.detectionRange then
      self.playerDetected = true
   else
      self.playerDetected = false
      self.canAttack = false
      self.attackDelayTimer = 0
   end

   if self.playerDetected and not self.canAttack then
      self.attackDelayTimer = self.attackDelayTimer + dt

      if self.attackDelayTimer >= self.attackDelay then
         self.canAttack = true
      end
   end
end

function Boss:updateShoot(dt)
   if not self.canAttack then
      return
   end

   self.shootTimer = self.shootTimer - dt

   if self.shootTimer <= 0 then
      self:shootTriple()
      self.shootTimer = self.shootCooldown
   end
end

function Boss:shootTriple()
   local bulletStartX = self.x - self.width * 0.35
   local bulletStartY = self.y - 8

   table.insert(self.bullets, BossBullet.new(bulletStartX, bulletStartY, -1, 0))
   table.insert(self.bullets, BossBullet.new(bulletStartX, bulletStartY, -1, -0.25))
   table.insert(self.bullets, BossBullet.new(bulletStartX, bulletStartY, -1, 0.25))
end

function Boss:updateBullets(dt)
   for i = #self.bullets, 1, -1 do
      local bullet = self.bullets[i]

      bullet:update(dt)

      local bx, by, bw, bh = bullet:getRect()

      local px = Player.x - Player.width / 2
      local py = Player.y - Player.height / 2
      local pw = Player.width
      local ph = Player.height

      if checkCollision(bx, by, bw, bh, px, py, pw, ph) then
         Player:takeDamage(self.bulletDamage)
         table.remove(self.bullets, i)

      elseif bullet.dead then
         table.remove(self.bullets, i)
      end
   end
end

function Boss:checkPlayerBulletHits()
   for i = #Player.bullets, 1, -1 do
      local bullet = Player.bullets[i]
      local bx, by, bw, bh = bullet:getRect()

      local bossX = self.x - self.width / 2
      local bossY = self.y - self.height / 2

      if checkCollision(bx, by, bw, bh, bossX, bossY, self.width, self.height) then
         self:tintRed()
         self.health = self.health - 1
         table.remove(Player.bullets, i)

         if self.health <= 0 then
            self.dead = true
            Boss.defeated = true
         end

         break
      end
   end
end

function Boss:checkPlayerContact()
   local bossX = self.x - self.width / 2
   local bossY = self.y - self.height / 2

   local px = Player.x - Player.width / 2
   local py = Player.y - Player.height / 2
   local pw = Player.width
   local ph = Player.height

   if checkCollision(bossX, bossY, self.width, self.height, px, py, pw, ph) then
      Player:takeDamage(self.contactDamage)
   end
end

function Boss:draw()
   love.graphics.setColor(self.color.red, self.color.green, self.color.blue)
   -- love.graphics.setColor(1, 1, 1, 1)

   love.graphics.draw(
        self.sprite,
        self.x,
        self.y,
        0,
        1,
        1,
        self.width / 2,
        self.height / 2
    )

   for _, bullet in ipairs(self.bullets) do
      bullet:draw()
   end

   local barWidth = 100
   local barHeight = 10
   local ratio = self.health / self.maxHealth

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.rectangle("line", self.x - barWidth / 2, self.y - self.height / 2 - 20, barWidth, barHeight)

   love.graphics.rectangle("fill", self.x - barWidth / 2, self.y - self.height / 2 - 20, barWidth * ratio, barHeight)

   love.graphics.setColor(1, 1, 1, 1)
end

function Boss.updateAll(dt)
   for i = #ActiveBosses, 1, -1 do
      local boss = ActiveBosses[i]

      boss:update(dt)

      if boss.dead then
         table.remove(ActiveBosses, i)
      end
   end
end

function Boss.drawAll()
   for _, boss in ipairs(ActiveBosses) do
      boss:draw()
   end
end

function Boss:tintRed()
   self.color.green = 0
   self.color.blue = 0
end

function Boss:unTint(dt)
   self.color.red = math.min(self.color.red + self.color.speed * dt, 2)
   self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
   self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

return Boss