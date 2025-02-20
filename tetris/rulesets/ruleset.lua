local Object = require 'libs.classic'
local Piece = require 'tetris.components.piece'

local Ruleset = Object:extend()

Ruleset.name = ""
Ruleset.hash = ""

Ruleset.enable_IRS_wallkicks = false

-- Component functions.

function Ruleset:rotatePiece(inputs, piece, grid, prev_inputs, initial)
	local new_inputs = {}

	for input, value in pairs(inputs) do
		if value and not prev_inputs[input] then
			new_inputs[input] = true
		end
	end

	self:attemptRotate(new_inputs, piece, grid, initial)

	-- prev_inputs becomes the previous inputs
	for input, value in pairs(inputs) do
		prev_inputs[input] = inputs[input]
	end
end

function Ruleset:attemptRotate(new_inputs, piece, grid, initial)
	local rot_dir = 0
	
	if (new_inputs["rotate_left"] or new_inputs["rotate_left2"]) then
		rot_dir = 3
	elseif (new_inputs["rotate_right"] or new_inputs["rotate_right2"]) then
		rot_dir = 1
	elseif (new_inputs["rotate_180"]) then
		rot_dir = self:get180RotationValue()
	end

	if rot_dir == 0 then return end

	local new_piece = piece:withRelativeRotation(rot_dir)

	if (grid:canPlacePiece(new_piece)) then
		piece:setRelativeRotation(rot_dir)
		self:onPieceRotate(piece, grid)
	else
		if not(initial and self.enable_IRS_wallkicks == false) then
			self:attemptWallkicks(piece, new_piece, rot_dir, grid)
		end
	end
end

function Ruleset:attemptWallkicks(piece, new_piece, rot_dir, grid)
	-- do nothing in default ruleset
end

function Ruleset:movePiece(piece, grid, move, instant)
	local x = piece.position.x
	if move == "left" then
		piece:moveInGrid({x=-1, y=0}, 1, grid, false)
	elseif move == "right" then
		piece:moveInGrid({x=1, y=0}, 1, grid, false)
	elseif move == "speedleft" then
		piece:moveInGrid({x=-1, y=0}, 10, grid, instant)
	elseif move == "speedright" then
		piece:moveInGrid({x=1, y=0}, 10, grid, instant)
	end
	if piece.position.x ~= x then
		self:onPieceMove(piece, grid)
	end
end

function Ruleset:dropPiece(
	inputs, piece, grid, gravity, drop_speed, drop_locked, hard_drop_locked,
	hard_drop_enabled, additive_gravity
)
	local y = piece.position.y
	if inputs["down"] == true and drop_locked == false then
		if additive_gravity then
			piece:addGravity(gravity + drop_speed, grid)
		else
			piece:addGravity(math.max(gravity, drop_speed), grid)
		end
	elseif inputs["up"] == true and hard_drop_enabled == true then
		if hard_drop_locked == true or piece:isDropBlocked(grid) then
			piece:addGravity(gravity, grid)
		else
			piece:dropToBottom(grid)
		end
	else
		piece:addGravity(gravity, grid)
	end
	if piece.position.y ~= y then
		self:onPieceDrop(piece, grid)
	end
end

function Ruleset:lockPiece(piece, grid, lock_delay)
	if piece:isDropBlocked(grid) and piece.gravity >= 1 and piece.lock_delay >= lock_delay then
		piece.locked = true
	end
end

function Ruleset:get180RotationValue() return 2 end
function Ruleset:getDefaultOrientation() return 1 end

function Ruleset:initializePiece(
	inputs, data, grid, gravity, prev_inputs,
	move, lock_delay, drop_speed,
	drop_locked, hard_drop_locked, big
)
	local spawn_positions
	if big then
		spawn_positions = self.big_spawn_positions
	else
		spawn_positions = self.spawn_positions
	end
	local piece = Piece(data.shape, data.orientation - 1, {
		x = spawn_positions[data.shape].x,
		y = spawn_positions[data.shape].y
	}, self.block_offsets, 0, 0, data.skin, big)

	self:onPieceCreate(piece)
	self:rotatePiece(inputs, piece, grid, {}, true)
	self:dropPiece(inputs, piece, grid, gravity, drop_speed, drop_locked, hard_drop_locked)
	return piece
end

-- stuff like move count, rotate count, floorkick count go here
function Ruleset:onPieceCreate(piece) end

function Ruleset:processPiece(
	inputs, piece, grid, gravity, prev_inputs,
	move, lock_delay, drop_speed,
	drop_locked, hard_drop_locked,
	hard_drop_enabled, additive_gravity
)
	self:rotatePiece(inputs, piece, grid, prev_inputs, false)
	self:movePiece(piece, grid, move, gravity >= 20)
	self:dropPiece(
		inputs, piece, grid, gravity, drop_speed, drop_locked, hard_drop_locked,
		hard_drop_enabled, additive_gravity
	)
	self:lockPiece(piece, grid, lock_delay)
end

function Ruleset:onPieceMove(piece) end
function Ruleset:onPieceRotate(piece) end
function Ruleset:onPieceDrop(piece) end

return Ruleset
