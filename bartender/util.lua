--[[
	Helpful Utilities
]]

function bartender:ChatHelp (playerName)
	messaging:Send (playerName, "Bartender Basic Conversation:")
	messaging:Send (playerName, "help: This list")
	messaging:Send (playerName, "bye: Stop talking to the Bartender")
end

-- Thread management
function bartender:RunConversations ()
	while (bartender.data.barOpen) do
		-- Run any open tables
		local p
		for _, p in pairs (bartender.data.conversations) do
			if p.isDone or os.difftime (os.time (), p.lastActive) > 500 then
				print ("is done")
				p:Stop ()
				bartender.data.conversations [p.player] = nil
			else
				p:Parse (p.request)
				p.request = nil
			end
		end
		bartender:Yield ()
	end
end

function bartender:RunThread ()
	if bartender.data.barOpen then
		Timer ():SetTimeout (bartender.data.delay, function ()
			-- Determine which thread to run
			if not messaging.threadBusy and bartender.data.thread and coroutine.status (bartender.data.thread):lower () == "suspended" then
				coroutine.resume (bartender.data.thread)
			end
			
			-- Determine conditions for continuing thread
			if bartender.data.thread and coroutine.status (bartender.data.thread):lower () ~= "dead" then
				bartender:RunThread ()
			else
				bartender.data:SaveData ()
				-- Close all conversations
				local p
				for _, p in pairs (bartender.data.conversations) do
					p:Stop ()
					bartender.data.conversations [p.player] = nil
					print ("Remove Conversation")
				end
				bartender.data.thread = nil
			end
		end)
	end
end

function bartender:Yield ()
	bartender.data.stepCounter = bartender.data.stepCounter + 1
	if bartender.data.stepCounter == bartender.data.chunkSize then
		bartender.data.stepCounter = 0
		coroutine.yield ()
	end
end
