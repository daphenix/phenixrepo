--[[
	Blackjack Client
]]

gamePlayer.games.blackjack = {}
gamePlayer.games.blackjack.version = "0.6"
gamePlayer.games.blackjack.name = "Blackjack"
gamePlayer.games.blackjack.gameName = "blackjack"
gamePlayer.games.blackjack.isPlayable = true  -- true to cause game plugin to load a startup button in launcher
gamePlayer.games.blackjack.isCasinoGame = true  -- true if interacting with Casino plugin
gamePlayer.games.blackjack.soundDir = "blackjack/"

-- List all used sounds here
local sounds = {
	{name="start", length=3500},
	{name="bet", length=3400},
	{name="play", length=1000},
	{name="hit", length=600},
	{name="win", length=5200}
}

-- Game UI
local function Blackjack (game)
	local hitButton = iup.stationbutton {title="Hit", font=gamePlayer.ui.font, active="NO"}
	local stayButton = iup.stationbutton {title="Stay", font=gamePlayer.ui.font, active="NO"}
	--local dealerHand = iup.label {title="", font=gamePlayer.ui.font}
	local dealerHand = iup.hbox {}
	local dealerTotal = iup.label {title="", font=gamePlayer.ui.font, size="35x"}
	--local playerHand = iup.label {title="", font=gamePlayer.ui.font}
	local playerHand = iup.hbox {}
	local playerTotal = iup.label {title="", font=gamePlayer.ui.font, size="35x"}
	local info = iup.multiline {
		size = "600x175",
		scrollbar = "NO",
		active = "NO",
		expand = "YES",
		border = "NO",
		boxcolor = "0 0 0",
		readonly = "YES",
		font = gamePlayer.ui.font
	}
	local ui = game.ui
	local startedPlay = false

	-- Generate the GUI for the game
	local content = iup.hbox {
		iup.fill {size=5},
		iup.vbox {
			iup.fill {size=5},
			iup.label {title="Blackjack"},
			iup.fill {size = 10},
			game.ui:GetBalanceBar (),
			iup.fill {size = 25},
			iup.hbox {
				iup.label {title="Bet: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
				ui:GetBetText ();
				expand = "YES"
			},
			iup.fill {size=10},
			iup.hbox {
				iup.label {title="Dealer Hand: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
				dealerHand,
				iup.fill {},
				iup.label {title="Total: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
				dealerTotal;
				expand = "YES"
			},
			iup.hbox {
				iup.label {title="Player Hand: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
				playerHand,
				iup.fill {},
				iup.label {title="Total: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
				playerTotal;
				expand = "YES"
			},
			iup.fill {size = 10},
			iup.label {title = "Information:", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
			info,
			iup.hbox {
				iup.fill {},
				ui:GetBetButton (),
				ui:GetPlayButton (),
				hitButton,
				stayButton,
				ui:GetBalanceButton (),
				ui:GetQuitButton ();
				expand = "YES"
			};
			expand = "YES"
		},
		iup.fill {size=5};
		expand="YES"
	}
	
	local function ClearDisplays ()
		--dealerHand.title = ""
		dealerHand = iup.hbox {}
		dealerTotal.title = ""
		--playerHand.title = ""
		playerHand = iup.hbox {}
		playerTotal.title = ""
	end
	
	function ui:SetButtonState (hasAccount)
		hitButton.active = "NO"
		stayButton.active = "NO"
	end
	
	function ui:Initialize ()
		gamePlayer:LoadSounds (game, sounds)
		ui.state ["bet"] = {
			active = {ui:GetBetButton ()},
			inactive = {hitButton, stayButton},
			exitTest = function ()
				if string.find (ui.lastResponse, "Your bet of %d+c has been registered") then return true
				else return false
				end
			end
		}
		ui.state ["play"] = {
			active = {
				ui:GetPlayButton (),
				function ()
					ClearDisplays ()
				end
			}
		}
		ui.state ["hit"] = {active={hitButton, stayButton}}
	end
	
	function ui:Start ()
		ClearDisplays ()
		info.value = ""
		iup.Refresh (content)
		gamePlayer:SendCasinoMessage ("play blackjack")
	end
	
	local fPlay = ui.Play
	function ui:Play ()
		if not startedPlay then
			ui.nextState = "hit"
			fPlay ()
			startedPlay = true
		end
	end
	
	function ui:Parse (data)
		local s = data:lower ()
		
		-- Check for Push
		if string.find (s, "pushes") then
			ui.nextState = "bet"
		end
		
		-- Play Responses
		if string.find (s, "dealer hand") then
			local r, t
			if string.find (s, "=") then
				r, t = string.match (data, "Dealer Hand: (.+) = (%d+)")
			else
				r, t = string.match (data, "Dealer Hand: (.+)")
			end
			dealerHand.title = r
			dealerTotal.title = t
			iup.Refresh (dealerHand)
		elseif string.find (s, "player hand") then
			local r, t = string.match (data, "Player Hand: (.+) = (%d+)")
			playerHand.title = r
			playerTotal.title = t
			iup.Refresh (playerHand)
		elseif not string.find (s, "dealer hand") and not string.find (s, "player hand") and not string.find (s, "balance") then
			info.value = info.value .. "\n" .. data
			iup.Refresh (info)
		end
	end
	
	function ui:Win (data)
		startedPlay = false
		gamePlayer:PlaySound (game, "win", function ()
			gamePlayer:SendCasinoMessage ("balance")
		end)
	end
	
	function ui:Lose (data)
		startedPlay = false
		gamePlayer:SendCasinoMessage ("balance")
	end
	
	function hitButton.action ()
		gamePlayer:PlaySound (game, "hit", function ()
			gamePlayer:SendCasinoMessage ("hit")
		end)
	end
	
	function stayButton.action ()
		gamePlayer:SendCasinoMessage ("stay")
	end
	
	return content
end

function gamePlayer.games.blackjack.CreateGameContent (launcher, game)
	game.ui = gamePlayer.games:CreateBasicUI (launcher, game)
	game.ui:SetMainContent (Blackjack (game))
end