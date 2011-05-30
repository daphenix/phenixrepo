--[[
	Options Control UI
]]
dofile ("ui/statsTab.lua")
dofile ("ui/bankTab.lua")
dofile ("ui/gameTab.lua")
dofile ("ui/waitQueueTab.lua")
dofile ("ui/bannedTab.lua")
dofile ("ui/gameConfigTab.lua")
dofile ("ui/adTab.lua")
	
-- Define local popup for banning players
-- Done here because it's shared across multiple screens 
function casino.ui:GetBanPlayerPopup (name, tab, bannedTab)
	local playerName = iup.text {value = name, size="150x"}
	local reason = iup.text {value = "", size="250x"}
	local banButton = iup.stationbutton {title="Ban", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}

	local banPlayerPopup = iup.dialog {
		iup.pdarootframe {
			iup.vbox {
				iup.hbox {
					iup.fill {size = 5},
					iup.label {title="Player Name: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					playerName,
					iup.fill {size=5};
					expand = "HORIZONTAL"
				},
				iup.fill {size=5},
				iup.hbox {
					iup.fill {size=5},
					iup.label {title="Reason for Ban: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					reason,
					iup.fill {size=5};
					expand = "HORIZONTAL"
				},
				iup.fill {size=15},
				iup.hbox {
					iup.fill {},
					banButton,
					cancelButton;
					expand = "HORIZONTAL"
				};
			};
		},
	    font = casino.ui.font,
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
		bgcolor = casino.ui.bgcolor,
		defaultesc = cancelButton
	}
	
	function banButton:action ()
		HideDialog (banPlayerPopup)
		banPlayerPopup.active = "NO"
		casino:DoBan (playerName.value, reason.value)
		tab:ReloadData ()
		if bannedTab then bannedTab:ReloadData () end
	end
	
	function cancelButton:action ()
		HideDialog (banPlayerPopup)
		banPlayerPopup.active = "NO"
	end
	
	return banPlayerPopup
end

function casino.ui:CreatePdaUI ()
	local saveButton = iup.stationbutton { title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton { title="Cancel", font=casino.ui.font}
	
	-- Build basic control box
	local casinoName = iup.text {value = casino.data.name, size = "200x"}
	local debugToggle = iup.stationtoggle {title="  Use Debug Mode?", fgcolor=casino.ui.fgcolor}
	local activateButton = iup.stationbutton {title="Start", font=casino.ui.font}
	local resetButton = iup.stationbutton {title = "Reset", font = casino.ui.font}
	local statusLabel = iup.label {title = "", font=casino.ui.font, size = "150x"}
	local maxGameLimit = iup.text {value = "", size = "40x"}
	local currentPlayers = iup.label {title = tostring (casino.data.numPlayers), fgcolor=casino.ui.fgcolor, font=casino.ui.font}
	local currentTime = iup.label {title = os.date (), fgcolor=casino.ui.fgcolor, font=casino.ui.font}
	
	local function SetCasinoStatus ()
		if casino.data.tablesOpen then
			statusLabel.title = "Open"
			statusLabel.fgcolor = casino.ui.okaycolor
			activateButton.title = "Stop"
		else
			statusLabel.title = "Closed"
			statusLabel.fgcolor = casino.ui.alertcolor
			activateButton.title = "Start"
		end
	end
	
	local function SetCasinoData ()
		currentPlayers.title = tostring (casino.data.numPlayers)
		currentTime.title = os.date ()
	end
	
	local function SetPlayerLimit ()
		maxGameLimit.value = tostring (casino.data.maxPlayers)
	end
	
	local status = iup.hbox {
		iup.label {title = "Status: ", fgcolor=casino.ui.fgcolor, font=casino.ui.font},
		statusLabel,
		iup.fill {},
		debugToggle,
		iup.fill {size=10},
		activateButton,
		resetButton;
		expand = "YES"
	}
	
	local gameData = iup.hbox {
		iup.label {title = "Maximum Players: ", fgcolor=casino.ui.fgcolor, font=casino.ui.font},
		maxGameLimit,
		iup.fill {size = 50},
		iup.label {title = "Current Players: ", fgcolor=casino.ui.fgcolor, font=casino.ui.font},
		currentPlayers,
		iup.fill {},
		iup.label {title = "Date: ", fgcolor=casino.ui.fgcolor, font=casino.ui.font},
		currentTime;
		expand = "HORIZONTAL"
	}
	
	function activateButton.action ()
		if casino.data.tablesOpen then
			casino:CloseTables ()
		else
			casino:OpenTables ({"", tostring (debugToggle.value == "ON")})
		end
		SetCasinoStatus ()
	end
	
	function resetButton.action ()
		casino:Reset ()
	end
	
	-- Set up tabs
	local bannedTab = casino.ui:CreateBannedTab ()
	local statsTab = casino.ui:CreateStatsTab ()
	local bankTab = casino.ui:CreateBankTab ()
	local gameTab = casino.ui:CreateGameTab (bannedTab)
	local waitQueueTab = casino.ui:CreateWaitQueueTab (bannedTab)
	local configTab = casino.ui:CreateGameConfigTab ()
	local adTab = casino.ui:CreateAdTab ()
	
	-- Assemble Tab Frame
	local tabframe = iup.roottabtemplate {
		statsTab,
		bankTab,
		gameTab,
		waitQueueTab,
		bannedTab,
		configTab,
		adTab;
		expand = "YES"
	}
	
	local pda = iup.vbox {
		iup.label {title = "Casino Settings v" .. casino.version, font=casino.ui.font},
		iup.fill {size = 15},
		iup.hbox {
			iup.label {title = "Casino Name: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
			casinoName;
		},
		iup.fill {size = 15},
		status,
		iup.fill {size = 5},
		gameData,
		iup.fill {size = 5},
		tabframe,
		iup.fill {},
		iup.hbox {
			iup.fill {},
			saveButton,
			cancelButton; };
	}
	
	function pda:ReloadData ()
		SetCasinoStatus ()
		SetCasinoData ()
		statsTab:ReloadData ()
		bankTab:ReloadData ()
		gameTab:ReloadData ()
		waitQueueTab:ReloadData ()
		bannedTab:ReloadData ()
		iup.Refresh (pda)
	end
	
	function pda:GetCasinoName ()
		return casinoName.value
	end
	
	function pda:GetPlayerLimit ()
		return tonumber (maxGameLimit.value)
	end
	
	function pda:DoSave ()
		casino.data.name = pda:GetCasinoName ()
		casino.data.maxPlayers = pda:GetPlayerLimit ()
		adTab:DoSave ()
		casino.data:SaveUserSettings ()
	end
	
	function pda:DoCancel ()
		casino.data:LoadUserSettings ()
		pda:ReloadData ()
		SetPlayerLimit ()
	end
	
	function pda:GetSaveButton ()
		return saveButton
	end
	
	function pda:GetCancelButton ()
		return cancelButton
	end
	
	function saveButton.action ()
		pda:DoSave ()
	end
	
	function cancelButton.action ()
		pda:DoCancel ()
	end
	
	-- Initialize Fields
	SetCasinoStatus ()
	SetPlayerLimit ()
	
	return pda
end

function casino.ui:CreateSettingsUI ()
	local pda = casino.ui:CreatePdaUI ();
	
	local frame = iup.dialog {
		iup.pdarootframe {
			pda;
		},
	    font = casino.ui.font,
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
		bgcolor = casino.ui.bgcolor,
		defaultesc = pda:GetCancelButton ()
	}
	
	-- Set up Refresh Thread
	-- Keep an eye on this.  Not sure if may be a cause for a future memory leak
	local function RunRefresh ()
		Timer ():SetTimeout (casino.data.refreshDelay, function ()
			pda:ReloadData ()
			if frame.active == "YES" then
				RunRefresh ()
			end
		end)
	end
	
	pda:GetSaveButton ().action = function ()
		pda:DoSave ()
		HideDialog (frame)
		frame.active = "YES"
	end
	
	pda:GetCancelButton ().action = function ()
		pda:DoCancel ()
		HideDialog (frame)
		frame.active = "NO"
	end
	RunRefresh ()
	
	return frame
end