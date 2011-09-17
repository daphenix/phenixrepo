--[[
	Player Bank Account Management
]]

gamePlayer.games.bankaccount = {}
gamePlayer.games.bankaccount.version = "0.5"
gamePlayer.games.bankaccount.name = "Bank Account"
gamePlayer.games.bankaccount.isPlayable = true
gamePlayer.games.bankaccount.isCasinoGame = true
gamePlayer.games.bankaccount.soundDir = "bankaccount/"

-- List all used sounds here
local sounds = {
	{name="start", length=700, volume=0.5}
}

-- Game UI
local function BankAccount (launcher, game)
	local quitButton = game.ui:GetQuitButton ()
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
	
	-- Generate the GUI
	local depositButton = game.ui:GetDepositButton ()
	depositButton.expand = "HORIZONTAL"
	local withdrawButton = game.ui:GetWithdrawButton ()
	withdrawButton.expand = "HORIZONTAL"
	local balanceButton = game.ui:GetBalanceButton ()
	balanceButton.expand = "HORIZONTAL"
	local closeAcctButton = game.ui:GetCloseAcctButton ()
	closeAcctButton.expand = "HORIZONTAL"
	local ui = iup.hbox {
		iup.fill {size=5},
		iup.vbox {
			iup.fill {size = 5},
			iup.label {title="Casino Bank"},
			iup.fill {size = 10},
			game.ui:GetBalanceBar (),
			iup.hbox {
				game.ui:GetTransactionBar (),
				iup.fill {size = 200},
				iup.vbox {
					iup.hbox {
						depositButton,
						withdrawButton;
					},
					iup.hbox {
						balanceButton,
						closeAcctButton;
					};
				};
				expand = "YES"
			},
			iup.fill {size = 10},
			iup.label {title = "Information:", font = gamePlayer.ui.font, fgcolor = gamePlayer.ui.fgcolor},
			info,
			iup.fill {size = 10},
			iup.hbox {
				iup.fill {},
				quitButton;
				expand = "YES"
			};
			expand = "YES"
		},
		iup.fill {size=5};
		expand="YES"
	}
	
	function game.ui:Parse (data)
		local s = data:lower ()
		if not string.find (s, "balance") then
			info.value = info.value .. "\n" .. data
			iup.Refresh (info)
		end
	end
	
	function game.ui:Initialize ()
		gamePlayer:LoadSounds (game, sounds)
	end
	
	function quitButton.action ()
		launcher:StartLauncher ()
	end
	
	return ui
end

function gamePlayer.games.bankaccount.CreateGameContent (launcher, game)
	game.ui = gamePlayer.games:CreateBasicUI (launcher, game)
	game.ui:SetMainContent (BankAccount (launcher, game))
end