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
	print (string.format ("Casino v %s", casino.version))
end

function casino:OpenTables ()
	math.randomseed (os.time ())
	math.random ()
	casino.data.tablesOpen = true
	casino:Print ("Opening Tables")
	if not casino.data.houseThread or coroutine.status (casino.data.houseThread) == "dead" then
		-- Create house thread
		casino.data.houseThread = coroutine.create (casino.RunPlayerProcesses)
	end
	
	-- Start plotter thread
	if coroutine.status (casino.data.houseThread) == "suspended" then
		casino:RunHouseThread ()
	end
end

function casino:CloseTables ()
	casino.data.tablesOpen = false
end

casino.arguments = {
	add = casino.AddGame,
	remove = casino.RemoveGame,
	help = casino.Help,
	open = casino.OpenTables,
	close = casino.CloseTables
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
