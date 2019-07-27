local ConfigScene = Scene:extend()
require 'load.save'

local function createOption(name, size)
	option = {
		["name"] = name,
		["size"] = size,
		["selected"] = 1
	}
	return option
end

ConfigScene.title = "Settings"
ConfigScene.left_selector = 1
ConfigScene.selector_at_left = true

--initialize configuration menu
local available_settings = {}
available_settings["size"] = 4
available_settings[1] = createOption("Window Size",4)
available_settings[1][1] = "320 x 240 (x0.5)"
available_settings[1][2] = "640 x 480 (x1)"
available_settings[1][3] = "1280 x 960 (x2)"
available_settings[1][4] = "1920 x 1440 (x3)"
if config.window_width == nil then
	available_settings[1].selected = 2
else
	available_settings[1].selected = config.window_width/320
	if available_settings[1].selected > 3 then
		available_settings[1].selected = available_settings[1].selected/2
	end
end

available_settings[2] = createOption("Fullscreen Mode",2)
available_settings[2][1] = "off"
available_settings[2][2] = "on"
if config.fullscreen == nil or config.fullscreen == false then
	config.fullscreen = false
	available_settings[2].selected = 1
else
	available_settings[2].selected = 2
end

available_settings[3] = createOption("Game Skin",1)
available_settings[3][1] = "???"

available_settings[4] = createOption("Input Config",1)
available_settings[4][1] = "Controls"

function ConfigScene:new()
	selector_at_left = true
	self.left_selector = 1
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
	love.graphics.rectangle("fill", 340, 78 + 20 * available_settings[self.left_selector].selected, 200, 22)

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
	else
		local len = table.getn(available_settings[self.left_selector])
		available_settings[self.left_selector].selected = (available_settings[self.left_selector].selected + len + rel - 1) % len + 1
		if self.left_selector == 1 then
			self:updateWindowSize(available_settings[1].selected)
		end
	end
end

function ConfigScene:updateWindowSize(option)
	if option == 1 then
		config.window_width = 320
		config.window_height = 240
	else
		config.window_width = 640*(option-1)
		config.window_height = 480*(option-1)
	end
end

function ConfigScene:onKeyPress(e)
	if e.scancode == "escape" and e.isRepeat == false then
		scene = TitleScene()
		love.window.setMode(config.window_width, config.window_height, {fullscreen=config.fullscreen})
		saveConfig()
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

