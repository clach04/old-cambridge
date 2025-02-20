local Object = require 'libs.classic'

local Grid = Object:extend()

local empty = { skin = "", colour = "" }

function Grid:new()
	self.grid = {}
	self.grid_age = {}
	for y = 1, 24 do
		self.grid[y] = {}
		self.grid_age[y] = {}
		for x = 1, 10 do
			self.grid[y][x] = empty
			self.grid_age[y][x] = 0
		end
	end
end

function Grid:clear()
	for y = 1, 24 do
		for x = 1, 10 do
			self.grid[y][x] = empty
			self.grid_age[y][x] = 0
		end
	end
end

function Grid:isOccupied(x, y)
	return self.grid[y+1][x+1] ~= empty
end

function Grid:isRowFull(row)
	for index, square in pairs(self.grid[row]) do
		if square == empty then return false end
	end
	return true
end

function Grid:canPlacePiece(piece)
	if piece.big then
		return self:canPlaceBigPiece(piece)
	end

	local offsets = piece:getBlockOffsets()
	for index, offset in pairs(offsets) do
		local x = piece.position.x + offset.x
		local y = piece.position.y + offset.y
		if x >= 10 or x < 0 or y >= 24 or y < 0 or self.grid[y+1][x+1] ~= empty then
			return false
		end
	end
	return true
end

function Grid:canPlaceBigPiece(piece)
	local offsets = piece:getBlockOffsets()
	for index, offset in pairs(offsets) do
		local x = piece.position.x + offset.x
		local y = piece.position.y + offset.y
		if x >= 5 or x < 0 or y >= 12 or y < 0 or
			self.grid[y * 2 + 1][x * 2 + 1] ~= empty or
			self.grid[y * 2 + 1][x * 2 + 2] ~= empty or
			self.grid[y * 2 + 2][x * 2 + 1] ~= empty or
			self.grid[y * 2 + 2][x * 2 + 2] ~= empty
		then
			return false
		end
	end
	return true
end

function Grid:canPlacePieceInVisibleGrid(piece)
	if piece.big then
		return self:canPlaceBigPiece(piece)
		-- forget canPlaceBigPieceInVisibleGrid for now
	end

	local offsets = piece:getBlockOffsets()
	for index, offset in pairs(offsets) do
		local x = piece.position.x + offset.x
		local y = piece.position.y + offset.y
		if x >= 10 or x < 0 or y >= 24 or y < 4 or self.grid[y+1][x+1] ~= empty then
			return false
		end
	end
	return true
end

function Grid:getClearedRowCount()
	local count = 0
	for row = 1, 24 do
		if self:isRowFull(row) then
			count = count + 1
		end
	end
	return count
end

function Grid:markClearedRows()
	for row = 1, 24 do
		if self:isRowFull(row) then
			for x = 1, 10 do
				self.grid[row][x] = {
					skin = self.grid[row][x].skin,
					colour = "X"
				}
			end
		end
	end
	return true
end

function Grid:clearClearedRows()
	for row = 1, 24 do
		if self:isRowFull(row) then
			for above_row = row, 2, -1 do
				self.grid[above_row] = self.grid[above_row - 1]
				self.grid_age[above_row] = self.grid_age[above_row - 1]
			end
			self.grid[1] = {empty, empty, empty, empty, empty, empty, empty, empty, empty, empty}
			self.grid_age[1] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		end
	end
	return true
end

function Grid:copyBottomRow()
	for row = 1, 23 do
		self.grid[row] = self.grid[row+1]
		self.grid_age[row] = self.grid_age[row+1]
	end
	self.grid[24] = {empty, empty, empty, empty, empty, empty, empty, empty, empty, empty}
	self.grid_age[24] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	for col = 1, 10 do
		self.grid[24][col] = (self.grid[23][col] == empty) and empty or {
			skin = self.grid[23][col].skin,
			colour = "G"
		}
	end
	return true
end

function Grid:applyPiece(piece)
	if piece.big then
		self:applyBigPiece(piece)
		return
	end
	offsets = piece:getBlockOffsets()
	for index, offset in pairs(offsets) do
		x = piece.position.x + offset.x
		y = piece.position.y + offset.y
		self.grid[y+1][x+1] = {
			skin = piece.skin,
			colour = piece.shape
		}
	end
end

function Grid:applyBigPiece(piece)
	offsets = piece:getBlockOffsets()
	for index, offset in pairs(offsets) do
		x = piece.position.x + offset.x
		y = piece.position.y + offset.y
		for a = 1, 2 do
			for b = 1, 2 do
				self.grid[y*2+a][x*2+b] = {
					skin = piece.skin,
					colour = piece.shape
				}
			end
		end
	end
end

function Grid:update()
	for y = 1, 24 do
		for x = 1, 10 do
			if self.grid[y][x] ~= empty then
				self.grid_age[y][x] = self.grid_age[y][x] + 1
			end
		end
	end
end

function Grid:draw()
	for y = 1, 24 do
		for x = 1, 10 do
			if self.grid[y][x] ~= empty then
				if self.grid_age[y][x] < 1 then
					love.graphics.setColor(1, 1, 1, 1)
					love.graphics.draw(blocks[self.grid[y][x].skin]["F"], 48+x*16, y*16)
				else
					love.graphics.setColor(0.5, 0.5, 0.5, 1)
					love.graphics.draw(blocks[self.grid[y][x].skin][self.grid[y][x].colour], 48+x*16, y*16)
				end
				if self.grid[y][x].skin ~= "bone" then
					love.graphics.setColor(0.8, 0.8, 0.8, 1)
					love.graphics.setLineWidth(1)
					if y > 1 and self.grid[y-1][x] == empty then
						love.graphics.line(48.0+x*16, -0.5+y*16, 64.0+x*16, -0.5+y*16)
					end
					if y < 24 and self.grid[y+1][x] == empty then
						love.graphics.line(48.0+x*16, 16.5+y*16, 64.0+x*16, 16.5+y*16)
					end
					if x > 1 and self.grid[y][x-1] == empty then
						love.graphics.line(47.5+x*16, -0.0+y*16, 47.5+x*16, 16.0+y*16)
					end
					if x < 10 and self.grid[y][x+1] == empty then
						love.graphics.line(64.5+x*16, -0.0+y*16, 64.5+x*16, 16.0+y*16)
					end
				end
			end
		end
	end
end

function Grid:drawInvisible(opacity_function, garbage_opacity_function)
	for y = 1, 24 do
		for x = 1, 10 do
			if self.grid[y][x] ~= empty then
				if self.grid[y][x].colour == "X" then
					opacity = 1
				elseif garbage_opacity_function and self.grid[y][x].colour == "G" then
					opacity = garbage_opacity_function(self.grid_age[y][x])
				else
					opacity = opacity_function(self.grid_age[y][x])
				end
				love.graphics.setColor(0.5, 0.5, 0.5, opacity)
				love.graphics.draw(blocks[self.grid[y][x].skin][self.grid[y][x].colour], 48+x*16, y*16)
				if opacity > 0 and self.grid[y][x].colour ~= "X" then
					love.graphics.setColor(0.64, 0.64, 0.64)
					love.graphics.setLineWidth(1)
					if y > 1 and self.grid[y-1][x] == empty then
						love.graphics.line(48.0+x*16, -0.5+y*16, 64.0+x*16, -0.5+y*16)
					end
					if y < 24 and self.grid[y+1][x] == empty then
						love.graphics.line(48.0+x*16, 16.5+y*16, 64.0+x*16, 16.5+y*16)
					end
					if x > 1 and self.grid[y][x-1] == empty then
						love.graphics.line(47.5+x*16, -0.0+y*16, 47.5+x*16, 16.0+y*16)
					end
					if x < 10 and self.grid[y][x+1] == empty then
						love.graphics.line(64.5+x*16, -0.0+y*16, 64.5+x*16, 16.0+y*16)
					end
				end
			end
		end
	end
end

return Grid
