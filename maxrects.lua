local MaxRects = {}

function MaxRects.make( width, height, flip )
	return {
		width = width,
		height = height,
		flip = flip or false,
		used = {},
		free = {{0,0,width,height}}
	}
end

local function placeRect( self, best )
	-- TODO
end

function MaxRects.insert( self, rects, method )
	local rectsSet = {}
	for i = 1, #rects do
		rectsSet[rects[i]] = rects[i]
	end
	local out = {}
	while next( rectsSet ) do
		local best1, best2, best = math.huge, math.huge, nil
		for rect in pairs( rectsSet ) do
			local score1, score2, node = scoreRect( self, rect[3], rect[4], method )
			if score1 < best1 or (score1 == best1 and score2 < best2) then
				best1, best2, best = score1, score2, node
			end
		end
		if not best then
			return false, {}
		end
		self = placeRect( self, best )
		out[#out+1] = best
		rectsSet[best] = nil
	end
	return true, out
end

return MaxRects
