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
	purchaseprint ("Commands\n")
	purchaseprint ("\tadd_game <playerName> <gameName> - Add a game for a given player to the open tables list")
	purchaseprint ("\tremove_game <playerName> - Removes a game for the given player")
	purchaseprint ("\topen_account <playerName> <amt> - Open a bank account for a player")
	purchaseprint ("\tclose_account <playerName> - Closes a player's account (without cashout)'")
	purchaseprint ("\tbank - Displays all existing bank accounts")
	purchaseprint ("\tgames - Displays all currently running games")
	purchaseprint ("\treservations - Displays all players on the waiting list")
	purchaseprint ("\tstatus - Displays all bank account, open game, and wait list information, plus the house thread status")
	purchaseprint ("\thelp - Prints this list")
	purchaseprint ("\tbackup - Backs up all bank account information")
	purchaseprint ("\tstart - Starts up the Casino")
	purchaseprint ("\tstop - Shuts down the Casino")
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
	--RegisterEvent (casino.data, "CHAT_MSG_GROUP")
	RegisterEvent (casino.data, "CHAT_MSG_SECTORD")
	casino.data.tablesOpen = true
	if coroutine.status (casino.data.houseThread) == "suspended" then
		casino:RunHouseThread ()
		casino:RunMessageQueue ()
		casino:RunBackup ()
		
		-- Make announcement that the casino is open.  Give casino sector
		SendChat ("The Casino is Open!", "GUILD", nil)
	end
end

function casino:CloseTables ()
	-- Make announcement that the casino is closed
	SendChat ("The Casino is Closed!", "GUILD", nil)
	
	UnregisterEvent (casino.data, "CHAT_MSG_SECTORD")
	UnregisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	--UnregisterEvent (casino.data, "CHAT_MSG_GROUP")
	casino.data.tablesOpen = false
end

casino.arguments = {
	add_game = casino.AddGame,
	remove_game = casino.RemoveGame,
	open_account = casino.AddAccount,
	close_account = casino.RemoveAccount,
	bank = casino.DisplayAccounts,
	games = casino.DisplayGames,
	reservations = casino.DisplayWaitQueue,
	status = casino.Status,
	help = casino.Help,
	backup = casino.data.SaveAccountInfo,
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
