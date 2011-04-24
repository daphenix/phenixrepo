--[[
	This "game" is intended to be a brief command help in game
	but also the comments should reflect a young woman being annoyed by a patron
	
	The intent here is to flesh this out more as a conversation bot
]]
function casino.games.FrontDesk (game)
	local frontdesk = casino.games:BaseController  (game)
	frontdesk.canPlay = true
	local replyNumber = 1
	
	function frontdesk:Play (req)
		if replyNumber < 3 then
			frontdesk:SendMessage ("Basic Game Commands: play, bet, or quit")
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
	
	return frontdesk
end