--[[
	Data Management for Cargolist
]]

cargolist.data = {}
cargolist.data.id = 314159265359
cargolist.data.settingsOffset = 20
cargolist.data.isInitialized = false
cargolist.data.delay = 25
cargolist.data.maxSteps = 4
cargolist.data.stepCounter = 0
cargolist.data.itemList = {}
cargolist.data.pickups = {}
cargolist.data.maxScannableItems = 400
cargolist.data.maxItemListSize = 100
cargolist.data.activeSet = "All"
cargolist.data.cargoSets = nil
cargolist.data.currentDrop = 0
cargolist.data.scanner = nil
cargolist.data.scanLock = false
cargolist.data.autoAdvance = true

-- Options
cargolist.data.targetPolicy = 1

--------------------------------------------------------------
--
--	Data Handling Functions
--
--------------------------------------------------------------

function cargolist.data:Unbind (list)
	local name, set, command
	for name,set in pairs (list) do
		command = "DropScan_" .. set.alias
		gkinterface.UnbindCommand (command)
		UnregisterUserCommand (command)
	end
end

function cargolist.data:SaveBinds (binds)
	local scanScreenBind = binds [1] or ""
	local scanBind = binds [2] or ""
	local nextDropBind = binds [3] or ""
	local previousDropBind = binds [4] or ""
	local scanAllBind = binds [5] or ""
	gkinterface.UnbindCommand ("cargolist")
	if scanScreenBind:len () > 0 then
		gkini.WriteString (cargolist.config, "scanScreenBind", scanScreenBind)
		gkinterface.GKProcessCommand (string.format ("bind %s cargolist", scanScreenBind))
	end
	gkinterface.UnbindCommand ("DropScan")
	if scanBind:len () > 0 then
		gkini.WriteString (cargolist.config, "scanBind", scanBind)
		gkinterface.GKProcessCommand (string.format ("bind %s DropScan", scanBind))
	end
	gkinterface.UnbindCommand ("NextDropItem")
	if nextDropBind:len () > 0 then
		gkini.WriteString (cargolist.config, "nextDropBind", nextDropBind)
		gkinterface.GKProcessCommand (string.format ("bind %s NextDropItem", nextDropBind))
	end
	gkinterface.UnbindCommand ("PreviousDropItem")
	if previousDropBind:len () > 0 then
		gkini.WriteString (cargolist.config, "previousDropBind", previousDropBind)
		gkinterface.GKProcessCommand (string.format ("bind %s PreviousDropItem", previousDropBind))
	end
	gkinterface.UnbindCommand ("DropScan_All")
	if scanAllBind:len () > 0 then
		gkini.WriteString (cargolist.config, "scanAllBind", scanAllBind)
		gkinterface.GKProcessCommand (string.format ("bind %s DropScan_All", scanAllBind))
	end
	
	-- Set all Scan Set Aliases and Binds
	local name, set, command
	cargolist.data:Unbind (cargolist.data.cargoSets)
	for name,set in pairs (cargolist.data.cargoSets) do
		command = "DropScan_" .. set.alias
		RegisterUserCommand (command, cargolist.ProcessScanSetCommand, name)
		if set.bind:len () > 0 then
			gkinterface.GKProcessCommand ("bind " .. set.bind .. " " .. command)
		end
	end
end

function cargolist.data:LoadBinds ()
	local scanScreenBind = gkini.ReadString (cargolist.config, "scanScreenBind", "")
	gkinterface.UnbindCommand ("cargolist")
	if scanScreenBind:len () > 0 then
		gkinterface.GKProcessCommand (string.format ("bind %s cargolist", scanScreenBind))
	end
	local scanBind = gkini.ReadString (cargolist.config, "scanBind", "")
	gkinterface.UnbindCommand ("DropScan")
	if scanBind:len () > 0 then
		gkinterface.GKProcessCommand (string.format ("bind %s DropScan", scanBind))
	end
	local nextDropBind = gkini.ReadString (cargolist.config, "nextDropBind", "")
	gkinterface.UnbindCommand ("NextDropItem")
	if nextDropBind:len () > 0 then
		gkinterface.GKProcessCommand (string.format ("bind %s NextDropItem", nextDropBind))
	end
	local previousDropBind = gkini.ReadString (cargolist.config, "previousDropBind", "")
	gkinterface.UnbindCommand ("PreviousDropItem")
	if previousDropBind:len () > 0 then
		gkinterface.GKProcessCommand (string.format ("bind %s PreviousDropItem", previousDropBind))
	end
	local scanAllBind = gkini.ReadString (cargolist.config, "scanAllBind", "")
	gkinterface.UnbindCommand ("DropScan_All")
	if scanAllBind:len () > 0 then
		gkini.WriteString (cargolist.config, "scanAllBind", scanAllBind)
		gkinterface.GKProcessCommand (string.format ("bind %s DropScan_All", scanAllBind))
	end
	
	-- Set all Scan Set Aliases and Binds
	local name, set, command
	for name,set in pairs (cargolist.data.cargoSets) do
		if not set.bind then set.bind = "" end
		if not set.alias then set.alias = string.gsub (name, " ", "_") end
		command = "DropScan_" .. set.alias
		gkinterface.UnbindCommand (command)
		UnregisterUserCommand (command)
		RegisterUserCommand (command, cargolist.ProcessScanSetCommand, name)
		if set.bind:len () > 0 then
			gkinterface.GKProcessCommand ("bind " .. set.bind .. " " .. command)
		end
	end
end

function cargolist.data:SaveOptions ()
	gkini.WriteInt (cargolist.config, "targetPolicy", cargolist.data.targetPolicy)
	gkini.WriteString (cargolist.config, "activeSet", cargolist.data.activeSet)
	gkini.WriteInt (cargolist.config, "sortColumn", cargolist.ui.sortColumn)
	gkini.WriteInt (cargolist.config, "maxScannableItems", cargolist.data.maxScannableItems)
	gkini.WriteInt (cargolist.config, "maxItemListSize", cargolist.data.maxItemListSize)
	gkini.WriteString (cargolist.config, "autoAdvance", tostring (cargolist.data.autoAdvance))
	if pairs (cargolist.data.cargoSets) then
		local charId = cargolist.data.id + cargolist.data.settingsOffset
		SaveSystemNotes (spickle (cargolist.data.cargoSets), charId)
	end
end

function cargolist.data:LoadOptions ()
	if not cargolist.data.cargoSets then
		local charId = cargolist.data.id + cargolist.data.settingsOffset
		cargolist.data.cargoSets = unspickle (LoadSystemNotes (charId)) or {}
	end
	cargolist.data.targetPolicy = gkini.ReadInt (cargolist.config, "targetPolicy", 1)
	cargolist.data.activeSet = gkini.ReadString (cargolist.config, "activeSet", "All")
	cargolist.util:SetActiveSet (cargolist.data.activeSet)
	cargolist.ui.sortColumn = gkini.ReadInt (cargolist.config, "sortColumn", 1)
	cargolist.data.maxScannableItems = gkini.ReadInt (cargolist.config, "maxScannableItems", 400)
	cargolist.data.maxItemListSize = gkini.ReadInt (cargolist.config, "maxItemListSize", 100)
	cargolist.data.autoAdvance = gkini.ReadString (cargolist.config, "autoAdvance", "true") == "true"
	cargolist.data:LoadBinds ()
end

--------------------------------------------------------------
--
--	Initialization and Event Handling
--
--------------------------------------------------------------

-- Event Handling and Initialization
cargolist.data.initialize = {}
function cargolist.data.initialize:OnEvent (event, id)
	if not cargolist.data.isInitialized then
		UnregisterEvent (cargolist.data.initialize, "PLAYER_ENTERED_GAME")
		cargolist.data:LoadOptions ()
		
		-- Event Registration
		RegisterEvent (cargolist.data.logout, "PLAYER_LOGGED_OUT")
		RegisterEvent (cargolist.data.restart, "UNLOAD_INTERFACE")
		RegisterEvent (cargolist.data, "INVENTORY_UPDATE")
		
		cargolist.data.pickups = {}
		cargolist.data.isInitialized = true
	end
end

-- Lua ReloadInterface ()
cargolist.data.restart = {}
function cargolist.data.restart:OnEvent (event, data)
	cargolist.data.isInitialized = false
	UnregisterEvent (cargolist.data, "INVENTORY_UPDATE")
	UnregisterEvent (cargolist.data.restart, "UNLOAD_INTERFACE")
	UnregisterEvent (cargolist.data.logout, "PLAYER_LOGGED_OUT")
	cargolist.data:Unbind (cargolist.data.cargoSets)
	RegisterEvent (cargolist.data.initialize , "PLAYER_ENTERED_GAME")
end

-- Logout procedure
cargolist.data.logout = {}
function cargolist.data.logout:OnEvent (event, id)
	cargolist.data:SaveOptions ()
end

-- Main Event Handler
function cargolist.data:OnEvent (event, data)
	if not PlayerInStation () and event == "INVENTORY_UPDATE" then
		local name = GetInventoryItemName (data)
		cargolist.data.pickups [name] = data
		if cargolist.data.autoAdvance and #cargolist.data.itemList > 0 and cargolist.data.currentDrop > 0 and string.find (cargolist.data.itemList [cargolist.data.currentDrop].name, name) then
			if cargolist.data.targetPolicy == 3 and cargolist.data.currentDrop == #cargolist.data.itemList then
				table.remove (cargolist.data.itemList, cargolist.data.currentDrop)
				cargolist.data.currentDrop = #cargolist.data.itemList
				cargolist:RunBackScan (nil, false)
			else
				cargolist.util:CleanList ()
			end
		end
	end
end
RegisterEvent (cargolist.data.initialize , "PLAYER_ENTERED_GAME")