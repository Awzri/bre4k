Note = { Time = 5, Show = false, Lane = 1 }

function Note:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

return Note