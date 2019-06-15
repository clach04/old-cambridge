local ModeSelectScene = Scene:extend()

ModeSelectScene.title = "Game Start"

current_mode = 1
current_ruleset = 1

MAX_MODES = 19

game_modes = {
	require 'tetris.modes.marathon_2020',
	require 'tetris.modes.survival_2020',
	require 'tetris.modes.strategy',
	require 'tetris.modes.interval_training',
	require 'tetris.modes.pacer_test',
	require 'tetris.modes.marathon_wcb',
	require 'tetris.modes.demon_mode',
	require 'tetris.modes.phantom_mania',
	require 'tetris.modes.phantom_mania2',
	require 'tetris.modes.phantom_mania_n',
	require 'tetris.modes.race_40',
	require 'tetris.modes.marathon_a1',
	require 'tetris.modes.marathon_a2',
	require 'tetris.modes.marathon_a3',
	require 'tetris.modes.marathon_ax',
	require 'tetris.modes.marathon_ax2',
	require 'tetris.modes.marathon_ax3',
	require 'tetris.modes.marathon_c89',
	require 'tetris.modes.survival_a1',
	require 'tetris.modes.survival_a2',
	require 'tetris.modes.survival_a3',
	require 'tetris.modes.survival_ax',
	require 'tetris.modes.survival_ax2',
	require 'tetris.modes.credits_a3',
}

rulesets = {
	require 'tetris.rulesets.cambridge',
	require 'tetris.rulesets.standard',
	require 'tetris.rulesets.standard_ti',
	require 'tetris.rulesets.arika',
	require 'tetris.rulesets.arika_ti',
	require 'tetris.rulesets.arika_ace',
	--require 'tetris.rulesets.bonkers',
	--require 'tetris.rulesets.shirase',
	--require 'tetris.rulesets.super302',
}

function ModeSelectScene:new()
	self.menu_state = {
		mode = current_mode,
		ruleset = current_ruleset,
		select = "mode",
	}
end

function ModeSelectScene:update()
end

function getCursorHeight(x)
	return 78 + 20 * x
end


function ModeSelectScene:drawList(name, items, cursor, x)
	local start, finish
	if table.getn(items) < MAX_MODES then
		start = 1
		finish = table.getn(items)
	else
		if cursor < 10 then
			start = 1
			finish = 19
		elseif cursor > table.getn(items) - 9 then
			start = table.getn(items) - 18
			finish = table.getn(items)
		else
			start = cursor - 9
			finish = cursor + 9
		end
	end

	if self.menu_state.select == name then
		love.graphics.setColor(1, 1, 1, 0.5)
	else
		love.graphics.setColor(1, 1, 1, 0.25)
	end
	love.graphics.rectangle("fill", x, getCursorHeight(cursor - start), 240, 22)

	love.graphics.setColor(1, 1, 1, 1)

	for idx = start, finish do
		local item = items[idx]
		love.graphics.printf(item.name, x + 20, 80 + 20 * (idx - start), 200, "left")
	end
end


function ModeSelectScene:render()
	love.graphics.setFont(font_3x5_2)

	love.graphics.draw(
		backgrounds[0],
		0, 0, 0,
		0.5, 0.5
	)

	love.graphics.draw(misc_graphics["select_mode"], 20, 30)

	self:drawList("mode", game_modes, self.menu_state.mode, 20)
	self:drawList("ruleset", rulesets, self.menu_state.ruleset, 320)
end

function ModeSelectScene:onKeyPress(e)
	if e.scancode == "escape" and e.isRepeat == false then
		scene = TitleScene()
	elseif e.scancode == "return" and e.isRepeat == false then
		current_mode = self.menu_state.mode
		current_ruleset = self.menu_state.ruleset
		config.current_mode = current_mode
		config.current_ruleset = current_ruleset
		saveConfig()
		scene = GameScene(game_modes[self.menu_state.mode], rulesets[self.menu_state.ruleset])
	elseif (e.scancode == config.input["up"] or e.scancode == "up") and e.isRepeat == false then
		self:changeOption(-1)
	elseif (e.scancode == config.input["down"] or e.scancode == "down") and e.isRepeat == false then
		self:changeOption(1)
	elseif (e.scancode == config.input["left"] or e.scancode == "left") or
		(e.scancode == config.input["right"] or e.scancode == "right") then
		self:switchSelect()
	end
end

function ModeSelectScene:changeOption(rel)
	if self.menu_state.select == "mode" then
		self:changeMode(rel)
	elseif self.menu_state.select == "ruleset" then
		self:changeRuleset(rel)
	end
end

function ModeSelectScene:switchSelect(rel)
	if self.menu_state.select == "mode" then
		self.menu_state.select = "ruleset"
	elseif self.menu_state.select == "ruleset" then
		self.menu_state.select = "mode"
	end
end

function ModeSelectScene:changeMode(rel)
	local len = table.getn(game_modes)
	self.menu_state.mode = (self.menu_state.mode + len + rel - 1) % len + 1
end

function ModeSelectScene:changeRuleset(rel)
	local len = table.getn(rulesets)
	self.menu_state.ruleset = (self.menu_state.ruleset + len + rel - 1) % len + 1
end

return ModeSelectScene
