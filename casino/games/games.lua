--[[
	Games modules installed
]]

casino.games = {}

-- All games installable
dofile ("games/dummy.lua")
dofile ("games/slots.lua")

casino.games.gamesList = {
	["dummy"] = casino.games.Dummy,
	["slots"] = casino.games.Slots
}

function casino.games:BaseController (game)
	local base = {
		canPlay = false
	}
	function base:Play (req) end

	function base:SendMessage (msg)
		--SendChat (msg, "PRIVATE", game.player)
		print (msg)
	end
	
	function base:Win (amt)
		base:SendMessage (string.format ("You Win %dc!", (game.acct.currentBet + amt)))
		game.acct:Deposit (game.acct.currentBet + amt)
	end
	
	function base:Lose ()
		base:SendMessage ("You Lose.  Better Luck Next Time")
		game.acct.currentBet = 0
	end
	
	function base:ProcessRequest (req)
		if req then
			local key, args = string.match (req:lower (), "^(%w+)%s*(.*)$")
			if not game.acct then
				base:SendMessage ("You must visit the casino sector and set up an account to be able to play\nJust /givemoney to the casino to set up an account\nQuitting game")
				game.isDone = true
				
			elseif key == "bet" and not base.canPlay then
				base.canPlay = game.acct:MakeBet (tonumber (args))
				
			elseif key == "quit" then
				game.isDone = true
				
			elseif key == "play" then
				if base.canPlay then
					casino:Yield ()
					base:Play (args)
				else
					base:SendMessage ("You must bet before you can play")
				end
			end
		end
	end
	
	return base
end

function casino.games:CreateGame (gameName, playerName)
	casino:Log ("Creating game " .. tostring (gameName) .. " for player " .. playerName)
	local game = {
		name = gameName,
		player = playerName,
		acct = casino.bank.trustAccount [playerName],
		isDone = false,
		request = nil
	}
	local controller = casino.games.gamesList [gameName] or casino.games.Dummy
	game.controller = controller (game)
	
	return game
end
