Note = {
	Time = 0,
	BPMTime = 0,
	BPSTime = 0,
	Show = false,
	Lane = 1,
	Link = nil,
	Hittable = true,
	Long = false,
	Mine = false,
	Speed = 100 --150
	}

function Note:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Note:addLinkBPM(func, timeBPM)

end

function Note:addLinkBPS(func, timeBPS)

end

function Note:addLink(func, time)

end

return Note