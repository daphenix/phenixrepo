--[[
	Messaging Toolset
]]

declare ("messaging", {})
messaging.threadBusy = false
messaging.queue = {}
messaging.chatDelay = 350

local users = {}
local numUsers = 0

function messaging:Split (s, d, trim)
	s = s or ""
	d = d or " "
	trim = trim or false
	local words = {}
	s = s .. d
	local pattern = "[^" .. d .. "]+"
	
	local elem
	for elem, _ in string.gmatch (s, pattern) do
		if trim then
			table.insert (words, string.match (elem, "%P+"))
		else
			table.insert (words, elem)
		end
	end
	
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
		Send = function () SendChat (msg, type, playerName) end
	}
	
	return message
end

function messaging:Send (playerName, msg, type, channel)
	local line
	for _, line in ipairs (messaging:Split (msg, "//")) do
		table.insert (messaging.queue, messaging:Message (playerName, line, type, channel))
	end
end

function messaging:SendPublicMessage (msg)
	local line
	for _, line in ipairs (messaging:Split (msg, "//")) do
		table.insert (messaging.queue, messaging:Message (nil, line, "CHANNEL", 100))
	end
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