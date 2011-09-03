--[[
	This "game" is intended to be a brief command help in game
	but also the comments should reflect a young woman being annoyed by a patron
	
	The intent here is to flesh this out more as a conversation bot
]]
casino.games.frontdesk = {}
casino.games.frontdesk.version = "0.5"
casino.games.frontdesk.name = "Front Desk"
casino.games.frontdesk.isPlayable = false

function casino.games.frontdesk.GetController (game)
	local frontdesk = casino.games:BaseController  (game)
	frontdesk.canPlay = true
	local replyNumber = 0
	
	-- Random Responses
	local responses = {
		"I know you are, but what am I?",
		"What makes you think I would do that for you?",
		"Isn't there someone else you could talk to?",
		"Security!!",
		"You don't have many friends, do you?",
		"Just go away already!"
	}
	
	-- Clerk Names
	local clerks = {
		"Melanie",
		"Stacy",
		"Shonna",
		"Aster",
		"Helen",
		"Joanna",
		"Kylie"
	}
	frontdesk.startup = string.format ("This is the Front Desk.  My name is %s.  How may I help you?", clerks [math.random (1, #clerks)])
	
	function frontdesk:Help ()
		frontdesk:ParseKey ()
	end
	
	function frontdesk:ParseKey (key, args)
		replyNumber = replyNumber + 1
		if replyNumber < 3 then
			frontdesk:SendMessage (string.format ("Available games are: %s.  Just send !casino play <gameName> to play one of our games", table.concat (casino.games.gamesList, ", ")))
		else
			local index = math.random (1, #responses)
			frontdesk:SendMessage (responses [index])
		end
	end
	
	function frontdesk:Play (req)
		-- If using the "play" keyword, check existing games and swap out if possible
		if casino.games [req:lower ()] then
			Timer ():SetTimeout (2*casino.data.delay, function ()
				local playerName = game.player
				local gameName = req:lower ()
				casino:Log (string.format ("Player: %s\tGame: %s", tostring (playerName), tostring (gameName)))
				casino.data.numPlayers = casino.data.numPlayers - 1
				casino.data.tables [playerName] = casino.games:CreateGame (gameName, playerName)
			end)
		else
			frontdesk:ParseKey ("play", req)
		end
	end
	
	return frontdesk
end

function casino.games.frontdesk.CreateConfigUI (game)
	local ui = iup.hbox {
		iup.label {title = "Create REALLY annoyed clerks!", font=casino.ui.font, expand="YES"};
		expand = "YES"
	}
	
	function ui:DoSave ()
	end
	
	function ui:DoCancel ()
	end
	
	return ui
end