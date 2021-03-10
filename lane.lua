Lane = { X = 0, Y = 0 , Input = 1, Pressed = false }

function Lane:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Lane:move(x, time, tween, style)

end

return Lane