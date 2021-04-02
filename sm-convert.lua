-- Standalone converter for Stepmania songs
-- CONVERTS .sm FILES, NOT .ssc FILES
-- Used for bre4k
-- https://github.com/NullCat/bre4k

local file = {...}

if #file > 1 then
	print("Only one file can be converted at a time. Sorry for any inconvenience that may cause.")
	return
else
	if file[1] then
		smFile = io.open(file[1])
		if not smFile then
			print("Not a file.\nUsage: lua sm-convert.lua <file>")
			return
		end
	else
		print("Usage: lua sm-convert.lua <file>")
		return
	end
end

local smFileRead = smFile:read("*all")
local convertedFile = io.open("convert.lua", "w+")

Original = {
	Name = string.match(smFileRead, "#TITLE:(.-);"),
	Artist = string.match(smFileRead, "#ARTIST:(.-);"),
	File = string.match(smFileRead, "#MUSIC:(.-);"),
	BPM = string.match(smFileRead, "#BPMS:0=(.-)(%p-)"),
	Offset = tonumber(string.match(smFileRead, "#OFFSET:(.-);")) + 1,
	BPMChanges = {},
	MinBPM = 0,
	MaxBPM = 0
}

do 
	local currMin = 0 
	local currMax = 0
	for i in string.gmatch(string.match(smFileRead, "BPMS:(.-);"), "(.-),") do
		local beat = tonumber(string.match(smFileRead, ":(.-)="))
		if beat ~= 0 then
			local changedBPM = tonumber(string.match(smFileRead, "=(.-)"))
			print(beat, changedBPM)
			if currMin > changedBPM then
				currMin = changedBPM
			elseif currMax < changedBPM then
				currMax = changedBPM
			end
			table.insert(BPMChanges, i, beat)
		end
	end
end

local noteStart
smFile:seek("set")
-- ignore the fact i iterated f:read("l") here and then used f:lines() later
for i = 1, 101 do
	local nextLine = smFile:read("l")
	if nextLine and string.match(nextLine, "#NOTES:") then
		print("Found notes at line "..i + 6)
		noteStart = i + 6
		break
	elseif not nextLine then
		error("Next file line did not load.")
	elseif i > 100 then
		error("Tries to find start of notes exceeded 100 lines.")
	end
end

smFile:seek("set")
-- Format for NoteList is similar to the Note object in bre4k
local NoteList = {}
local incompleteLongs = {}
-- what do you mean f:lines() doesn't produce 2 variables?
do
	local n = 0
	local positionInMeasure = 0
	local firstNoteCreated = 0
	local measureNumber = 1
	for i in smFile:lines() do
		i = i:match("(%S+)")
		n = n + 1
		if n >= noteStart then
			if i:len() == 4 then
				positionInMeasure = positionInMeasure + 1
				for j = 1, 4 do
					local noteChecked = i:sub(j,j)
					if noteChecked == "3" then
						for _, k in next, incompleteLongs do
							if k.Lane == j then
								k.LongMeasure = measureNumber
								k.LongBeatTime = positionInMeasure
								table.insert(NoteList, k)
							end
						end
						table.insert(NoteList, k)
					elseif noteChecked ~= "0" then
						local newNote = {}
						newNote.Measure = measureNumber
						newNote.BeatTime = positionInMeasure
						newNote.Lane = j
						if noteChecked == "1" then
							table.insert(NoteList, newNote)
						elseif noteChecked == "2" or noteChecked == "4" then
							table.insert(incompleteLongs, newNote)
						elseif noteChecked == "M" then
							newNote.Mine = true
							table.insert(NoteList, newNote)
						end
					end
					--[[if noteChecked == "1" then
						local newNote = {}
						newNote.Measure = measureNumber
						newNote.BeatTime = positionInMeasure
						newNote.Lane = j
						table.insert(NoteList, newNote)
					elseif noteChecked == "2" or noteChecked == "4" then
						local newNote = {}
						newNote.Measure = measureNumber
						newNote.BeatTime = positionInMeasure
						newNote.Lane = j
						table.insert(incompleteLongs, newNote)
					elseif noteChecked == "M" then
						local newNote = {}
						newNote.Measure = measureNumber
						newNote.Mine = true
						newNote.BeatTime = positionInMeasure
						newNote.Lane = j
						table.insert(NoteList, newNote)
					end]]
				end
			elseif i:len() == 1 then
				print("Hit comma...")
				for j = firstNoteCreated, #NoteList do
					if NoteList[j] then
						print(NoteList[j].BeatTime, positionInMeasure, NoteList[j].Measure)
						NoteList[j].BeatTime = NoteList[j].BeatTime / positionInMeasure
					end
				end
				measureNumber = measureNumber + 1
				firstNoteCreated = #NoteList + 1
				positionInMeasure = 0
				print(i)
				print("Comma!")
			end
		else
			firstNoteCreated = n - noteStart
		end
	end
end

local noteCount = #NoteList
local final = ""
for n, i in next, NoteList do
	local currentNote = ""
	currentNote = currentNote.."Song.Notes["..n.."].Lane = "..i.Lane.."\n"
	currentNote = currentNote.."Song.Notes["..n.."].BeatTime = "..i.BeatTime.."\n"
	currentNote = currentNote.."Song.Notes["..n.."].Measure = "..i.Measure.."\n"
	if i.Mine then
		currentNote = currentNote.."Song.Notes["..n.."].Mine = true\n"
	elseif i.Long then
		currentNote = currentNote.."Song.Notes["..n.."].Long = true\n"
		currentNote = currentNote.."Song.Notes["..n.."].LongMeasure = "..i.LongMeasure.."\n"
		currentNote = currentNote.."SOng.Notes["..n.."].LongBeatTime = "..i.LongBeatTime.."\n"
	elseif BPMChanges[i.BeatTime * 4 + i.Measure] ~= 0 then
		currentNote = currentNote.."Song.Notes["..n.."].ChangeBPM = "..BPMChanges[i.BeatTime * 4 + i.Measure].."\n"
	end
	final = final.."\n"..currentNote
end
convertedFile:write([[
Song={}
local Note = require('note')
local Lane = require('lane')
Song.Info = {
	Name = "]]..Original.Name..[[",
	Artist = "]]..Original.Artist..[[",
	File = "]]..Original.File..[[",
	Notes = ]]..noteCount..[[,
	UseBPM = true,
	BPM = ]]..Original.BPM..[[,
	MinBPM = ]]..Original.MinBPM..[[,
	MaxBPM = ]]..Original.MaxBPM..[[,
	Offset = ]]..Original.Offset..[[,
	BGVideo = nil,
	BGImage = nil,
	Version = 1
}
Song.Lanes = {}
for i=1,4 do
	table.insert(Song.Lanes,Lane:new())
	Song.Lanes[i].Input = i
	Song.Lanes[i].X = percentWidth(50) + percentWidth(6.2) * (i-3)
	Song.Lanes[i].Y = percentHeight(90)
	Song.Lanes[i].StartX = Song.Lanes[i].X
	Song.Lanes[i].StartY = Song.Lanes[i].Y
end
Song.Notes={}
for i=1,Song.Info.Notes do
	table.insert(Song.Notes, Note:new())
end

]]..final.."return Song")
