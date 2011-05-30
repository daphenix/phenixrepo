--[[
	Casino Thread handling and utlities
]]

function casino:Message (playerName, msg, isPublic)
	local type = "CHANNEL"
	if not isPublic then type = "PRIVATE" end
	local message = {
		player = playerName,
		msg = msg,
		type = type,
		Send = function ()
			SendChat (msg, type, playerName)
		end
	}
	
	return message
end

function casino:Print (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:SendMessage (playerName, msg)
	table.insert (casino.data.messageQueue, casino:Message (playerName, msg))
end

function casino:SendPublicMessage (msg)
	table.insert (casino.data.messageQueue, casino:Message (nil, msg, true))
end

function casino:Log (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:ChatHelp (playerName)
	casino:SendMessage (playerName, "Casino Commands:")
	casino:SendMessage (playerName, "help: Get help from the casino or from the game")
	casino:SendMessage (playerName, "balance: Get your current bank balance")
	casino:SendMessage (playerName, "withdraw <amount>: Withdraw funds from your bank account (must be in the casino sector)")
	casino:SendMessage (playerName, "close: Close out your bank account and receive all remaining funds (must be in the casino sector)")
	casino:SendMessage (playerName, "play <gameName>: Start a new game")
	casino:SendMessage (playerName, "play: Play an existing game")
	casino:SendMessage (playerName, "We have available: " .. table.concat (casino.games.gamesList, ", "))
end

function casino:IsBanned (playerName)
	return casino.data.bannedList [playerName]
end

function casino:DoBan (playerName, reason)
	if not casino:IsBanned (playerName) then
		casino.data.bannedList [playerName] = reason
		casino:SendMessage (playerName, "You have been banned from playing.  Contact a PA official to appeal")
		if casino.data.tables [playerName] then
			casino.data.tables [playerName].isDone = true
		end
	end
end

function casino:DoUnban (playerName)
	if casino:IsBanned (playerName) then
		casino.data.bannedList [playerName] = nil
		casino:SendMessage (playerName, "You have been unbanned.  Please feel free to play")
	end
end

-- Thread management
function casino:RunPlayerProcesses ()
	while (casino.data.tablesOpen) do
		-- Run any open tables
		local p
		for _, p in pairs (casino.data.tables) do
			if p.isDone then
				casino:Log (string.format ("Removing Spent Process for player %s", p.player))
				p.controller:Close ()
				casino.data.tables [p.player] = nil
				casino.data.numPlayers = casino.data.numPlayers - 1
				if #casino.data.waitQueue > 0 then
					casino:SendMessage (casino.data.waitQueue [1], "A spot has opened in the Casino!")
					table.remove (casino.data.waitQueue, 1)
				end
			else
				p.controller:ProcessRequest (p.request)
				p.request = nil
			end
		end
		casino:Yield ()
	end
end

function casino:RunBackup ()
	Timer ():SetTimeout (casino.data.backupDelay, function ()
		if casino.data.tablesOpen then
			casino.data:SaveAccountInfo ()
			casino.data:SaveLog ()
			casino:RunBackup ()
		end
	end)
end

function casino:RunAnnouncements ()
	Timer ():SetTimeout (casino.data.adDelay, function ()
		if casino.data.tablesOpen then
			-- Get an ad from the list and create a message
			local totalAds = #casino.data.announcements
			if casino.data.useAnnouncements and totalAds > 0 then
				casino:SendPublicMessage (casino.data.announcements [math.random (1, totalAds)])
				casino:RunAnnouncements ()
			end
		end
	end)
end

function casino:RunMessageQueue ()
	Timer ():SetTimeout (casino.data.chatDelay, function ()
		if casino.data.tablesOpen then
			if #casino.data.messageQueue > 0 then
				--casino.data.messageQueue [1]:Send ()
				table.remove (casino.data.messageQueue, 1):Send ()
			end
			casino:RunMessageQueue ()
		end
	end)
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
