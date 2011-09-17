--[[
	Games modules installed
]]

gamePlayer.games = {}

-- All games installable (order here defines the order of their launch buttons)
dofile ("games/bank_account.lua")
dofile ("games/slots.lua")

gamePlayer.games.gamesList = {}

function gamePlayer.games:SetupGames ()
	-- Define list of games available
	local game
	gamePlayer.games.gamesList = {}
	for _, game in pairs (gamePlayer.games) do
		if type (game) == "table" and game.isPlayable then
			table.insert (gamePlayer.games.gamesList, game)
		end
	end
end

function gamePlayer.games:CreateBasicUI (launcher, game)
	local content = iup.vbox {}
	local playButton = iup.stationbutton {title="Play", font=gamePlayer.ui.font}
	local betButton = iup.stationbutton {title="Bet", font=gamePlayer.ui.font}
	local quitButton = iup.stationbutton {title="Quit", font=gamePlayer.ui.font}
	local balance, transaction, balanceButton, depositButton, withdrawButton, closeAcctButton
	local hasAccount = false
	
	function content:SetMainContent (ui)
		iup.Append (content, ui)
	end
	
	function content:EnableButtons (flag)
		if flag then flag = "YES"
		else flag = "NO"
		end
		playButton.active = "NO"
		betButton.active = "NO"
		if balanceButton then balanceButton.active = "NO" end
		if withdrawButton then withdrawButton.active = "NO" end
		if closeAcctButton then closeAcctButton.active = "NO" end
		if hasAccount then
			playButton.active = flag
			betButton.active = flag
			if balanceButton then balanceButton.active = flag end
			if withdrawButton then withdrawButton.active = flag end
			if closeAcctButton then closeAcctButton.active = flag end
		end
		quitButton.active = flag
		content:SetButtonState (flag)
	end
	
	-- Process response returned from Casino server.  No need to use if standalone game
	function content:ProcessResponse (data)
		if (hasAccount or balance) and string.find (data:lower (), "balance") then
			content:GetDepositButton ().title = "Deposit Money"
			local acct = string.match (data, "Current Balance: (%d+)") or "0"
			balance.title = acct .. "c"
			hasAccount = true
			iup.Refresh (balance)
		elseif string.find (data:lower (), "win") then
			content:Win (data)
		elseif string.find (data:lower (), "lose") then
			content:Lose (data)
		end
		content:Parse (data)
		content:EnableButtons (true)
	end
	
	-- It is strongly advised not to override this function unless highly understood
	-- Override if standalone game
	function content:Play ()
		content:EnableButtons (false)
		gamePlayer:PlaySound (game, "play", function ()
			if game.isCasinoGame then
				gamePlayer:SendCasinoMessage ("play")
			end
		end)
	end
	
	function content:Bet (amt)
		content:EnableButtons (false)
		gamePlayer:PlaySound (game, "bet", function () gamePlayer:SendCasinoMessage (string.format ("bet %d", amt)) end)
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
	
	function content:GetQuitButton ()
		return quitButton
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
		content:Bet ()
	end
	
	function quitButton.action ()
		content:Quit ()
	end
	
	-- Override these functions per game requirements
	-- They should be overridden with game.ui:FunctionName
	
	-- Called to set the state of any game specific buttons
	function content:SetButtonState (flag) end
	
	-- Called when the game instance is first created.  This is done one time only
	function content:Initialize () end
	
	-- Called each time the game is started
	function content:Start () end
	
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