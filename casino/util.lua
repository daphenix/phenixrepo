--[[
	Casino Thread handling and utlities
]]

function casino:Print (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:RunPlayerProcesses ()
	while (casino.data.tablesOpen) do
		local p
		for _, p in pairs (casino.data.tables) do
			if p and p.isDone then
				print (string.format ("Removing Spent Process for player %s", p.player))
				p = nil
			else
				casino:Yield ()
				p.controller.ProcessRequest (p)
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
				casino:Print ("All Tables Closed")
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
