--[[
	Utility Functions for Cargolist
]]

cargolist.util = {}
declare ("targetless", targetless or nil)

function cargolist:RunBackScan (args, isFreshScan)
	if PlayerInStation () then
		ShowDialog (cargolist.ui:CreateAlertUI ("Cannot Scan inside Station"), iup.CENTER, iup.CENTER)
	elseif not cargolist.data.scanner then
		if args and #args > 1 and (args [2] == 'All' or cargolist.data.cargoSets [args [2]]) then
			cargolist.data.activeSet = args [2]
		end
		if cargolist.data.targetPolicy == 3 then
			if isFreshScan == nil then
				isFreshScan = true
			end
			cargolist.data.scanner = coroutine.create (function ()
				cargolist.util:Print (string.format ("Scanning %s ...", cargolist.data.activeSet))
				cargolist.util:RadarListScan (isFreshScan)
				cargolist.util:Print ("Done")
				cargolist.util:SetLocks (false)
				cargolist:KillThread ()
			end)
		else
			cargolist.data.scanner = coroutine.create (function ()
				cargolist.util:Print (string.format ("Scanning %s ...", cargolist.data.activeSet))
				cargolist.util:ScanCargo ()
				cargolist.util:Print (string.format ("Done.  Located: %d", #cargolist.data.itemList))
				cargolist.util:SetLocks (false)
				cargolist:KillThread ()
			end)
		end
		return cargolist:RunScan ()
	end
end

function cargolist:RunScan ()
	if cargolist.data.scanner then
		Timer ():SetTimeout (cargolist.data.delay, function ()
			if cargolist.data.scanner then
				coroutine.resume (cargolist.data.scanner)
				if coroutine.status (cargolist.data.scanner):lower () ~= "dead" then
					return cargolist:RunScan ()
				end
			end
		end)
	end
end

function cargolist:Yield (forcePause)
	if cargolist.data.scanner then
		cargolist.data.stepCounter = cargolist.data.stepCounter + 1
		if forcePause or cargolist.data.stepCounter == cargolist.data.maxSteps then
			cargolist.data.stepCounter = 0
			coroutine.yield ()
		end
	end
end

function cargolist:KillThread ()
	Timer ():SetTimeout (500, function ()
			cargolist.util:SetLocks (false)
			cargolist.data.scanner = nil
		end)
end

function cargolist:SetScanLock (flag)
	cargolist.data.scanLock = flag
end

function cargolist.util:Print (msg)
	HUD:PrintSecondaryMsg ("\12700ff00" .. msg .. "\127o")
end

function cargolist.util:SetActiveSet (set)
	if cargolist.data.cargoSets [set] then
		cargolist.data.activeSet = set
	else
		cargolist.data.activeSet = "All"
	end
end

function cargolist.util:GetTargetInfo ()
	local name, health, dist = GetTargetInfo ()
	local objectType, objectId = radar.GetRadarSelectionID ()
	
	-- string, number, number, number
	return {name=name, health=health, dist=dist, type=objectType, id=objectId}
end

function cargolist.util:SortDrops (list)
	if #list > 0 then
		table.sort (list, function (a,b)
			if cargolist.ui.sortColumn == 1 then
				return a.name:lower () < b.name:lower ()
			elseif cargolist.ui.sortColumn == 2 then
				return a.dist < b.dist
			else
				return false
			end
	end)
	end
end

function cargolist.util:SetLocks (flag)
	if targetless then
		targetless.api.radarlock = flag
		targetless.var.lock = flag
		targetless.var.scanlock = flag
	end
end

function cargolist.util:SetTarget ()
	--print ("Set Target - start")
	local list = cargolist.data.itemList
	local drop = cargolist.data.currentDrop
	--print ("Current Drop: " .. tostring (cargolist.data.currentDrop))
	if list [drop] then
		local id = list [drop].id
		local type = list [drop].type
		cargolist.util:SetLocks (true)
		radar.SetRadarSelection (type, id)
		cargolist.util:SetLocks (false)
		
		--print ("Expected Target: " .. tostring (list [drop].name))
		--print ("Actual Target: " .. tostring (cargolist.util:GetTargetInfo ().name))
		--print ("*return " .. tostring (cargolist.util:GetTargetInfo ().name:lower () == list [drop].name:lower ()))
		return cargolist.util:GetTargetInfo ().name:lower () == list [drop].name:lower ()
	end
	
	--print ("return false")
	return false
end

function cargolist.util:CleanList ()
	-- Called if the current target is nil
	--print ("CleanList - start")
	local item
	--print ("List Length (before): " .. tostring (#cargolist.data.itemList))
	repeat
		--print ("Current Drop: " .. tostring (cargolist.data.currentDrop))
		item = table.remove (cargolist.data.itemList, cargolist.data.currentDrop)
		--print ("Item Removed: " .. tostring (item.name))
		if cargolist.data.currentDrop > #cargolist.data.itemList then
			cargolist.data.currentDrop = 1
		end
	until (#cargolist.data.itemList == 0 or cargolist.util:SetTarget ())
	--print ("List Length (after): " .. tostring (#cargolist.data.itemList))
end

function cargolist.util:CheckDrop (object)
	if not object or not object.name then return false end
	if object.name == "Asteroid" or object.name == "Ice Crystal" or object.type ~= 2 then return false end
	if cargolist.data.activeSet == "All" then
		return true
	else
		local item
		local list = cargolist.data.cargoSets [cargolist.data.activeSet].items
		for _,item in ipairs (list) do
			object.name = name:gsub ("-", " ")
			item = item:gsub ("-", " ")
			cargolist:Yield ()
			if object.name:lower ():find (item:lower ()) then
				return true
			end
		end
		
		return false
	end
end

function cargolist.util:IsUnique (id)
	local item
	if not id then return false end
	for _, item in ipairs (cargolist.data.itemList) do
		if item.id == id then
			return false
		end
		cargolist:Yield ()
	end
	
	return true
end

function cargolist.util:ScanCargo ()
	-- if check if scan lock is on.  If locked, skip scan
	if not cargolist.data.scanLock then
		cargolist.util:SetLocks (true)
		local steps = 0
		local items = 0
		local maxItems = cargolist.data.maxItemListSize
		local maxScans = cargolist.data.maxScannableItems
		local currentObjType = nil
		local currentObjId = nil
		local policy = cargolist.data.targetPolicy
		if policy == 1 then
			currentObjType, currentObjId = radar.GetRadarSelectionID ()
		end
		cargolist.data.stepCounter = 0
		cargolist.data.itemList = {}
		-- Reset radar and refresh commands
		radar.SetRadarSelection ()
		cargolist:Yield (true)
		
		local firstObject = {}
		local object = {}
		local resetCount = 0
		local nilCount = 0
		cargolist:Yield ()
		repeat
			steps = steps + 1
			if object.id and not firstObject.id then
				firstObject.id = object.id
				firstObject.type = object.type
			end
			gkinterface.GKProcessCommand ("RadarPrev")
			cargolist:Yield ()
			object= cargolist.util:GetTargetInfo ()
			if not object.id then
				nilCount = nilCount + 1
			end
			if object.id ~= firstObject.id and cargolist.util:CheckDrop (object) then
				cargolist.data.itemList [#cargolist.data.itemList+1] = object
				items = items + 1
				nilCount = 0
			end
			if nilCount > 2 then
				resetCount = resetCount + 1
				nilCount = 0
				gkinterface.GKProcessCommand ("RadarNext")
				cargolist:Yield ()
			end
		until steps >= maxScans or items >= maxItems or object.type ~= 2 or object.name == "Asteroid" or object.name == "Ice Crystal" or (firstObject.id and object.id == firstObject.id) or resetCount > 2
		
		cargolist.data.currentDrop = 0
		cargolist.util:SortDrops (cargolist.data.itemList)
		if #cargolist.data.itemList > 0 and policy == 2 then
			cargolist.data.currentDrop = 1
			local currentDrop = cargolist.data.itemList [1]
			currentObjType = currentDrop.type
			currentObjId = currentDrop.id
		end
		radar.SetRadarSelection (currentObjType, currentObjId)
		cargolist.util:SetLocks (false)
	end
end

function cargolist.util:RadarListScan (isFreshScan)
	if not cargolist.data.scanLock then
		cargolist.util:SetLocks (true)
		local steps = 0
		local maxScans = cargolist.data.maxScannableItems
		cargolist.data.stepCounter = 0
		
		-- Reset radar and refresh commands
		if isFreshScan then
			cargolist.data.itemList = {}
			radar.SetRadarSelection ()
		elseif #cargolist.data.itemList > 0 then
			local o = cargolist.data.itemList [#cargolist.data.itemList]
			radar.SetRadarSelection (o.type, o.id)
		end
		cargolist:Yield (true)
		
		local firstObject = {}
		local object = {}
		local checkDrop = false
		local isUnique = false
		repeat
			steps = steps + 1
			if object.id and not firstObject.id  then
				firstObject.id = object.id
				firstObject.type = object.type
			end
			gkinterface.GKProcessCommand ("RadarPrev")
			object= cargolist.util:GetTargetInfo ()
			checkDrop = cargolist.util:CheckDrop (object)
			isUnique = cargolist.util:IsUnique (object.id)
		until steps >= maxScans or object.type ~= 2 or object.name == "Asteroid" or object.name == "Ice Crystal" or (firstObject.id and object.id == firstObject.id) or (checkDrop and isUnique)
		
		if checkDrop and isUnique then
			-- Check list to determine if current ID has been scanned before
			local last = #cargolist.data.itemList + 1
			cargolist.data.itemList [last] = object
			cargolist.data.currentDrop = last
		elseif #cargolist.data.itemList > 0 then
			cargolist.data.currentDrop = 1
			object.id = cargolist.data.itemList [cargolist.data.currentDrop].id
			object.type = cargolist.data.itemList [cargolist.data.currentDrop].type
		else
			object.id = nil
			object.type = nil
		end
		radar.SetRadarSelection (object.type, object.id)
		cargolist.util:SetLocks (false)
	end
end