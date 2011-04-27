--[[
	This "game" is intended to be a brief command help in game
	but also the comments should reflect a young woman being annoyed by a patron
	
	The intent here is to flesh this out more as a conversation bot
]]
function casino.games.FrontDesk (game)
	local frontdesk = casino.games:BaseController  (game)
	frontdesk.canPlay = true
	frontdesk.startup = "This is the Front Desk.  How may I help you?"
	local replyNumber = 0
	
	-- Random Responses
	local responses = {
		"I know you are, but what am I?",
		"What makes you think I would do that for you?",
		"Security!!",
		"Just go away already!"
	}
	
	function frontdesk:Help ()
		frontdesk:ParseKey ()
	end
	
	function frontdesk:ParseKey (key, args)
		replyNumber = replyNumber + 1
		if replyNumber < 3 then
			frontdesk:SendMessage ("Available games are: Slots.  Just send !casino play <gameName> to play one of our games")
		else
			local index = math.random (1, #responses)
			frontdesk:SendMessage (responses [index])
		end
	end
	
	function frontdesk:Play (req)
		-- If using the "play" keyword, check existing games and swap out if possible
		if casino.games.gamesList [req:lower ()] then
			Timer ():SetTimeout (2*casino.data.delay, function ()
				local playerName = frontdesk.player
				local gameName = req:lower ()
				casino.data.tables [playerName] = nil
				casino.games:CreateGame (gameName, playerName)
			end)
		else
			frontdesk:ParseKey ("play", req)
		end
	end
	
	return frontdesk
end