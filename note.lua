Note = {
	Time = 0,
	BPMTime = 0,
	BeatTime = 0/1,
	Show = true,
	Lane = 1,
	Link = nil,
	Hittable = true,
	Long = false,
	Mine = false,
	Speed = 100, --150
	Color = {1,1,1,1},
	ColorUnhittable = {0.5,0.5,0.5,1}
	}

function Note:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Note:addLinkBPM(func, timeBPM)

end

function Note:addLink(func, time)
	Link = func(time)
end

return Note