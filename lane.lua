Lane = {
	X = 0, -- Both the X and Y are in pixels
	Y = 0,
	Width = 6.2, -- Percent of screen space
	Input = 1,
	Pressed = false,
	Locked = true,
	Notes = {},
	StartX = 0,
	StartY = 0,
	Show = false,
	Color = {1,1,1,1} 
	}

function Lane:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Lane:move(x)
	self.Locked = false
	self.X = x
end

return Lane