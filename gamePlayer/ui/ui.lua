--[[
	UI Elements
]]
gamePlayer.ui = {}
gamePlayer.ui.font = 14 * (gkinterface.GetYResolution () / 600)
gamePlayer.ui.fontSmall = 10 * (gkinterface.GetYResolution () / 600)
gamePlayer.ui.bgcolor = "255 10 10 10*"
gamePlayer.ui.highlight = "255 150 150 150*"
gamePlayer.ui.fgcolor = "200 200 50"
gamePlayer.ui.alertcolor = "200 50 50"
gamePlayer.ui.okaycolor = "50 200 50"

function gamePlayer.ui:GetOnOffSetting (flag)
	if (flag) then
		return "ON"
	else
		return "OFF"
	end
end
dofile ("ui/pda.lua")

function gamePlayer.ui:CreateLauncherUI ()
	-- Basic Controls
	local quitButton = iup.stationbutton {title="Leave Casino", font=gamePlayer.ui.font}

	-- Row Width.  The number of buttons in a rows
	local rowWidth = 4
	
	-- Build Launcher root
	local launcher = iup.zbox {
		iup.fill {};
		alignment = "ACENTER"
	}
	-- Setup holder for buttons
	local casinoName = iup.text {value = gamePlayer.data.casinoName, font = gamePlayer.ui.font, size = "200x"}
	local topPage = iup.vbox {
		iup.label {title = "Play Casino Games", align = "ACENTER", expand = "HORIZONTAL"},
		iup.fill {size = 10},
		iup.hbox {
			iup.fill {size = 5},
			iup.label {title = "Connect to Casino: ", font = gamePlayer.ui.font, fgcolor = gamePlayer.ui.fgcolor},
			casinoName,
			iup.fill {size = 5};
			expand = "YES"
		},
		iup.fill {size = 25};
		expand = "YES"
	}
	
	function launcher:StartLauncher ()
		if gamePlayer.data.activeGame.isCasinoGame then
			UnregisterEvent (gamePlayer.data, "CHAT_MSG_PRIVATE")
		end
		launcher.value = topPage
		gamePlayer.data.activeGame = nil
	end
	
	function launcher:StartGame (game)
		gamePlayer.data.casinoName = casinoName.value
		gamePlayer.data.activeGame = game
		if game.isCasinoGame then
			RegisterEvent (gamePlayer.data, "CHAT_MSG_PRIVATE")
			gamePlayer:SendCasinoMessage ("balance")
		end
		launcher.value = game.ui
		gamePlayer:PlaySound (game, "start", function ()
			game.ui.nextState = "bet"
			game.ui:Start ()
		end)
	end
	
	-- Loop through all the discovered games and add buttons for their configurations
	local k, game, button, rowPanel
	local index = 1
	for k, game in ipairs (gamePlayer.games.gamesList) do
		button = gamePlayer.games:CreateGameUI (launcher, game)
		if index % rowWidth == 1 then
			rowPanel = iup.hbox {iup.fill {size = 5}, button, iup.fill {size = 5}, expand = "YES"}
		else
			iup.Append (rowPanel, button)
			iup.Append (rowPanel, iup.fill {size = 5})
		end
		if index % rowWidth == 0 then
			iup.Append (topPage, rowPanel)
			rowPanel = nil
		end
			index = index + 1
	end
	if rowPanel then
		iup.Append (topPage, rowPanel)
	end
	iup.Append (topPage, iup.fill {})
	iup.Append (topPage, iup.hbox {
					iup.fill {},
					quitButton;
					expand = "YES"
				})
	iup.Append (launcher, topPage)
	
	local frame = iup.dialog {
		iup.pdasubsubframebg {
			iup.vbox {
				launcher;
				expand = "YES"
			};
		},
	    font = gamePlayer.ui.font,
		border = 'YES',
		topmost = 'YES',
		resize = 'YES',
		maxbox = 'NO',
		minbox = 'NO',
		modal = 'NO',
		fullscreen = 'NO',
		expand = 'YES',
		active = 'NO',
		menubox = 'NO',
		bgcolor = gamePlayer.ui.bgcolor,
		defaultesc = quitButton
	}
	
	function quitButton.action ()
		-- Shut down any active game
		if launcher.value ~= topPage then
			launcher.value:Stop ()
		end
		
		-- Shutdown all utilized resources on all games
		for _, game in ipairs (gamePlayer.games.gamesList) do
			game.ui:Shutdown ()
		end
		
		-- Hide main dialog
		messaging:Stop (gamePlayer)
		HideDialog (frame)
		frame.active = "NO"
		gamePlayer.data.activeGame = nil
		gamePlayer.data.isActive = false
	end
	
	messaging:Start (gamePlayer)
	launcher.value = topPage
	ShowDialog (frame, iup.CENTER, iup.CENTER)
	frame.active = "YES"
	gamePlayer.data.isActive = true
	gamePlayer:PlayAmbiance ()
end
