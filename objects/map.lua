
local Map = {}
local STI = require("lib.sti.init")
local Coin = require("objects.Coin")
local Spike = require("objects.spike")
local Camera = require("objects.Camera")
local Enemy = require("objects.Enemy")
local Player = require("objects.Player")
local Boss = require("objects.Boss")
local DeadZone = require("objects.DeadZone")

function Map:load(levelNumber)
   Coin.removeAll()
   Enemy.removeAll()
   Boss.removeAll()
   DeadZone.removeAll()
   Spike.removeAll()

   self.currentLevel = levelNumber or 1
   self.completed = false

   World = love.physics.newWorld(0, 2000)

   self:init()
end

function Map:init()
   self.level = STI("map/"..self.currentLevel..".lua", {"box2d"})

   self.level:box2d_init(World)
   self.solidLayer = self.level.layers.solid
   self.groundLayer = self.level.layers.ground
   self.entityLayer = self.level.layers.entity

   self.solidLayer.visible = false
   self.entityLayer.visible = false
   MapWidth = self.groundLayer.width * 16
   MapHeight = self.groundLayer.height * 16

   self:loadBackground()
   self:spawnEntities()
end

function Map:loadBackground()
   if self.currentLevel == 1 then
      self.backgroundLayers = {
         love.graphics.newImage("assets/backgrounds/forest/BACKGROUND.png"),
         love.graphics.newImage("assets/backgrounds/forest/WOODS - First.png"),
         love.graphics.newImage("assets/backgrounds/forest/WOODS - Second.png"),
         love.graphics.newImage("assets/backgrounds/forest/VINES - Second.png"),
         love.graphics.newImage("assets/backgrounds/forest/WOODS - Third.png"),
         love.graphics.newImage("assets/backgrounds/forest/WOODS - Fourth.png"),
         love.graphics.newImage("assets/backgrounds/forest/BUSH - BACKGROUND.png")
      }
   else
      self.backgroundLayers = {
         love.graphics.newImage("assets/backgrounds/cave/cave7.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave6.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave5.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave4.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave3.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave2.png"),
         love.graphics.newImage("assets/backgrounds/cave/cave1.png")
      }
   end
end

function Map:drawParallax()
   local camX = Camera.x
   local screenW = love.graphics.getWidth()
   local screenH = love.graphics.getHeight()

   local layers = self.backgroundLayers
   local total = #layers

   local function drawLayer(img, speed)
      local scale = math.max(
         screenW / img:getWidth(),
         screenH / img:getHeight()
      )

      local imgW = img:getWidth() * scale
      local x = -(camX * speed) % imgW

      love.graphics.draw(img, x, 0, 0, scale, scale)
      love.graphics.draw(img, x - imgW, 0, 0, scale, scale)
      love.graphics.draw(img, x + imgW, 0, 0, scale, scale)
   end

   for i = 1, total do
      local speed = i / total
      drawLayer(layers[i], speed)
   end
end

function Map:draw()
   self:drawParallax()
   self.level:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
end

function Map:next()
   self:clean()
   self.currentLevel = self.currentLevel + 1
   self.completed = false
   self:init()
   Player:resetPosition()
end

function Map:clean()
   self.level:box2d_removeLayer("solid")
   Coin.removeAll()
   Enemy.removeAll()
   Boss.removeAll()
   DeadZone.removeAll()

   Spike.removeAll()
end

function Map:update()
   if Player.x > MapWidth - 16 then
      self:next()
   end
end

function Map:spawnEntities()
	for i, v in ipairs(self.entityLayer.objects) do
		if v.type == "spikes" then
			Spike.new(v.x + v.width / 2, v.y + v.height / 2)
      
      elseif v.type == "deadzone" then
         DeadZone.new(v.x, v.y, v.width, v.height)

		elseif v.type == "enemy" then
			Enemy.new(v.x + v.width / 2, v.y + v.height / 2)
      
      elseif v.type == "enemy_collider" then
         local body = love.physics.newBody(World, v.x + v.width / 2, v.y + v.height / 2, "static")
         local shape = love.physics.newRectangleShape(v.width, v.height)
         local fixture = love.physics.newFixture(body, shape)

         fixture:setUserData("enemy_collider")

		elseif v.type == "boss" and self.currentLevel == 2 then
			Boss.new(v.x + v.width / 2, v.y + v.height / 2)

		elseif v.type == "coin" then
			Coin.new(v.x, v.y)
		end
	end
end

return Map
