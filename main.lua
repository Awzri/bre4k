-- Main requires Lane, Note, Song
-- Song requires Lane, Note, Tween 

function percentWidth(percent)
	-- DOESN'T TAKE A DECIMAL! TAKES AN INTEGER (0 - 100)
	return love.graphics.getWidth() * (percent / 100)
end

function percentHeight(percent)
	-- DOESN'T TAKE A DECIMAL! TAKES AN INTEGER (0 - 100)
	return love.graphics.getHeight() * (percent / 100)
end

function convertBeatTime(BPM, beatTime, measure, offset)
	-- Due to the way this is made, only supports 4/4 for the time being
	local BPS = BPM / 60
	local secondsToNextMeasure = 4 / BPS
	local Time = secondsToNextMeasure * measure
	Time = Time + (beatTime * secondsToNextMeasure)
	return Time + offset
end

function love.load()
	timeElapsedSinceStart = 0
	math.randomseed(os.time())
	print("// - // Break the rules // - //")
	love.window.setMode(711, 400, { fullscreen = true, vsync = 0 })
	Lane = require("lane")
	Note = require("note")
	Song = require("song")
	keys = {
		"d", "f", "j", "k"
	}
	lanes = Song.Lanes
	notes = Song.Notes
	currentLong = {}
	if Song.Info.UseBPM then
		for _, i in next, notes do
			if i.Time == 0 then
				i.Time = convertBeatTime(Song.Info.BPM, i.BeatTime, i.Measure, Song.Info.Offset)
			end
		end
	end
	if Song.Info.File and love.filesystem.getInfo(Song.Info.File).type == "file" then
		music = love.audio.newSource(Song.Info.File, "stream")
	end
	if music then music:play() end
end

-- timeElapsedSinceStart should be used for checking accuracy
function love.update(d)
	timeElapsedSinceStart = timeElapsedSinceStart + d
	for n, i in next, notes do
		if timeElapsedSinceStart >= i.Time - .015 and timeElapsedSinceStart <= i.Time + .015 and not i.Hittable then
			if i.Link then i.Link() end
			table.remove(notes, n)
		end
		if timeElapsedSinceStart > i.Time + .25 and i.Hittable then
			print("Miss!")
			if i.Link then i.Link() end
			table.remove(notes, n)
		end
		if timeElapsedSinceStart < i.Time - 10 then
			break
		end
	end
	if Song.OnUpdate then
		Song.OnUpdate(timeElapsedSinceStart)
	end
end

function love.keypressed(key, scankey)

	-- Change this to F11 when this goes standalone
	if key == "f11" then
		love.window.setFullscreen(not love.window.getFullscreen())

	-- Quitting the game by hitting escape.
	elseif key == "escape" then
		local QuitMessages = {
			"See ya!",
			"Now get back to work.",
			"Quitting...",
			"Come back soon!"
		}
		print(QuitMessages[math.random(#QuitMessages)])
		love.event.quit()

	end
	for n, i in next, keys do
		if key == i then
			for m, j in next, lanes do
				if lanes[n].Input == j.Input then
					j.Pressed = true
					for o, k in next, notes do
						if o > 4 then break end
						if k.Hittable
						and k.Lane == m
						and timeElapsedSinceStart >= k.Time - .25
						and timeElapsedSinceStart <= k.Time + .25 then
							print("Hit!")
							if k.Link then k.Link() end
							if not k.Long then
								table.remove(notes, o)
							else
								table.insert(currentLong, k)
								table.remove(notes, o)
							end
							break
						end
					end
				end
			end
		end
	end
end



-- Made for fancy animations:tm: and for long notes.
function love.keyreleased(key, scankey)
	for n, i in next, keys do
		if key == i then
			for m, j in next, lanes do
				if lanes[n].Input == j.Input then
					j.Pressed = false
					for o, k in next, currentLong do
						if timeElapsedSinceStart >= k.LongEnd - .3
						and k.Lane == m
						and timeElapsedSinceStart <= k.LongEnd + .3 then
							print("Hit!")
							table.remove(currentLong, o)
							break
						elseif k.Lane == m then
							print("Miss!")
							table.remove(currentLong, o)
							break
						end
					end
				end
			end
		end
	end
end

function love.draw()
	-- Draw all lanes to the screen.
	for n, i in next, lanes do
		love.graphics.setColor(i.Color)
		if i.Show then
			love.graphics.rectangle(
				"line",
				i.X,
				-percentHeight(100),
				percentWidth(6.2),
				love.graphics.getHeight() + percentHeight(200)
			)
		end

		love.graphics.circle(
			i.Pressed and "fill" or "line", 
			i.X + percentWidth(3.1),
			i.Y,
			percentWidth(2.8)
		)
	end

	for _, i in next, notes do
		if timeElapsedSinceStart > i.Time - 5 and i.Show then
			if not i.Hittable then
				love.graphics.setColor(i.ColorUnhittable)
			else
				love.graphics.setColor(i.Color)
			end
			love.graphics.circle(
				"fill",
				lanes[i.Lane].X + percentWidth(3.1),
				(timeElapsedSinceStart - i.Time) * percentHeight(i.Speed) + (lanes[i.Lane].Y),
				percentWidth(3)
			)
			if i.Long then
				local xmid = lanes[i.Lane].X + percentWidth(3.1)
				local ymid = (timeElapsedSinceStart - i.LongEnd) * percentHeight(i.Speed) + (lanes[i.Lane].Y)
				love.graphics.polygon(
					"fill",
					xmid,
					ymid,
					xmid + percentWidth(3),
					ymid + percentHeight(5),
					xmid + percentWidth(3),
					(timeElapsedSinceStart - i.Time) * percentHeight(i.Speed) + (lanes[i.Lane].Y),
					xmid - percentWidth(3),
					(timeElapsedSinceStart - i.Time) * percentHeight(i.Speed) + (lanes[i.Lane].Y),
					xmid - percentWidth(3),
					ymid + percentHeight(5)
				)
				--[[love.graphics.circle(
					"line",
					lanes[i.Lane].X + percentWidth(3.1),
					(timeElapsedSinceStart - i.LongEnd) * percentHeight(i.Speed) + (lanes[i.Lane].Y),
					percentWidth(3)
				)]]
			end
		end
	end
	for n, i in next, currentLong do
		if timeElapsedSinceStart - i.LongEnd <= 0 then
			local xmid = lanes[i.Lane].X + percentWidth(3.1)
			local ymid = (timeElapsedSinceStart - i.LongEnd) * percentHeight(i.Speed) + (lanes[i.Lane].Y)
			love.graphics.polygon(
				"fill",
				xmid,
				ymid,
				xmid + percentWidth(3),
				ymid + percentHeight(5),
				xmid + percentWidth(3),
				lanes[i.Lane].Y,
				xmid - percentWidth(3),
				lanes[i.Lane].Y,
				xmid - percentWidth(3),
				ymid + percentHeight(5)
			)
		elseif timeElapsedSinceStart - i.LongEnd > .3 then
			print("Miss!")
			table.remove(currentLong, n)
		end
	end
end
