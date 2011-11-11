--[[
	Cargolist
	
	Original author: Mick
	Rewritten with permission: Keller
]]

declare ("cargolist", {})
cargolist.version = "1.1"
cargolist.config = "cargolist"
dofile ("data/data.lua")
dofile ("util.lua")
dofile ("ui/ui.lua")

function cargolist:OpenScan ()
	if PlayerInStation () then
		ShowDialog (cargolist.ui:CreateAlertUI ("Cannot Scan inside Station"), iup.CENTER, iup.CENTER)
	else
		cargolist.data.scanner = nil
		local frame = cargolist.ui:CreateUI ()
	end
end

function cargolist:OpenSettings ()
	local frame = cargolist.ui:CreateSettingsUI ()
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end

function cargolist:NextDropItem ()
	local list = cargolist.data.itemList
	if cargolist.data.targetPolicy == 3 and cargolist.data.currentDrop == #list then
		cargolist:RunBackScan (nil, false)
	else
		if list and #list > 0 then
			if cargolist.data.currentDrop < #list then
				cargolist.data.currentDrop = cargolist.data.currentDrop + 1
			else
				cargolist.data.currentDrop = 1
			end
			if not cargolist.util:SetTarget () then
				cargolist.util:CleanList ()
			end
		end
	end
end

function cargolist:PreviousDropItem ()
	local list = cargolist.data.itemList
	if list and #list > 0 then
		if cargolist.data.currentDrop > 1 then
			cargolist.data.currentDrop = cargolist.data.currentDrop - 1
		else
			cargolist.data.currentDrop = #list
		end
		if not cargolist.util:SetTarget () then
			cargolist.util:CleanList ()
		end
	end
end

function cargolist:Help ()
	purchaseprint ("Cargolist Commands")
	purchaseprint ("-  help - Prints this list")
	purchaseprint ("-  options - Displays Control screen")
	purchaseprint ("-  scan [setName] - Performs a background scan against the current set")
	purchaseprint ("-      or against an new set defined by setName")
	purchaseprint ("- /DropScan - Shortcut command for /cargolist scan")
	purchaseprint ("- /NextDropItem - Advances to the next scanned drop item")
	purchaseprint ("- /PreviousDropItem - Reverses to the previously scanned drop item")
end

cargolist.command = {
	help = cargolist.Help,
	options = cargolist.OpenSettings,
	scan = cargolist.RunBackScan
}
function cargolist:Start (args)
	if args then
		local f = cargolist.command [args [1]:lower ()] or cargolist.Help
		f (cargolist, args)
	else
		cargolist:OpenScan ()
	end
end

function cargolist.ProcessScanSetCommand (set, args)
	if set then
		cargolist:RunBackScan ({"scan", set})
	end
end
RegisterUserCommand ("cargolist", cargolist.Start)
RegisterUserCommand ("DropScan", cargolist.RunBackScan)
RegisterUserCommand ("DropScan_All", cargolist.ProcessScanSetCommand, "All")
RegisterUserCommand ("NextDropItem", cargolist.NextDropItem)
RegisterUserCommand ("PreviousDropItem", cargolist.PreviousDropItem)