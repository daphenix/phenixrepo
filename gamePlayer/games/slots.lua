--[[
	Slots Client for Casino
]]

gamePlayer.games.slots = {}
gamePlayer.games.slots.version = "0.6"
gamePlayer.games.slots.name = "Slots"
gamePlayer.games.slots.gameName = "slots"
gamePlayer.games.slots.isPlayable = true
gamePlayer.games.slots.isCasinoGame = true
gamePlayer.games.slots.soundDir = "slots/"

local sounds = {
	{name="start", length=2000},
	{name="play", length=10000},
	{name="win", length=2000}
}

-- Game UI
local function SlotsGame (game)
	local balance = iup.label {title = "0c", font = gamePlayer.ui.font, expand = "YES"}
	local result = iup.label {title="", font=gamePlayer.ui.font, expand ="YES"}
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
	
	-- Radio group for token size
	local tokens = {
		["1c"] = iup.stationradio {title="1c", font=gamePlayer.ui.font, token=1},
		["10c"] = iup.stationradio {title="10c", font=gamePlayer.ui.font, token=10},
		["100c"] = iup.stationradio {title="100c", font=gamePlayer.ui.font, token=100},
		["1000c"] = iup.stationradio {title="1000c", font=gamePlayer.ui.font, token=1000},
		["10000c"] = iup.stationradio {title="10kc", font=gamePlayer.ui.font, token=10000},
		["100000c"] = iup.stationradio {title="100kc", font=gamePlayer.ui.font, token=100000},
		["1000000c"] = iup.stationradio {title="1Mc", font=gamePlayer.ui.font, token=1000000}
	}
	local tokenSize = iup.radio {
		iup.vbox {
			tokens ["1c"],
			tokens ["10c"],
			tokens ["100c"],
			tokens ["1000c"],
			tokens ["10000c"],
			tokens ["100000c"],
			tokens ["1000000c"];
			expand = "YES"
		},
		value=tokens ["1c"]
	}

	local function GetTokenValue ()
		return tokenSize.value.token
	end
	local currentToken = 1

	local content = iup.hbox {
		iup.fill {size=5},
		iup.vbox {
			iup.fill {size = 5},
			iup.label {title="Slots Game"},
			iup.fill {size = 10},
			game.ui:GetBalanceBar (),
			iup.fill {size = 25},
			iup.hbox {
				iup.vbox {
					iup.label {title="Token Value", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
					iup.fill {size=10},
					tokenSize;
					expand="YES"
				},
				iup.fill {size=25},
				iup.vbox {
					iup.hbox {
						iup.label {title="Result: ", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
						result;
						expand="YES"
					},
					iup.fill {size = 10},
					iup.label {title="Info:", font=gamePlayer.ui.font, fgcolor=gamePlayer.ui.fgcolor},
					info;
					expand="YES"
				};
				expand="YES"
			},
			iup.fill {size = 25},
			iup.hbox {
				iup.fill {},
				game.ui:GetPlayButton (),
				game.ui:GetBalanceButton (),
				game.ui:GetQuitButton ();
				expand = "YES"
			};
			expand = "YES"
		},
		iup.fill {size=5};
		expand="YES"
	}
	
	function game.ui:Initialize ()
		gamePlayer:LoadSounds (game, sounds)
	end
	
	function game.ui:Start ()
		result.title = ""
		info.value = ""
		iup.Refresh (content)
		gamePlayer:SendCasinoMessage ("play slots")
	end
	
	function game.ui:Win (data)
		gamePlayer:PlaySound (game, "win", function () gamePlayer:SendCasinoMessage ("balance") end)
	end
	
	function game.ui:Lose (data)
		gamePlayer:SendCasinoMessage ("balance")
	end
	
	local fplay = game.ui.Play
	function game.ui:Play ()
		if currentToken ~= GetTokenValue () then
			currentToken = GetTokenValue ()
			gamePlayer:SendCasinoMessage (string.format ("token %d", currentToken))
		end
		fplay ()
	end
	
	function game.ui:Parse (data)
		local s = data:lower ()
		if string.find (s, "result") then
			local r = string.match (data, "Result: (.+)")
			result.title = r
			iup.Refresh (result)
		elseif not string.find (s, "spin") and not string.find (s, "balance") then
			info.value = info.value .. "\n" .. data
			iup.Refresh (info)
		end
	end
	
	return content
end

function gamePlayer.games.slots.CreateGameContent (launcher, game)
	game.ui = gamePlayer.games:CreateBasicUI (launcher, game)
	game.ui:SetMainContent (SlotsGame (game))
end