--[[
	Casino Thread handling and utlities
]]

function casino:Print (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:SendMessage (playerName, msg)
	--SendChat (msg, "PRIVATE", playerName)
	print (msg)
end

function casino:Log (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

-- Thread management
function casino:RunPlayerProcesses ()
	while (casino.data.tablesOpen) do
		-- Run any open tables
		local p
		for _, p in pairs (casino.data.tables) do
			if p.isDone then
				casino:Log (string.format ("Removing Spent Process for player %s", p.player))
				casino.data.tables [p.player] = nil
			else
				p.controller:ProcessRequest (p.request)
				p.request = nil
			end
		end
		casino:Yield ()
	end
end

function casino:RunHouseThread ()
	if casino.data.tablesOpen then
		Timer ():SetTimeout (casino.data.delay, function ()
			coroutine.resume (casino.data.houseThread)
			if coroutine.status (casino.data.houseThread):lower () ~= "dead" then
				casino:RunHouseThread ()
			else
				casino:Print ("Casino is Closed")
				casino.data:SaveAccountInfo ()
			end
		end)
	end
end

function casino:Yield ()
	casino.data.stepCounter = casino.data.stepCounter + 1
	if casino.data.stepCounter == casino.data.chunkSize then
		casino.data.stepCounter = 0
		coroutine.yield ()
	end
end
