--[[
	Bartender
	
	Author: Keller  aka "Jak the Coder"
	
	This plugin represents a simulated Bartender managing the bar in a station
]]

declare ("bartender", {})
bartender.version = "0.1"
dofile ("data/data.lua")
if not messaging then
	dofile ("messaging.lua")
end
dofile ("chat/chat.lua")
dofile ("util.lua")
dofile ("ui/ui.lua")

function bartender:Help ()
	purchaseprint (string.format ("Bartender v %s", bartender.version))
	purchaseprint ("Commands\n")
	purchaseprint ("\tstart - Opens bar and activates bartender")
	purchaseprint ("\tstop - Closes bar and deactivates bartender")
end

function bartender:OpenBar ()
	print ("Starting Bartender")
	if not bartender.data.thread or coroutine.status (bartender.data.thread) == "dead" then
		-- Create thread
		bartender.data.thread = coroutine.create (bartender.RunConversations)
	end
	casino.bank:Open (bartender)
	RegisterEvent (bartender.data, "CHAT_MSG_BAR")
	RegisterEvent (bartender.data.pay, "BANK_DEPOSIT")
	bartender.data.barOpen = true
	if coroutine.status (bartender.data.thread) == "suspended" then
		messaging:Start (bartender)
		bartender:RunThread ()
	end
end

function bartender:CloseBar ()
	print ("Stopping Bartender")
	bartender.data.barOpen = false
	casino.bank:Close (bartender)
	messaging:Stop (bartender)
	UnregisterEvent (bartender.data, "CHAT_MSG_BAR")
	UnregisterEvent (bartender.data.pay, "BANK_DEPOSIT")
end

bartender.arguments = {
	start = bartender.OpenBar,
	stop = bartender.CloseBar
}
function bartender.Start (obj, args)
	if args then
		local f = bartender.arguments [args [1]:lower ()] or bartender.Help
		f (bartender, args)
	else
		bartender:Help ()
	end
end
RegisterUserCommand ("bartender", bartender.Start)