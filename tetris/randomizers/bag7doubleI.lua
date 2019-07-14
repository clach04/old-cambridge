local Randomizer = require 'tetris.randomizers.randomizer'

local Bag7RandomizerDoubleI = Randomizer:extend()

function Bag7RandomizerDoubleI:initialize()
	self.bag = {"I", "I", "J", "L", "O", "S", "T", "Z"}
end

function Bag7RandomizerDoubleI:generatePiece()
	if next(self.bag) == nil then
		self.bag = {"I", "I", "J", "L", "O", "S", "T", "Z"}
	end
	local x = math.random(table.getn(self.bag))
	return table.remove(self.bag, x)
end

return Bag7RandomizerDoubleI
