local Camera = {
   x = 0,
   y = 0,
   scale = 2,
   minY = 0
}

function Camera:apply()
   love.graphics.push()
   love.graphics.scale(self.scale, self.scale)
   love.graphics.translate(-self.x, -self.y)
end

function Camera:clear()
   love.graphics.pop()
end

function Camera:setPosition(x, y)
   local screenW = love.graphics.getWidth() / self.scale
   local screenH = love.graphics.getHeight() / self.scale

   self.x = x - screenW / 2

   if self.x < 0 then
      self.x = 0
   elseif self.x + screenW > MapWidth then
      self.x = MapWidth - screenW
   end

   self.y = y - screenH / 2

   if self.y < 0 then
      self.y = 0
   end

   if self.y + screenH > MapHeight then
      self.y = MapHeight - screenH
   end
end

return Camera