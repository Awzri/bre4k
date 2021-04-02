-- Example Song
-- This is the bare minimum that a song should have
-- If something isn't straightforward, there will be a comment by it


-- Init table to require into main
Song = {}

-- Require notes and lanes to be used
local Note = require("note")
local Lane = require("lane")

-- Tweening Algorithms
local Tween = require("tween")

-- EDIT THIS!
Song.Info = {
	Name = "SongName",
	Artist = "ArtistName",
	File = nil,
	Notes = 8,
	UseBPM = false,
	BPM = 120,
	MinBPM = 120,
	MaxBPM = 120,
	Offset = 0,
	BGVideo = nil,
	BGImage = nil,
	Version = 1
}

-- Init table to hold lanes
Song.Lanes = {}

-- Put lanes into the table
for i = 1, 4 do
	table.insert(Song.Lanes, Lane:new())
	Song.Lanes[i].Input = i
	Song.Lanes[i].X = (love.graphics.getWidth() / 2) + percentWidth(6.2) * (i - 3)
	Song.Lanes[i].Y = percentHeight(90)
	Song.Lanes[i].StartX = Song.Lanes[i].X
	Song.Lanes[i].StartY = Song.Lanes[i].Y
end

-- Init table to hold notes
Song.Notes = {}

-- Put all notes inside the table
for i = 1, Song.Info.Notes do
	table.insert(Song.Notes, Note:new())
end

-- Updates each love.update.
-- Allows for tweening and stuff
-- really scuffed solution but it works for the time being

--[[
	Some tweening algorithms
	Cosine / Sine (InOut)
		amountUpDown * math.cos(speed * timeElapsed + offset) + start
	Linear (InOut)
		tweenTime = timeElapsed + startTime
		transformation * tweenTime + start
	Exponential (In)
		tweenTime = timeElapsed + startTime
		transformation * tweenTime ^ x + start
]]
Song.OnUpdate = function( timeElapsed )
	-- local laneOneStart = (love.graphics.getWidth() / 2) + percentWidth(6.2) * (1 - 3)
	-- for i = 1, 4 do
		-- Song.Lanes[i].Y = percentHeight(40) * math.cos(timeElapsed * timeElapsed + (i* .25)) + percentHeight(50)
	-- end
	if timeElapsed >= 5 and timeElapsed <= 5.5 then
		local tweenTime1 = timeElapsed - 5
		-- End point = percentWidth(5)
		-- y = mx + b -- Linear Tweening
		-- y = mx^2 + b -- Exponential Tweening
		-- what math came into use no way
		Song.Lanes[1].X = -percentWidth(10) * tweenTime1 ^ 2 + Song.Lanes[1].StartX
	end
	if timeElapsed >= 7 and timeElapsed <= 7.5 then
		local tweenTime1 = timeElapsed - 7
		Song.Lanes[4].X = percentWidth(10) * tweenTime1 ^ 2 + Song.Lanes[4].StartX
	end
end

--[[
oh god oh frick this is where things get messy
all of the note properties are changed here.
welcome to hell
i probably will make this compressed at some point but uh
im lazy rn so
soontm

Known Bug:
If using multiple lanes with one input, chord notes must be going from lowest to highest, else it will only hit the first note of the chord listed here.
]]
Song.Notes[1].Lane = 1
Song.Notes[1].Time = 5

Song.Notes[2].Lane = 2
Song.Notes[2].Time = 5

Song.Notes[3].Lane = 3
Song.Notes[3].Time = 5

Song.Notes[4].Lane = 4
Song.Notes[4].Time = 6

Song.Notes[5].Lane = 4
Song.Notes[5].Time = 6.1

Song.Notes[6].Lane = 1
Song.Notes[6].Time = 7

Song.Notes[7].Lane = 2
Song.Notes[7].Time = 7

Song.Notes[8].Lane = 3
Song.Notes[8].Time = 7

return Song
