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

function convertTimeBPS(BPS, timeBPS)

end

function love.load()
	timeElapsedSinceStart = 0
	math.randomseed(os.time())
	Lane = require("lane")
	Note = require("note")
	Song = require("song")
	print("// - // Break the rules // - //")
	love.window.setMode(711, 400, { fullscreen = false, vsync = 1 })
	keys = {
		"d", "f", "j", "k"
	}
	lanes = Song.Lanes
	notes = Song.Notes
	for k, _ in next, lanes do
		lanes[k].Input = k
	end
end

-- timeElapsedSinceStart should be used for checking accuracy
function love.update(d)
	timeElapsedSinceStart = timeElapsedSinceStart + d
	for n, i in next, notes do
		if timeElapsedSinceStart > i.Time - 10 then
			Note.Show = true
		end
		if timeElapsedSinceStart > i.Time + .4 then
			print("Miss!")
			table.remove(notes, n)
		end
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
		if scankey == i then
			lanes[n].Pressed = true
			local notesChecked = 0
			for n, i in next, notes do
				notesChecked = notesChecked + 1
				if timeElapsedSinceStart >= i.Time - .4 and  timeElapsedSinceStart <= i.Time + .4 then
					print("Hit!")
					print(timeElapsedSinceStart, i.Time - .4, i.Time + .4)
					table.remove(notes, n)
				end
				if notesChecked >= 10 then
					break
				end
			end
		end
	end
end


-- Made for fancy animations:tm: and for long notes.
function love.keyreleased(key, scankey)
	for n, i in next, keys do
		if scankey == i then
			lanes[n].Pressed = false
		end
	end
end

function love.draw()
	-- Draw all lanes to the screen.
	for n, i in next, lanes do
		love.graphics.rectangle(
			"line",
			i.X,
			i.Y - 25,
			percentWidth(6.2),
			love.graphics.getHeight() + 50
		)

		love.graphics.circle(
			i.Pressed and "fill" or "line", 
			i.X + percentWidth(3.1),
			love.graphics.getHeight() - percentHeight(10),
			percentWidth(2.8)
		)
	end

	for _, i in next, notes do
		if i.Show then
			love.graphics.circle(
				"fill",
				lanes[i.Lane].X + percentWidth(3.1),
				(timeElapsedSinceStart - i.Time) * percentHeight(i.Speed) + (love.graphics.getHeight() - percentHeight(10)),
				percentWidth(3)
			)
		end
	end
end
