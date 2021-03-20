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

function convertTimeBPM(BPM, timeBPM)

end

function love.load()
	timeElapsedSinceStart = 0
	math.randomseed(os.time())
	print("// - // Break the rules // - //")
	love.window.setMode(711, 400, { fullscreen = true, vsync = 1 })
	Lane = require("lane")
	Note = require("note")
	Song = require("song")
	keys = {
		"d", "f", "j", "k"
	}
	lanes = Song.Lanes
	notes = Song.Notes
end

-- timeElapsedSinceStart should be used for checking accuracy
function love.update(d)
	timeElapsedSinceStart = timeElapsedSinceStart + d
	for n, i in next, notes do
		if timeElapsedSinceStart >= i.Time - .015 and timeElapsedSinceStart <= i.Time + .015 and not i.Hittable then
			if i.Link then i.Link() end
			table.remove(notes, n)
		end
		if timeElapsedSinceStart > i.Time + .4 and i.Hittable then
			print("Miss!")
			if i.Link then i.Link() end
			table.remove(notes, n)
		end
		if timeElapsedSinceStart < i.Time - 10 then
			break
		end
	end
	Song.OnUpdate(timeElapsedSinceStart)
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
		if scankey == i then
			for m, j in next, lanes do
				if j.Input == n or lanes[n].Input == j.Input then
					j.Pressed = true
					local nextNote = notes[1] or nil
					if nextNote and nextNote.Hittable and nextNote.Lane == m and timeElapsedSinceStart >= nextNote.Time - .4 and timeElapsedSinceStart <= nextNote.Time + .4 then
						print("Hit!")
						if nextNote.Link then nextNote.Link() end
						table.remove(notes, 1)
					end
				end
			end
		end
	end
	print("-------")
end


-- Made for fancy animations:tm: and for long notes.
function love.keyreleased(key, scankey)
	for n, i in next, keys do
		if scankey == i then
			for _, j in next, lanes do
				if j.Input == n or lanes[n].Input == j.Input then
					j.Pressed = false
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
		if timeElapsedSinceStart > i.Time - 10 and i.Show then
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
		end
	end
end