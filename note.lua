Note = {
	Time = 0,
	Measure = 1,
	BeatTime = 1/1,
	Show = true,
	Lane = 1,
	Link = nil,
	ChangeBPM = nil,
	Hittable = true,
	Long = false,
	LongEnd = 0,
	LongMeasure = 1,
	LongBeatTime = 1/1,
	Mine = false,
	Speed = 150, --150
	Color = {1,1,1,1},
	ColorUnhittable = {0.5,0.5,0.5,1},
	MineColor = {1,0,0,1}
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
