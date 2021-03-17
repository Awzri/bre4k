-- Example Song
-- This is the bare minimum that a song should have
-- If something isn't straightforward, there will be a comment by it


-- Init table to require into main
Song = {}

-- Require notes and lanes to be used
local Note = require("note")
local Lane = require("lane")

-- EDIT THIS!
Song.Info = {
	Name = "SongName",
	Artist = "ArtistName",
	Notes = 8,
	Long = 0,
	BPM = 120
}

-- Init table to hold lanes
Song.Lanes = {}

-- Put lanes into the table
for i = 1, 4 do
	table.insert(Song.Lanes, Lane:new())
	Song.Lanes[i].Input = i
	Song.Lanes[i].X = (love.graphics.getWidth() / 2) + percentWidth(6.2) * (i - 3)
	print(Song.Lanes[i].X)
end

-- Init table to hold notes
Song.Notes = {}

-- Put all notes inside the table
for i = 1, Song.Info.Notes do
	table.insert(Song.Notes, Note:new())
end

-- Updates each love.update.
-- Allows for tweening and stuff
-- really scuffed solution but it works
Song.OnUpdate = function( timeElapsed )
	local laneOneStart = (love.graphics.getWidth() / 2) + percentWidth(6.2) * (1 - 3)
	if timeElapsed >= 5 and timeElapsed <= 6 then
		-- End point = percentWidth(5)
	end
end

--[[
oh god oh frick this is where things get messy
all of the note properties are changed here.
welcome to hell
i probably will make this compressed at some point but uh
im lazy rn so
soontm
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

Song.Notes[6].Lane = 3
Song.Notes[6].Time = 7

Song.Notes[7].Lane = 2
Song.Notes[7].Time = 7

Song.Notes[8].Lane = 1
Song.Notes[8].Time = 7

return Song