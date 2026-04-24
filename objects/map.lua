
local Map = {}
local STI = require("lib.sti.init")
local Coin = require("objects.coin")
local Spike = require("objects.spike")

local Enemy = require("objects.enemy")
local Player = require("objects.player")
local Boss = require("objects.boss")

function Map:load(levelNumber)
   Coin.removeAll()
   Enemy.removeAll()
   Boss.removeAll()
   Spike.removeAll()

   self.currentLevel = levelNumber or 1
   self.completed = false

   World = love.physics.newWorld(0, 2000)
   World:setCallbacks(beginContact, endContact)

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

   self:spawnEntities()
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

		elseif v.type == "enemy" then
			Enemy.new(v.x + v.width / 2, v.y + v.height / 2)

		elseif v.type == "boss" and self.currentLevel == 2 then
			Boss.new(v.x + v.width / 2, v.y + v.height / 2)

		elseif v.type == "coin" then
			Coin.new(v.x, v.y)
		end
	end
end

return Map
