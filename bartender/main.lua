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

local debugMode = false
function bartender:OpenBar (args)
	if not bartender.data.barOpen then
		print ("Starting Bartender")
		debugMode = (args [2] == "true")
		if not bartender.data.thread or coroutine.status (bartender.data.thread) == "dead" then
			-- Create thread
			bartender.data.thread = coroutine.create (bartender.RunConversations)
		end
		
		-- Start Plugin Threads
		casino.bank:Open (bartender)
		if debugMode then
			RegisterEvent (bartender.data.debug, "CHAT_MSG_GROUP")
		else
			RegisterEvent (bartender.data, "CHAT_MSG_BAR")
		end
		RegisterEvent (bartender.data.pay, "BANK_DEPOSIT")
		bartender.data.barOpen = true
		if coroutine.status (bartender.data.thread) == "suspended" then
			messaging:Start (bartender)
			bartender:RunThread ()
		end
	end
end

function bartender:CloseBar ()
	if bartender.data.barOpen then
		print ("Stopping Bartender")
		bartender.data.barOpen = false
		casino.bank:Close (bartender)
		messaging:Stop (bartender)
		if debugMode then
			UnregisterEvent (bartender.data.debug, "CHAT_MSG_GROUP")
		else
			UnregisterEvent (bartender.data, "CHAT_MSG_BAR")
		end
		UnregisterEvent (bartender.data.pay, "BANK_DEPOSIT")
	end
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