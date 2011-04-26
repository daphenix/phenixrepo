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
	
	function frontdesk:Help ()
		frontdesk:ParseKey ()
	end
	
	function frontdesk:ParseKey (key, args)
		replyNumber = replyNumber + 1
		if replyNumber < 3 then
			frontdesk:SendMessage ("Available games are: Slots")
		else
			local response = math.random (1, 4)
			if response == 1 then
				frontdesk:SendMessage ("I know you are, but what am I?")
			elseif response == 2 then
				frontdesk:SendMessage ("What makes you think I would do that for you?")
			elseif response ==3 then
				frontdesk:SendMessage ("Security!!")
			else
				frontdesk:SendMessage ("Just go away already!")
			end
		end
	end
	
	function frontdesk:Play (req)
		frontdesk:ParseKey ("", req)
	end
	
	return frontdesk
end