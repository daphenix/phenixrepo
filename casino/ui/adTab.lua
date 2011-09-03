--[[
	Announcements Maintenance Tab
]]

function casino.ui:CreateAdTab ()
	local addButton = iup.stationbutton { title="Add", font=casino.ui.font}
	local removeButton = iup.stationbutton { title="Remove", font=casino.ui.font, active="NO"}
	local useAnnouncementsToggle = iup.stationtoggle {title="  Use Announcements?", fgcolor=casino.ui.fgcolor}
	local contactPlayersToggle = iup.stationtoggle {title="  Contact Players in Sector?", fgcolor=casino.ui.fgcolor}
	local adDelay = iup.text {value=tostring (casino.data.adDelay/1000), font=casino.ui.font, size="40x"}
	local announcementText = iup.text {value = "", font = casino.ui.font, expand="YES"}
	local selectedRow = 0
	local adList = {}
	local ad
	for _, ad in ipairs (casino.data.announcements) do
		table.insert (adList, ad)
	end
	local channelText = iup.text {value=tostring (casino.data.announcementChannel), font=casino.ui.font, size="40x"}
	local typeSelection = iup.pdasublist  {
		font = casino.ui.font,
		dropdown = "YES",
		size="100x",
		visible_items = 4
	}
	typeSelection [1] = "Channel"
	typeSelection [2] = "System"
	typeSelection [3] = "Sector"
	typeSelection.value = casino.data.announcementType
	
	function typeSelection:action (text, index, state)
		if state == 1 then
			if text == "Channel" then
				channelText.readonly = "NO"
			else
				channelText.readonly = "YES"
			end
		end
	end

	local function SetButtonState ()
		removeButton.active = "NO"
		if selectedRow > 0 then
			removeButton.active = "YES"
		end
	end

	-- Build Data Matrix
	local matrix = iup.pdasubmatrix {
		numcol = 1,
		numlin = 1,
		numlin_visible = 10,
		heightdef = 15,
		expand = "YES",
		scrollbar = "YES",
		widthdef = 120,
		font = casino.ui.font,
		bgcolor = casino.ui.bgcolor
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Announcement")
	matrix:setcell (1, 1, string.rep (" ", 77))
	
	function matrix:SetSelectedRow (self, row)
		-- Set all bgcolors
		selectedRow = row
		local l, bgcolor
		for l=1, self.numlin do
			bgcolor = string.format ("bgcolor%d:*", l)
			if l == row then
				self [bgcolor] = casino.ui.highlight
			else
				self [bgcolor] = casino.ui.bgcolor
			end
		end
	end
	
	function matrix:Set (row, text)
		if text then
			matrix.numlin = row
			matrix.font = casino.ui.font
			matrix.redraw = "ALL"
			matrix:setcell (row, 1, text)
		end
		matrix.alignment1 = "ALEFT"
		matrix.width1 = 475
	end
	
	function matrix.click_cb (self, row, col)
		self:SetSelectedRow (self, row)
		return SetButtonState ()
	end

	local adTab = iup.pdasubframe_nomargin {
		iup.vbox {
			iup.fill {size = 5},
			iup.hbox {
				iup.fill {size = 5},
				useAnnouncementsToggle,
				iup.fill {},
				iup.label {title="Delay (in seconds): ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
				adDelay,
				iup.fill {size = 10};
				expand="YES"
			},
			iup.hbox {
				iup.fill {size = 5},
				contactPlayersToggle,
				iup.fill {},
				iup.label {title="Type:  ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
				typeSelection,
				channelText,
				iup.fill {size = 10};
				expand="YES"
			},
			iup.fill {size = 10},
			matrix,
			iup.fill {size = 10},
			iup.hbox {
				iup.label {title="New Text: ", font=casino.ui.font, fgcolor=casino.uifgcolor},
				announcementText;
				expand = "YES"
			},
			iup.hbox {
				iup.fill {},
				addButton,
				removeButton;
			};
			expand = "YES"
		};
		tabtitle="Announcements",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function adTab:DoSave ()
		casino.data.adDelay = 1000 * adDelay.value
		if useAnnouncementsToggle.value == "ON" and casino.data.tablesOpen and not casino.data.useAnnouncements then
			casino:RunAnnouncements ()
		end
		casino.data.useAnnouncements = useAnnouncementsToggle.value == "ON"
		casino.data.announcements = {}
		local ad
		for _, ad in ipairs (adList) do
			table.insert (casino.data.announcements, ad)
		end
		casino.data.announcementType = tonumber (typeSelection.value)
		casino.data.announcementChannel = tonumber (channelText.value) or 100
		if casino.data.tablesOpen and contactPlayersToggle.value == "ON" and not casino.data.contactPlayers then
			RegisterEvent (casino.data.com, "PLAYER_ENTERED_SECTOR")
			casino.data.contactActive = true
		elseif casino.data.tablesOpen and contactPlayersToggle.value == "OFF" and casino.data.contactPlayers then
			UnregisterEvent (casino.data.com, "PLAYER_ENTERED_SECTOR")
			casino.data.contactActive = false
		end
		casino.data.contactPlayers = contactPlayersToggle.value == "ON"
	end
	
	function adTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function adTab:ReloadData ()
		adDelay.value = tostring (casino.data.adDelay/1000)
		useAnnouncementsToggle.value = casino.ui:GetOnOffSetting (casino.data.useAnnouncements)
		typeSelection.value = casino.data.announcementType
		channelText.value = tostring (casino.data.announcementChannel)
		contactPlayersToggle.value = casino.ui:GetOnOffSetting (casino.data.contactPlayers)
		adTab:ClearData ()
		local row, ad
		for row, ad in ipairs (adList) do
			matrix:Set (row, ad)
		end
		iup.Refresh (adTab)
	end
	adTab:ReloadData ()
	
	function addButton:action ()
		table.insert (adList, announcementText.value)
		announcementText.value = ""
		adTab:ReloadData ()
		return SetButtonState ()
	end
	
	function removeButton:action ()
		table.remove (adList, selectedRow)
		selectedRow = 0
		adTab:ReloadData ()
		return SetButtonState ()
	end
	
	return adTab
end