local DeadZone = {}
DeadZone.__index = DeadZone

local ActiveDeadZones = {}
local Player = require("objects.Player")

function DeadZone.removeAll()
   for i, v in ipairs(ActiveDeadZones) do
      v.physics.body:destroy()
   end

   ActiveDeadZones = {}
end

function DeadZone.new(x, y, width, height)
   local instance = setmetatable({}, DeadZone)

   instance.x = x + width / 2
   instance.y = y + height / 2
   instance.width = width
   instance.height = height

   instance.damage = 999

   instance.physics = {}
   instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
   instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
   instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
   instance.physics.fixture:setSensor(true)

   table.insert(ActiveDeadZones, instance)
end

function DeadZone:update(dt)

end

function DeadZone.updateAll(dt)
   for i, instance in ipairs(ActiveDeadZones) do
      instance:update(dt)
   end
end

function DeadZone.drawAll()
   for i, instance in ipairs(ActiveDeadZones) do
      instance:draw()
   end
end

function DeadZone.beginContact(a, b, collision)
   for i, instance in ipairs(ActiveDeadZones) do
      if a == instance.physics.fixture or b == instance.physics.fixture then
         if a == Player.physics.fixture or b == Player.physics.fixture then
            Player:takeDamage(instance.damage)
            return true
         end
      end
   end
end

return DeadZone