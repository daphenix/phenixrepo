--[[
	Games modules installed
]]

gamePlayer.games = {}

dofile ("games/deck.lua")

-- All games installable (order here defines the order of their launch buttons)
dofile ("games/bank_account.lua")
dofile ("games/slots.lua")
dofile ("games/blackjack.lua")

gamePlayer.games.gamesList = {}

function gamePlayer.games:SetupGames ()
	-- Define list of games available
	local game
	gamePlayer.games.gamesList = {}
	for _, game in pairs (gamePlayer.games) do
		if type (game) == "table" and game.isPlayable then
			table.insert (gamePlayer.games.gamesList, game)
		end
		table.sort (gamePlayer.games.gamesList, function (a, b)
			if a.name == "Bank Account" then return true
			elseif b.name == "Bank Account" then return false
			else return a.name < b.name
			end
		end)
	end
end

function gamePlayer.games:CreateBasicUI (launcher, game)
	local content = iup.vbox {}
	content.currentState = nil
	content.nextState = nil
	content.lastResponse = ""
	
	local playButton = iup.stationbutton {title="Play", font=gamePlayer.ui.font, active="NO"}
	local betButton = iup.stationbutton {title="Bet", font=gamePlayer.ui.font}
	local betText = iup.text {value="", size="75x"}
	local quitButton = iup.stationbutton {title="Quit", font=gamePlayer.ui.font}
	local helpButton = iup.stationbutton {title="Help", font=gamePlayer.ui.font}
	local balance, transaction, balanceButton, depositButton, withdrawButton, closeAcctButton
	local hasAccount = false
	local betMade = false
	local startedPlay = false
	
	function content:SetInitialState ()
		betMade = false
		startedPlay = false
	end
	
	function content:SetMainContent (ui)
		iup.Append (content, ui)
	end
	
	--
	--	state engine properties
	--
	--	active = the list of items to activate.  If one is a function, call that function with the settable state
	--	inactive = the list of items to deactivate, call if function
	--	entranceTest = if present, this function must return true in order to proceed to the desired set state
	--	exitTest = if present, this function must return true in order to leave the current state
	--
	content.state = {
		["start"] = {active={}},
		["bet"] = {active={betButton}},
		["play"] = {active={playButton}},
		["win"] = {active={}},
		["lose"] = {active={}}
	}
	
	function content:DisableButtons ()
		playButton.active = "NO"
		betButton.active = "NO"
		if balanceButton then balanceButton.active = "NO" end
		if withdrawButton then withdrawButton.active = "NO" end
		if closeAcctButton then closeAcctButton.active = "NO" end
		content:DisableGameButtons (hasAccount)
	end
	
	function content:SetState (state)
		content:DisableButtons ()
		if hasAccount then
			if balanceButton then balanceButton.active = "YES" end
			if withdrawButton then withdrawButton.active = "YES" end
			if closeAcctButton then closeAcctButton.active = "YES" end
		end
		if not content.currentState or not content.state [content.currentState].exitTest or content.state [content.currentState].exitTest () then
			if content.state [state] and (not content.state [state].entranceTest or content.state [state].entranceTest ()) then
				content.currentState = state
			end
		end
		if content.state [content.currentState] then
			local item
			if content.state [content.currentState].active then
				for _, item in ipairs (content.state [content.currentState].active) do
					if type (item) == "function" then
						item (content.currentState)
					else
						item.active = "YES"
					end
				end
			end
			if content.state [content.currentState].inactive then
				for _, item in ipairs (content.state [content.currentState].inactive) do
					if type (item) == "function" then
						item (content.currentState)
					else
						item.active = "NO"
					end
				end
			end
		end
	end
	
	-- Process response returned from Casino server.  No need to use if standalone game
	function content:ProcessResponse (data)
		content.lastResponse = data
		if (hasAccount or balance) and string.find (data:lower (), "balance") then
			content:GetDepositButton ().title = "Deposit Money"
			local acct = string.match (data, "Current Balance: (%d+)") or "0"
			balance.title = acct .. "c"
			hasAccount = true
			iup.Refresh (balance)
		elseif string.find (data:lower (), "win") then
			content:SetState ("win")
			content:Win (data)
			content.nextState = "bet"
		elseif string.find (data:lower (), "lose") then
			content:SetState ("lose")
			content:Lose (data)
			content.nextState = "bet"
		end
		content:Parse (data)
		if content.nextState ~= content.currentState then
			content:SetState (content.nextState)
		else
			content:SetState (content.currentState)
		end
	end
	
	-- It is strongly advised not to override this function unless highly understood
	-- Override if standalone game
	function content:Play ()
		content:DisableButtons ()
		gamePlayer:PlaySound (game, "play", function ()
			if game.isCasinoGame then
				gamePlayer:SendCasinoMessage ("play")
			end
		end)
	end
	
	function content:Bet (amt)
		if tonumber (betText.value) then
			content:DisableButtons ()
			gamePlayer:PlaySound (game, "bet", function ()
				content.nextState = "play"
				if game.isCasinoGame then
					gamePlayer:SendCasinoMessage (string.format ("bet %d", amt))
				end
			end)
		end
	end
	
	function content:Quit ()
		content:Stop ()
		if game.isCasinoGame then
			gamePlayer:SendCasinoMessage ("quit")
		end
		launcher:StartLauncher ()
	end
	
	function content:GetPlayButton ()
		return playButton
	end
	
	function content:GetBetButton ()
		return betButton
	end
	
	function content:GetBetText ()
		return betText
	end
	
	function content:GetBetValue ()
		return tonumber (betText.value)
	end
	
	function content:SetBetValue (amt)
		betText.value = amt
	end
	
	function content:GetQuitButton ()
		return quitButton
	end
	
	function content:GetHelpButton ()
		return helpButton
	end
	
	function content:GetBalance ()
		if not balance then
			balance = iup.label {title = "No Account", font = gamePlayer.ui.font, expand = "YES"}
		end
		
		return balance
	end
	
	function content:GetBalanceValue ()
		if balance then
			return tonumber (string.match (balance.title, "(%d+)c")) or 0
		else
			return 0
		end
	end
	
	function content:GetBalanceButton ()
		if not balanceButton then
			balanceButton = iup.stationbutton {title="Get Balance", font=gamePlayer.ui.font, action=function () gamePlayer:SendCasinoMessage ("balance") end}
		end
		return balanceButton
	end
	
	function content:GetBalanceBar ()
		content:GetBalance ()
		return iup.hbox {
				iup.label {title = "Current Balance: ", font = gamePlayer.ui.font, fgcolor = gamePlayer.ui.fgcolor},
				balance;
				expand = "YES"
			}
	end
	
	function content:GetDepositButton ()
		if not depositButton then
			depositButton = iup.stationbutton {title="Open Account", font=gamePlayer.ui.font}
			function depositButton.action ()
				-- Check if Casino is in the same sector as player
				if gamePlayer:IsPlayerInSector (gamePlayer.data.casinoName) then
					local amt = tonumber (transaction.value) or 0
					if amt > 0 then
						GiveMoney (gamePlayer.data.casinoName, amt)
						gamePlayer:SendCasinoMessage ("balance")
					end
				end
			end
		end
		return depositButton
	end
	
	function content:GetTransactionBar ()
		if not transaction then
			transaction = iup.text {value = "", font = gamePlayer.ui.font, size = "75x"}
		end
		return iup.hbox {
			iup.label {title = "Transaction Amount: ", font = gamePlayer.ui.font, fgcolor = gamePlayer.ui.fgcolor},
			transaction;
			expand = "YES"
		}
	end
	
	function content:GetWithdrawButton ()
		if not withdrawButton then
			withdrawButton = iup.stationbutton {title="Withdraw", font=gamePlayer.ui.font}
			function withdrawButton.action ()
				-- Check if Casino is in the same sector as player
				if gamePlayer:IsPlayerInSector (gamePlayer.data.casinoName) then
					local amt = tonumber (transaction.value) or 0
					if amt > 0 then
						gamePlayer:SendCasinoMessage ("withdraw " .. tostring (amt))
					end
				end
			end
		end
		return withdrawButton
	end
	
	function content:GetCloseAcctButton ()
		if not closeAcctButton then
			closeAcctButton = iup.stationbutton {title = "Close Account", font = gamePlayer.ui.font}
			function closeAcctButton.action ()
				gamePlayer:SendCasinoMessage ("close")
			end
		end
		return closeAcctButton
	end
	
	function playButton.action ()
		content:Play ()
	end
	
	function betButton.action ()
		content:Bet (tonumber (betText.value))
	end
	
	function quitButton.action ()
		content:Quit ()
	end
	
	function helpButton.action ()
		if game.isCasinoGame then
			gamePlayer:SendCasinoMessage ("help")
		end
		content:Help ()
	end
	
	-- Override these functions per game requirements
	-- They should be overridden with game.ui:FunctionName
	
	-- Called to set the state of any game specific buttons
	function content:DisableGameButtons (hasAccount) end
	
	-- Called when the game instance is first created.  This is done one time only
	function content:Initialize () end
	
	-- Called each time the game is started
	function content:Start () end
	
	-- Called for local game help
	function content:Help () end
	
	-- Used to handle inbound data from the server
	function content:Parse (data) end
	
	-- Called when the player wins
	function content:Win (data) end
	
	-- Called when the player loses
	function content:Lose (data) end
	
	-- Called each time the player quits the game and leaves the game player or simply returns to the Launcher
	function content:Stop () end
	
	-- Called when the gamePlayer exits.  Used for any clean up required of resources used by the game
	function content:Shutdown () end
	
	return content
end

function gamePlayer.games:CreateGameUI (launcher, game)
	local gui = game.CreateGameContent or gamePlayer.games.frontend.CreateGameContent
	gui (launcher, game)
	game.ui:Initialize ()
	
	local button = iup.stationbutton {
		title = game.name,
		size = "150x",
		font = gamePlayer.ui.font,
		action = function ()
			launcher:StartGame (game)
		end
	}
	iup.Append (launcher, game.ui)
	
	return button
end