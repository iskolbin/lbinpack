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


function MaxRects.BEST_AREA( freeList, rect, flip )
	local bestArea, bestShortSideFit, bestFreeIndex = math.huge, math.huge, -1
	for i, free in ipairs( freeList ) do
		local areaFit = free[3] * free[4] - rect[3]*rect[4]
		if free[3] >= rect[3] and free[4] >= rect[4] then
			local shortSideFit = math.min( free[3] - rect[3], free[4] - rect[4] )
			if areaFit < bestAreaFit or (areaFit == bestAreaFit and shortSideFit < bestShortSideFit) then
				bestAreaFit, bestShortSideFit, bestFreeIndex = areaFit, shortSideFit, i
			end
		end
	end
	if i ~= -1 then
		local best = {}
		for k, v in pairs( rect ) do
			best[k] = v
		end
		best[1], best[2] = freeList[bestFreeIndex][1], freeList[bestFreeIndex][2]
		return bestAreaFit, bestShortSideFit, best, bestFreeIndex
	end
end

local function placeRect( usedList, freeList, used, freeIndex )
	local free = table.remove( freeList, freeIndex )
	if used[1] < free[1] + free[3] and used[1] + used[3] > free[1] then
		if used[2] > free[2] and used[2] < free[2] + free[4] then
			table.insert( freeList, {free[1],used[2]-free[2],free[3],free[4]})
		end
		if used[2] + used[4] < free[2] + free[4] then
			table.insert( freeList, {free[1],used[2]+used[4],free[3],free[2]+free[4]-used[2]-used[4]})
		end
	end
	if used[2] < free[2] + free[4] and used[2] + used[4] > free[2] then
		if used[1] > free[1] and used[1] < free[1] + free[3] then
			table.insert( freeList, {used[1]-free[1],free[2],free[3],free[4]})
		end
		if used[1] + used[3] < free[1] + free[3] then
			table.insert( freeList, {used[1]+used[3],free[2],free[1]+free[3]-used[1]-used[3],free[4]})
		end
	end
	table.insert( usedList, used )
end

function MaxRects.insert( self, rects, method )
	local rectsSet, usedList, freeList = {}, {}, {}
	for i = 1, #rects do
		rectsSet[rects[i]] = rects[i]
	end
	for i = 1, #self.used do
		usedList[i] = self.used[i]
	end
	for i = 1, #self.free do
		freeList[i] = self.free[i]
	end
	local out = {}
	while next( rectsSet ) do
		local best1, best2, bestInserting, bestFreeIndex = math.huge, math.huge, nil, -1
		for rect in pairs( rectsSet ) do
			local score1, score2, fitInserting, fitFreeIndex = MaxRects[method]( freeList, rect, self.flip )
			if score1 < best1 or (score1 == best1 and score2 < best2) then
				best1, best2, bestInserting, bestFreeIndex = score1, score2, fitInserting, fitFreeIndex
			end
		end
		if not bestInserting then
			return false, self
		end
		placeRect( usedList, freeList, bestInserting, bestFreeIndex )
		table.insert( out, bestInserting )
		rectsSet[best] = nil
	end
	return true, {width = self.width, height = self.height, flip = self.flip, used = usedList, free = freeList}, out
end

return MaxRects
