--[[
	Casino Manager
	
	Author: Keller  aka "Jackie the Coder"
	
	This is set up so a main process thread is constantly in listener mode so long as the tables are open.
	Individual players will have separate process threads spawned for their play which will be responsible
		for the actual functioning of each player's interaction with each table.
]]

declare ("casino", {})
casino.version = "0.8"
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
	purchaseprint ("\tban <playerName> - Bans a player from playing in the casino")
	purchaseprint ("\tunban <playerName> - Removes a player fromt the ban list")
	purchaseprint ("\tbank - Displays all existing bank accounts")
	purchaseprint ("\tgames - Displays all currently running games")
	purchaseprint ("\treservations - Displays all players on the waiting list")
	purchaseprint ("\tstats - Displays win/loss record for all games and money bet vs paidout by bank")
	purchaseprint ("\tstatus - Displays all bank account, open game, and wait list information, plus the house thread status")
	purchaseprint ("\treset - Resets the randomization of the casino")
	purchaseprint ("\thelp - Prints this list")
	purchaseprint ("\tbackup - Backs up all bank account information")
	purchaseprint ("\tstart [true/false] - Starts up the Casino (if passing true/false determines debug mode)")
	purchaseprint ("\tstop - Shuts down the Casino")
end

function casino:OpenSettings ()
	local frame = casino.ui:CreateSettingsUI ()
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
end

local debugMode = false
function casino:OpenTables (args)
	debugMode = (args [2] == "true")
	casino:Reset ()
	casino:Print ("Casino is Open")
	if not casino.data.houseThread or coroutine.status (casino.data.houseThread) == "dead" then
		-- Create house thread
		casino.data.houseThread = coroutine.create (casino.RunPlayerProcesses)
	end
	
	-- Start plotter thread
	if debugMode then
		RegisterEvent (casino.data, "CHAT_MSG_GROUP")
	else
		RegisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	end
	RegisterEvent (casino.data, "CHAT_MSG_SECTORD")
	casino.data.tablesOpen = true
	if coroutine.status (casino.data.houseThread) == "suspended" then
		casino:RunHouseThread ()
		casino:RunMessageQueue ()
		casino:RunBackup ()
		
		casino.data.wins = 0
		casino.data.losses = 0
		casino.data.totalBet = 0
		casino.data.totalPaidout = 0
		
		-- Make announcement that the casino is open.  Give casino sector
		if not debugMode then
			SendChat (string.format ("The Phoenix Casino is Open in %s!", LocationStr (GetCurrentSectorid ())), "CHANNEL", nil)
		end
	end
end

function casino:CloseTables ()
	-- Make announcement that the casino is closed
	if not debugMode then
		SendChat ("The Phoenix Casino is Closed!", "CHANNEL", nil)
	end
	
	UnregisterEvent (casino.data, "CHAT_MSG_SECTORD")
	if debugMode then
		UnregisterEvent (casino.data, "CHAT_MSG_GROUP")
	else
		UnregisterEvent (casino.data, "CHAT_MSG_PRIVATE")
	end
	debugMode = false
	casino.data.tablesOpen = false
end

casino.arguments = {
	add_game = casino.AddGame,
	remove_game = casino.RemoveGame,
	open_account = casino.AddAccount,
	close_account = casino.RemoveAccount,
	ban = casino.BanPlayer,
	unban = casino.UnbanPlayer,
	bank = casino.DisplayAccounts,
	games = casino.DisplayGames,
	reservations = casino.DisplayWaitQueue,
	stats = casino.DisplayGameStats,
	status = casino.Status,
	reset = casino.Reset,
	help = casino.Help,
	backup = casino.data.SaveAccountInfo,
	options = casino.OpenSettings,
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
