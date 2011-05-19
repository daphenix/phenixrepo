--[[
	Options Control UI
]]
dofile ("ui/statsTab.lua")
dofile ("ui/bankTab.lua")
dofile ("ui/gameTab.lua")
dofile ("ui/waitQueueTab.lua")
dofile ("ui/bannedTab.lua")
	
-- Define local popup for banning players
-- Done here because it's shared across multiple screens 
function casino.ui:GetBanPlayerPopup (name, tab, bannedTab)
	local playerName = iup.text {value = name, size="150x"}
	local reason = iup.text {value = "", size="250x"}
	local banButton = iup.stationbutton {title="Ban", font=casino.ui.font}
	local cancelButton = iup.stationbutton {title="Cancel", font=casino.ui.font}

	local frame = iup.dialog {
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
		bgcolor = "255 10 10 10 *",
		defaultesc = cancelButton
	}
	
	function banButton:action ()
		casino.data.bannedList [playerName.value] = reason.value
		HideDialog (frame)
		frame.active = "NO"
		tab:ReloadData ()
		bannedTab:ReloadData ()
	end
	
	function cancelButton:action ()
		HideDialog (frame)
		frame.active = "NO"
	end
	
	return banPlayerPopup
end

function casino.ui:CreatePdaUI ()
	local saveButton = iup.stationbutton { title="Save", font=casino.ui.font}
	local cancelButton = iup.stationbutton { title="Cancel", font=casino.ui.font}
	
	-- Build basic control box
	local debugToggle = iup.stationtoggle {title="  Use Debug Mode?", fgcolor=navcomp.ui.fgcolor}
	local activateButton = iup.stationbutton {title="Start", font=casino.ui.font}
	local resetButton = iup.stationbutton {title = "Reset", font = casino.ui.font}
	local statusLabel = iup.label {title = "", fgcolor=casino.ui.fgcolor, font=casino.ui.font}
	local maxGameLabel = iup.label {title = "Maximum Players: ", fgcolor=casino.ui.fgcolor, font=casino.ui.font}
	local maxGameLimit = iup.text {value = "    ", size = "50x"}
	
	local function SetCasinoStatus ()
		if casino.data.tablesOpen then
			statusLabel.title = "Open"
			activateButton.title = "Stop"
		else
			statusLabel.title = "Closed"
			activateButton.title = "Start"
		end
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
	
	function activateButton.action ()
		if casino.data.tablesOpen then
			casino:CloseTables ()
		else
			casino:OpenTables ({"", debugToggle.value == "OFF"})
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
	
	-- Assemble Tab Frame
	local tabframe = iup.roottabtemplate {
		statsTab,
		bankTab,
		gameTab,
		waitQueueTab,
		bannedTab;
		expand = "YES"
	}
	
	local pda = iup.vbox {
		iup.label {title = "Casino Settings v" .. casino.version, font=casino.ui.font},
		iup.fill {size = 15},
		status,
		iup.fill {size = 5},
		iup.hbox {
			maxGameLabel,
			maxGameLimit,
			iup.fill {};
			expand = "HORIZONTAL"
		},
		iup.fill {size = 5},
		tabframe,
		iup.fill {},
		iup.hbox {
			iup.fill {},
			saveButton,
			cancelButton; };
	}
	
	function pda:ReloadData ()
		statsTab:ReloadData ()
		bankTab:ReloadData ()
		gameTab:ReloadData ()
		waitQueueTab:ReloadData ()
		bannedTab:ReloadData ()
	end
	
	function pda:GetPlayerLimit ()
		return tonumber (maxGameLimit.value)
	end
	
	function pda:DoSave ()
		casino.data:SaveUserSettings ()
	end
	
	function pda:DoCancel ()
		casino.data:LoadUserSettings ()
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
		bgcolor = "255 10 10 10 *",
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