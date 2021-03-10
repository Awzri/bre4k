function love.load()
	timeElapsedSinceStart = 0
	math.randomseed(os.time())
	Lane = require("lane")
	Note = require("note")
	print("// - // Break the rules // - //")
	love.window.setMode(711, 400, { fullscreen = false, vsync = 1 })
	keys = {
		"d", "f", "j", "k"
	}
	lanes = { 
		Lane:new(),
		Lane:new(),
		Lane:new(),
		Lane:new()
	}
	notes = {
		Note:new()
	}
	for k, _ in next, lanes do
		lanes[k].Input = k
		lanes[k].X = (love.graphics.getWidth() / 2) + 40 * (k - 3)
	end
end

-- timeElapsedSinceStart should be used for checking accuracy
function love.update(d)
	timeElapsedSinceStart = timeElapsedSinceStart + d
	for _, i in next, notes do
		if timeElapsedSinceStart > i.Time - 5 then
			Note.Show = true
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
		love.graphics.rectangle("line", i.X, i.Y - 25, 40, love.graphics.getHeight() + 50)

		love.graphics.circle(
			i.Pressed and "fill" or "line", 
		i.X + 20, love.graphics.getHeight() - 35, 18)
	end

	for _, i in next, notes do
		if i.Show then
			love.graphics.circle("fill", lanes[i.Lane].X + 20, timeElapsedSinceStart * 50, 18)
		end
	end
end
