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
local convertedFile = io.open("song.lua", "w+")

Original = {
	Name = string.match(smFileRead, "#TITLE:(.-);"),
	Artist = string.match(smFileRead, "#ARTIST:(.-);"),
	File = string.match(smFileRead, "#MUSIC:(.-);"),
	BPM = string.match(smFileRead, "#BPMS:.-=(.-)%p+"),
	Offset = tonumber(string.match(smFileRead, "#OFFSET:(.-);")), 
	BPMChanges = {}
}

local noteStart
smFile:seek("set")
-- ignore the fact i iterated f:read("l") here and then used f:lines() later
for i = 1, 101 do
	local nextLine = smFile:read("*l")
	if nextLine and string.match(nextLine, "#NOTES:") then
		--print("Found notes at line "..i + 6)
		noteStart = i + 6
		break
	elseif not nextLine then
		error("Next file line did not load.")
	elseif i > 100 then
		error("Tries to find start of notes exceeded 100 lines.")
	end
end

local currMin = tonumber(Original.BPM)
local currMax = tonumber(Original.BPM)
do 
	local BPMList = string.match(smFileRead, "BPMS:(.-);")
	--print(BPMList)
	for i in string.gmatch(BPMList, "(.-),") do
		local beat = tonumber(string.match(i, "(%d-%p-%d-)="))
		--print("BPM CHANGE -----------")
		--print(beat)
		if beat ~= 0 then
			beat = beat + 1
			local changedBPM = tonumber(string.match(i, "=(.+)"))
			--print("BPM "..i, changedBPM)
			if currMin > changedBPM then
				currMin = changedBPM
			elseif currMax < changedBPM then
				currMax = changedBPM
			end
			--[[for j = #Original.BPMChanges, beat do
				table.insert(Original.BPMChanges, 0)
			end]]
			--print(beat, changedBPM)
			Original.BPMChanges[tostring(beat)] = changedBPM
			--table.insert(Original.BPMChanges, beat, changedBPM)
		end
		--print("End change")
	end
end

smFile:seek("set")
-- Format for NoteList is similar to the Note object in bre4k
local NoteList = {}
local incompleteLongs = {}
-- what do you mean f:lines() doesn't produce 2 variables?
do
	local n = 0
	local positionInMeasure = -1
	local firstNoteCreated = 0
	local measureNumber = 1
	for i in smFile:lines() do
		i = i:match("(%S+)")
		n = n + 1
		if n >= noteStart then
			if not i then error("Empty line found.\nMake sure that it is not multi-difficulty, and that there is no space between the start of the first measure and the groove radar data.(Including comments)\nAborting...") end
			positionInMeasure = positionInMeasure + 1
			if i:len() == 4 then
				for j = 1, 4 do
					local noteChecked = i:sub(j,j)
					if noteChecked == "3" then
						for m, k in next, incompleteLongs do
							--print("LongCheck "..m, k.Lane, j)
							--print("Time "..k.Measure, k.BeatTime)
							--print("Time "..measureNumber, positionInMeasure)
							if k.Lane == j then
								--print("New long!")
								k.Long = true
								k.LongMeasure = measureNumber
								k.LongBeatTime = positionInMeasure
								table.insert(NoteList, k)
								table.remove(incompleteLongs, m)
								break
							end
						end
						table.insert(NoteList, k)
					elseif noteChecked ~= "0" and noteChecked ~= "3" then
						local newNote = {}
						newNote.Measure = measureNumber
						newNote.BeatTime = positionInMeasure
						newNote.Lane = j
						if noteChecked == "1" then
							table.insert(NoteList, newNote)
						elseif noteChecked == "2" or noteChecked == "4" then
							--print("StartLong "..measureNumber, positionInMeasure)
							table.insert(incompleteLongs, newNote)
						elseif noteChecked == "M" then
							newNote.Mine = true
							table.insert(NoteList, newNote)
						else
							print("Unknown note: "..noteChecked)
						end
					end
				end
			elseif i:len() == 1 or string.match(i,"(%p)") then
				--print("Hit comma...")
				for _, j in next, incompleteLongs do
					if j.Measure == measureNumber then
						j.BeatTime = j.BeatTime / positionInMeasure
						j.BeatSet = true
						--print(measureNumber, j.BeatTime)
					end
				end
				for j = firstNoteCreated, #NoteList do
					if NoteList[j] then
						NoteList[j].Show = true
						NoteList[j].Hittable = true
						if not NoteList[j].BeatSet then
							NoteList[j].BeatTime = NoteList[j].BeatTime / positionInMeasure
						end
						if NoteList[j].Long then
							--print(NoteList[j].LongBeatTime, positionInMeasure)
							NoteList[j].LongBeatTime = NoteList[j].LongBeatTime / positionInMeasure
							--print(NoteList[j].LongBeatTime)
						end
						local NoteBeat = NoteList[j].Measure * 4 + NoteList[j].BeatTime / .25
						-- NoteList[j].BeatTime % .25 == 0 and
						if Original.BPMChanges[tostring(NoteBeat)] and Original.BPMChanges[tostring(NoteBeat)] ~= 0 then
							print("Changing note "..j.." on beat "..(NoteBeat - 1).." to BPM "..Original.BPMChanges[tostring(NoteBeat)])
							NoteList[j].ChangeBPM = Original.BPMChanges[tostring(NoteBeat)]
							Original.BPMChanges[tostring(NoteBeat)] = 0
						end
					end
				end
				--for n, j in next, Original.BPMChanges do
				for n, j in pairs(Original.BPMChanges) do
					local NoteBeat = tonumber(n)
					--print(NoteBeat, (NoteBeat / 4), measureNumber + 1)
					--local NoteBeat = (4 * measureNumber) + (n / .25)
					if j ~= 0 and (NoteBeat / 4) <= measureNumber + 1 then
						local newNote = {}
						newNote.Hittable = false
						newNote.Show = false
						newNote.Measure = measureNumber
						newNote.Lane = 1
						newNote.BeatTime = (NoteBeat - (measureNumber - 1)) / 4
						print("Adding note "..#NoteList.." on beat "..(NoteBeat - 1).." to compensate BPM changing to "..j)
						newNote.ChangeBPM = j
						table.insert(NoteList, newNote)
						Original.BPMChanges[tostring(n)] = 0
					end
				end
				measureNumber = measureNumber + 1
				firstNoteCreated = #NoteList + 1
				positionInMeasure = -1
				--print(i)
				--print("Comma!")
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
	currentNote = currentNote.."Song.Notes["..n.."].Measure = "..(i.Measure - 1).."\n"
	if i.Mine then
		currentNote = currentNote.."Song.Notes["..n.."].Mine = true\n"
	end
	if i.Long then
		currentNote = currentNote.."Song.Notes["..n.."].Long = true\n"
		currentNote = currentNote.."Song.Notes["..n.."].LongMeasure = "..(i.LongMeasure - 1).."\n"
		currentNote = currentNote.."Song.Notes["..n.."].LongBeatTime = "..i.LongBeatTime.."\n"
	end
	if not i.Show then
		currentNote = currentNote.."Song.Notes["..n.."].Show = false\n"
	end
	if not i.Hittable then
		currentNote = currentNote.."Song.Notes["..n.."].Hittable = false\n"
	end
	if i.ChangeBPM then
		currentNote = currentNote.."Song.Notes["..n.."].ChangeBPM = "..i.ChangeBPM.."\n"
	end
	--if i.BeatTime % .25 == 0 and Original.BPMChanges[i.Measure * 4 + i.BeatTime / .25] and Original.BPMChanges[i.Measure * 4 + i.BeatTime / .25] ~= 0 then
		--currentNote = currentNote.."Song.Notes["..n.."].ChangeBPM = "..Original.BPMChanges[((i.Measure - 1) * 4 + i.BeatTime / .25) + 1].."\n"
	--end
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
	MinBPM = ]]..currMin..[[,
	MaxBPM = ]]..currMax..[[,
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
