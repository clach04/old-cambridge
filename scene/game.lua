local GameScene = Scene:extend()
require 'load.save'

function GameScene:new(game_mode, ruleset)
	self.game = game_mode()
	self.ruleset = ruleset()
	self.game:initialize(self.ruleset)
end

function GameScene:update()
	if love.window.hasFocus() then
		self.game:update({
			left = love.keyboard.isScancodeDown(config.input.left),
			right = love.keyboard.isScancodeDown(config.input.right),
			up = love.keyboard.isScancodeDown(config.input.up),
			down = love.keyboard.isScancodeDown(config.input.down),
			rotate_left = love.keyboard.isScancodeDown(config.input.rotate_left),
			rotate_left2 = love.keyboard.isScancodeDown(config.input.rotate_left2),
			rotate_right = love.keyboard.isScancodeDown(config.input.rotate_right),
			rotate_right2 = love.keyboard.isScancodeDown(config.input.rotate_right2),
			rotate_180 = love.keyboard.isScancodeDown(config.input.rotate_180),
			hold = love.keyboard.isScancodeDown(config.input.hold),
		}, self.ruleset)
	end

	self.game.grid:update()
end

function GameScene:render()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		backgrounds[self.game:getBackground()],
		0, 0, 0,
		0.5, 0.5
	)

	-- game frame
	love.graphics.draw(misc_graphics["frame"], 48, 64)
	love.graphics.setColor(0, 0, 0, 200)
	love.graphics.rectangle("fill", 64, 80, 160, 320)

	self.game:drawGrid()
	self.game:drawPiece()
	self.game:drawNextQueue(self.ruleset)
	self.game:drawScoringInfo()

	-- ready/go graphics
	if self.game.ready_frames <= 100 and self.game.ready_frames > 52 then
		love.graphics.draw(misc_graphics["ready"], 144 - 50, 240 - 14)
		playSE("ready")
	elseif self.game.ready_frames <= 50 and self.game.ready_frames > 2 then
		love.graphics.draw(misc_graphics["go"], 144 - 27, 240 - 14)
		playSE("go")
	end

	self.game:drawCustom()

end

function GameScene:onKeyPress(e)
	if (self.game.completed) and
		e.scancode == "return" and e.isRepeat == false then
		highscore_entry = self.game:getHighscoreData()
		highscore_hash = self.game.hash .. "-" .. self.ruleset.hash
		submitHighscore(highscore_hash, highscore_entry)
		scene = ModeSelectScene()
	end
end

function submitHighscore(hash, data)
	if not highscores[hash] then highscores[hash] = {} end
	table.insert(highscores[hash], data)
	saveHighscores()
end

return GameScene
