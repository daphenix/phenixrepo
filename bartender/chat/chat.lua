--[[
	Chat Parser and functions
]]

bartender.chat = {}
dofile ("data/personalities.lua")
dofile ("data/vocabulary.lua")

function bartender.chat:CreateParser (playerName)
	local parser = {
		player = playerName,
		personality = {},
		isDone = false,
		lastActive = os.time (),
		request = nil
	}
	
	local function Barter ()
	end
	
	local function GetResponse (words)
		print ("GetResponse")
		local response = {}
		print ("Key = " .. words [1])
		if words [1] == "bye" then
			print ("Done")
			return function () parse.isDone = true end
		elseif words [1] == "hi" then
			print ("Starting")
			return function ()
				--parser:SendMessage ("Hello.  May I help you?")
				print ("Hello.  May I help you?")
			end
		end
		
		-- Default Response
		return function ()
			--parser:SendMessage (bartender.data.questions [math.random (1, #bartender.data.questions)], "STATION")
			print (bartender.data.questions [math.random (1, #bartender.data.questions)])
		end
	end
	
	function parser:SendMessage (msg)
		table.insert (messaging.queue, messaging:Message (parser.player, msg, "STATION"))
	end
	
	function parser:SendPrivateMessage (msg)
		table.insert (messaging.queue, messaging:Message (parser.player, msg))
	end
	
	-- Starts up the parser
	function parser:Start ()
		-- Build the bartender personality
	end
	
	-- Stops the parser
	function parser:Stop ()
		--parser:SendMessage ("Bye")
		print ("saying Bye")
	end
	
	-- Parses the inbound string request
	function parser:Parse (request)
		if request and request:len () > 0 then
			parser.lastActive = os.time ()
			
			-- Check for response
			local words = messaging:Split (request)
			local respond = GetResponse (words)
			respond (parser, words)
		end
	end
	
	return parser
end
