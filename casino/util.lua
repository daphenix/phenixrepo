--[[
	Casino Thread handling and utlities
]]

function casino:Print (msg)
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:SendAnnouncement ()
	local totalAds = #casino.data.announcements
	table.insert (casino.data.messageQueue,
						casino:Message (nil,
							casino.data.announcements [math.random (1, totalAds)],
							casino.data.announcementTypeList [casino.data.announcementType],
							casino.data.announcementChannel))
	table.insert (casino.data.messageQueue,
						casino:Message (nil,
							casino.data.announcements [math.random (1, totalAds)],
							casino.data.announcementTypeList [casino.data.announcementType2],
							casino.data.announcementChannel2))
end

function casino:Log (msg)
	-- Consider outputing to a mission log for storage
	local m = string.format ("\12700ff00%s\127o", msg)
	print (m)
end

function casino:ChatHelp (playerName)
	casino.messaging:Send (playerName, "Casino Commands:")
	casino.messaging:Send (playerName, "help: Get help from the casino or from the game")
	casino.messaging:Send (playerName, "balance: Get your current bank balance")
	casino.messaging:Send (playerName, "withdraw <amount>: Withdraw funds from your bank account (must be in the casino sector)")
	casino.messaging:Send (playerName, "close: Close out your bank account and receive all remaining funds (must be in the casino sector)")
	casino.messaging:Send (playerName, "play <gameName>: Start a new game")
	casino.messaging:Send (playerName, "play: Play an existing game")
	casino.messaging:Send (playerName, "We have available: " .. table.concat (casino.games.gamesList, ", "))
end

function casino:IsWaiting (playerName)
	local s = "::" .. table.concat (casino.data.waitQueue, "::") .. "::"
	return string.find (s, "::" .. playerName .. "::")
end

function casino:IsBanned (playerName)
	return casino.data.bannedList [playerName]
end

function casino:DoBan (playerName, reason)
	if not casino:IsBanned (playerName) then
		casino.data.bannedList [playerName] = reason
		casino.messaging:Send (playerName, "You have been banned from playing.  Contact a PA official to appeal")
		if casino.data.tables [playerName] then
			casino.data.tables [playerName].isDone = true
		end
	end
end

function casino:DoUnban (playerName)
	if casino:IsBanned (playerName) then
		casino.data.bannedList [playerName] = nil
		casino.messaging:Send (playerName, "You have been unbanned.  Please feel free to play")
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
					casino.messaging:Send (casino.data.waitQueue [1], "A spot has opened in the Casino!")
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
			messaging.threadBusy = true
			-- Make Backup of Bank Records
			casino.data:SaveAccountInfo ()
			
			-- Check for transfers to/from guild bank
			if casino.data.profitTrigger > 0 and casino.data.lossTrigger > 0 then
				local currentAssets = casino.bank:GetTotalAssets ()
				local profit = casino.bank.assets - currentAssets
				if profit > casino.data.profitTrigger then
					Guild.deposit (casino.data.profitTransferAmount, "Casino Profit Transfer")
					casino:Log (string.format ("Casino Profit Transfer: %d", casino.data.profitTransferAmount))
					casino.bank.assets = currentAssets
				elseif profit < -1 * casino.data.lossTrigger then
					Guild.withdraw (casino.data.lossTransferAmount, "Casino Loss Coverage")
					casino:Log (string.format ("Casino Loss Coverage: %d", casino.data.lossTransferAmount))
					casino.bank.assets = currentAssets
				end
			end
			casino:Log ("Bank backup complete at " .. os.date (casino.ui.dateFormat))
			casino.data:SaveLog ()
			casino:RunBackup ()
			messaging.threadBusy = false
		end
	end)
end

function casino:RunAnnouncements ()
	Timer ():SetTimeout (casino.data.adDelay, function ()
		if casino.data.tablesOpen then
			-- Get an ad from the list and create a message
			messaging.threadBusy = true
			local totalAds = #casino.data.announcements
			if casino.data.useAnnouncements and totalAds > 0 then
				casino:SendAnnouncement ()
				casino:RunAnnouncements ()
			end
			messaging.threadBusy = false
		end
	end)
end

local runHouseThread = true
function casino:RunThreads ()
	if casino.data.tablesOpen or casino.data.simulatorThread  then
		Timer ():SetTimeout (casino.data.delay, function ()
			-- Determine which thread to run
			if not messaging.threadBusy then
				if runHouseThread and casino.data.houseThread and coroutine.status (casino.data.houseThread):lower () == "suspended" then
					runHouseThread = true
					if casino.data.simulatorThread then
						runHouseThread = false
					end
					coroutine.resume (casino.data.houseThread)
				elseif (not runHouseThread or runHouseThread and not casino.data.houseThread) and casino.data.simulatorThread and coroutine.status (casino.data.simulatorThread):lower () == "suspended" then
					runHouseThread = false
					if casino.data.houseThread then
						runHouseThread = true
					end
					coroutine.resume (casino.data.simulatorThread)
				else
					runHouseThread = true
				end
			end
			
			-- Determine conditions for continuing thread
			if (casino.data.houseThread and coroutine.status (casino.data.houseThread):lower () ~= "dead") or (casino.data.simulatorThread and coroutine.status (casino.data.simulatorThread):lower () ~= "dead") then
				casino:RunThreads  ()
			elseif casino.data.houseThread and coroutine.status (casino.data.houseThread):lower () == "dead" then
				casino:Print ("Casino is Closed")
				casino.data:SaveAccountInfo ()
				-- Close all tables
				casino.data.numPlayers = 0
				local p
				for _, p in pairs (casino.data.tables) do
					casino:Log (string.format ("Removing Process for player %s", p.player))
					p.controller:Close ()
					casino.data.tables [p.player] = nil
				end
				casino.data.houseThread = nil
			else
				casino:Print ("Simulation Complete")
				casino.data.simulatorThread = nil
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
