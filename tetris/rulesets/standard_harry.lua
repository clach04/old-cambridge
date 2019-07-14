local Standard = require 'tetris.rulesets.standard'

local SRS = Standard:extend()

SRS.name = "Harry-SRS"
SRS.hash = "StandardHarry"

function SRS:onPieceMove(piece, grid)
	piece.lock_delay = 0 -- move reset
	if piece:isDropBlocked(grid) then
		piece.move_counter = piece.move_counter + 1
		if piece.move_counter >= 10 then
			piece.locked = true
		end
	end
end

function SRS:onPieceRotate(piece, grid)
	piece.lock_delay = 0 -- rotate reset
	if piece:isDropBlocked(grid) then
		piece.rotate_counter = piece.rotate_counter + 1
		if piece.rotate_counter >= 8 then
			piece.locked = true
		end
	end
end

function SRS:get180RotationValue() return config["reverse_rotate"] and 1 or 3 end

return SRS
