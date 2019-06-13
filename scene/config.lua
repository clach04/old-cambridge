local ConfigScene = Scene:extend()
require 'load.save'

ConfigScene.title = "Settings"
ConfigScene.left_selector = 1
ConfigScene.right_selector = 1
ConfigScene.selector_at_left = true

available_window_sizes = {
	[1] = "320 x 240 (x0.5)",
	[2] = "640 x 480 (x1)",
	[3] = "1280 x 960 (x2)",
	[4] = "1920 x 1440 (x3)",
	["name"] = "Window Size"
}

available_fullscreen_modes = {
	[1] = "off",
	[2] = "on",
	["name"] = "Fullscreen Mode"
}

available_skins = {
	[1] = "???",
	["name"] = "Game Skin"
}

available_controls = {
	[1] = "Input Config",
	["name"] = "Controls"
}

available_settings = {
	[1] = available_window_sizes,
	[2] = available_fullscreen_modes,
	[3] = available_skins,
	[4] = available_controls
}

function ConfigScene:new()
	selector_at_left = true
	--TODO: place selectors in the right places
end

function ConfigScene:update()
end

function ConfigScene:render()
	--background
	love.graphics.draw(
		backgrounds[19],
		0, 0, 0,
		0.5, 0.5
	)

	--left selector
	if self.selector_at_left then
		love.graphics.setColor(1, 1, 1, 0.5)
	else
		love.graphics.setColor(1, 1, 1, 0.25)
	end
	love.graphics.rectangle("fill", 20, 78 + 20 * self.left_selector, 240, 22)
	--right selector
	if self.selector_at_left then
		love.graphics.setColor(1, 1, 1, 0.25)
	else
		love.graphics.setColor(1, 1, 1, 0.5)
	end
	love.graphics.rectangle("fill", 340, 78 + 20 * self.right_selector, 200, 22)

	--title
	love.graphics.setColor(1, 1, 1, 1)
	--love.graphics.draw(misc_graphics["title_settings"], 20, 40)

	--print words
	--settings
	love.graphics.setFont(font_3x5_2)
	for idx, sett in ipairs(available_settings) do
		love.graphics.printf(sett.name, 40, 80 + 20 * idx, 200, "left")
	end
	--setting options
	for idx, opt in ipairs(available_settings[self.left_selector]) do
		love.graphics.printf(opt, 360, 80 + 20 * idx, 160, "left")
	end
	
end

function ConfigScene:changeOption(rel)
	if self.selector_at_left then
		local len = table.getn(available_settings)
		self.left_selector = (self.left_selector + len + rel - 1) % len + 1
		--TODO: pick the selected option for the setting
		self.right_selector = 1 --temp
	else
		local len = table.getn(available_settings[self.left_selector])
		self.right_selector = (self.right_selector + len + rel - 1) % len + 1
	end
end

function ConfigScene:onKeyPress(e)
	if e.scancode == "escape" and e.isRepeat == false then
		scene = TitleScene()
	elseif e.scancode == "return" and e.isRepeat == false then
		--TODO: enter switches between left and right section
		if (self.left_selector == 4 and not self.selector_at_left) then
			scene = InputConfigScene()
		end
	elseif (e.scancode == config.input["up"] or e.scancode == "up") and e.isRepeat == false then
		self:changeOption(-1)
	elseif (e.scancode == config.input["down"] or e.scancode == "down") and e.isRepeat == false then
		self:changeOption(1)
	elseif (e.scancode == config.input["left"] or e.scancode == "left") or
		(e.scancode == config.input["right"] or e.scancode == "right") then
		self.selector_at_left = not self.selector_at_left
	end
end

return ConfigScene

