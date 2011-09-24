--[[
	Messaging Toolset
]]

declare ("messaging", {})
messaging.threadBusy = false
messaging.queue = {}
messaging.chatDelay = 350

local users = {}
local numUsers = 0

function messaging:Split (s, d)
	print ("splitting " .. s)
	s = s or ""
	d = d or " "
	local words = {}
	s = s .. d
	local pattern = "([%w]+)%p*" .. d
	local elem
	for elem, _ in string.gmatch (s, pattern) do
		table.insert (words, elem)
	end
	print (string.format ("Returning %d words", #words))
	return words
end

function messaging:Start (p)
	if not users [p] then
	    users [p] = "YES"
	    numUsers = numUsers + 1
		if numUsers == 1 then
			messaging:RunMessageQueue ()
		end
	end
end

function messaging:Stop (p)
    if users [p] then
        users [p] = nil
        numUsers = numUsers - 1
    end
end

function messaging:Message (playerName, msg, type, channel)
	type = type or "PRIVATE"
	if type == "CHANNEL" and not playerName then
		playerName = channel
	end
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

function messaging:Send (playerName, msg, type, channel)
	table.insert (messaging.queue, messaging:Message (playerName, msg, type, channel))
end

function messaging:SendPublicMessage (msg)
	table.insert (messaging.queue, messaging:Message (nil, msg, "CHANNEL", 100))
end

-- Thread management
function messaging:RunMessageQueue ()
	Timer ():SetTimeout (messaging.chatDelay, function ()
		if not messaging.threadBusy and numUsers > 0 then
			messaging.threadBusy = true
			if #messaging.queue > 0 then
				table.remove (messaging.queue, 1):Send ()
			end
			messaging:RunMessageQueue ()
			messaging.threadBusy = false
		end
	end)
end