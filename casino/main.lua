--[[
	Casino Manager
	
	Author: Keller  aka "Jackie the Coder"
	
	This is set up so a main process thread is constantly in listener mode so long as the tables are open.
	Individual players will have separate process threads spawned for their play which will be responsible
		for the actual functioning of each player's interaction with each table.
]]

declare ("casino", {})
casino.version = "0.1"
dofile ("data/data.lua")
dofile ("games/games.lua")
dofile ("util.lua")
dofile ("ui/ui.lua")
dofile ("debug.lua")

function casino:Help ()
	purchaseprint (string.format ("Casino v %s", casino.version))
end

function casino:OpenTables ()
	math.randomseed (os.time ())
	math.random ()
	casino:Print ("Casino is Open")
	if not casino.data.houseThread or coroutine.status (casino.data.houseThread) == "dead" then
		-- Create house thread
		casino.data.houseThread = coroutine.create (casino.RunPlayerProcesses)
	end
	
	-- Start plotter thread
	RegisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	RegisterEvent (casino.data, "CHAT_MSG_SECTORD_SECTOR")
	casino.data.tablesOpen = true
	if coroutine.status (casino.data.houseThread) == "suspended" then
		casino:RunHouseThread ()
		
		-- Make announcement that the casino is open.  Give casino sector
	end
end

function casino:CloseTables ()
	-- Make announcement that the casino is closed
	
	UnregisterEvent (casino.data, "CHAT_MSG_SECTORD_SECTOR")
	UnregisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	casino.data.tablesOpen = false
end

casino.arguments = {
	add_game = casino.AddGame,
	remove_game = casino.RemoveGame,
	open_account = casino.AddAccount,
	close_account = casino.RemoveAccount,
	display = casino.DisplayAccounts,
	status = casino.Status,
	help = casino.Help,
	start = casino.OpenTables,
	stop = casino.CloseTables
}
function casino.Start (obj, args)
	if args then
		local f = casino.arguments [args [1]:lower ()] or casino.Help
		f (casino, args)
	else
		casino:Help ()
	end
end
RegisterUserCommand ("casino", casino.Start)
