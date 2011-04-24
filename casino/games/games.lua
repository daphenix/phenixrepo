--[[
	Games modules installed
]]

casino.games = {}

-- All games installable
dofile ("games/dummy.lua")
dofile ("games/slots.lua")

casino.games.gamesList = {
	["frontdesk"] = casino.games.FrontDesk,
	["slots"] = casino.games.Slots
}

function casino.games:BaseController (game)
	local base = {
		-- Set this to true when all preconditions for play have been satisfied
		canPlay = false
	}
	
	--[[*************************************************
	
		Override these 2 functions for each game if desired
	]]
	
	-- How to play this game
	function base:Help () end
	
	-- Primary Play function
	function base:Play (req) end
	
	-- Used for any additional processing that is needed but in default key set
	-- e.g. raise or see in Poker
	function base:ParseKey (key, args) end
	
	--[[
		End Override Section
		
	*****************************************************]]

	function base:SendMessage (msg)
		table.insert (casino.data.messageQueue, casino:Message (game.player, msg))
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
			casino:Yield ()
			if not game.acct then
				base:SendMessage ("You must visit the casino sector and set up an account to be able to play.  Just /givemoney to the casino to set up an account.  Quitting game")
				game.isDone = true
				
			elseif key == "help" then
				base:Help ()
				
			elseif key == "bet" and not base.canPlay then
				base.canPlay = game.acct:MakeBet (tonumber (args), true)
				
			elseif key == "quit" then
				game.isDone = true
				
			elseif key == "play" then
				if base.canPlay then
					base:Play (args)
				else
					base:SendMessage ("You must bet before you can play")
				end
			else
				base:ParseKey (key, args)
			end
		end
	end
	
	return base
end

function casino.games:CreateGame (gameName, playerName)
	if gameName:len () > 0 then
		casino:Log ("Creating game " .. tostring (gameName) .. " for player " .. playerName)
		local game = {
			name = gameName,
			player = playerName,
			acct = casino.bank.trustAccount [playerName],
			isDone = false,
			request = nil
		}
		local controller = casino.games.gamesList [gameName:lower ()] or casino.games.FrontDesk
		game.controller = controller (game)
		
		-- Send Response to player
		game.controller:SendMessage ("You are now playing " .. gameName)
		casino.data.numPlayers = casino.data.numPlayers + 1
		
		return game
	else
		casino:ChatHelp (playerName)
	end
end
