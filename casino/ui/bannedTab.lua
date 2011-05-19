--[[
	Banned List Tab screen for Casino
	
	GUI management for the banned list
]]

function casino.ui:CreateBannedTab ()
	local banPlayerButton = iup.stationbutton {title="Ban Player", font=casino.ui.font}
	local removePlayerButton = iup.stationbutton {title="Unban Player", font=casino.ui.font, active="NO"}
	local selectedRow = 0

	local function SetButtonState ()
		removePlayerButton.active = "NO"
		if selectedRow > 0 then
			removePlayerButton.active = "YES"
		end
	end

	-- Build Data Matrix
	local matrix = iup.pdasubmatrix {
		numcol = 2,
		numlin = 1,
		numlin_visible = 10,
		heightdef = 15,
		expand = "YES",
		scrollbar = "YES",
		widthdef = 120,
		font = casino.ui.font,
		bgcolor = "255 10 10 10 *"
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Name")
	matrix:setcell (0, 2, "Reason")
	matrix:setcell (1, 1, string.rep (" ", 25))
	matrix:setcell (1, 2, string.rep (" ", 45))
	
	function matrix:SetSelectedRow (self, row)
		-- Set all bgcolors
		selectedRow = row
		local l, bgcolor
		for l=1, self.numlin do
			bgcolor = string.format ("bgcolor%d:*", l)
			if l == row then
				self [bgcolor] = "255 150 150 150 *"
			else
				self [bgcolor] = "255 10 10 10 *"
			end
		end
	end
	
	function matrix:Set (row, data)
		if data then
			matrix:setcell (row, 1, tostring (data.player))
			matrix:setcell (row, 2, tostring (data.reason))
		end
		matrix.alignment1 = "ALEFT"
		matrix.alignment2 = "ALEFT"
		matrix.width1 = 175
		matrix.width2 = 400
	end
	
	function matrix.click_cb (self, row, col)
		self:SetSelectedRow (self, row)
		return SetButtonState ()
	end
	
	local bannedTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.fill {size = 25},
				matrix,
				iup.fill {size = 25},
				iup.hbox {
					iup.fill {},
					banPlayerButton,
					removePlayerButton,
					banPlayerButton;
					expand = "HORIZONTAL"
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Banned List",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function bannedTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function bannedTab:ReloadData ()
		local list = {}
		local name, reason, v
		for name, reason in pairs (casino.data.bannedList) do
			table.insert (list, {
				player = name,
				reason = reason
			})
		end
		table.sort (list, function (a,b)
			return a.player < b.player
		end)
		bannedTab:ClearData ()
		local row = 0
		matrix.heightdef = 15
		matrix.redraw = "ALL"
		if #list > 0 then
			for _,v in ipairs (list) do
				matrix.addlin = row
				matrix.font = casino.ui.font
				row = row + 1
				matrix:Set (row, v)
			end
			matrix.numlin = row
		else
			matrix.addlin = row
			matrix:Set (0)
		end
		iup.Refresh (bannedTab)
	end
	bannedTab:ReloadData ()
	
	function banPlayerButton.action ()
		local frame = casino.ui:GetBanPlayerPopup ("", bannedTab)
		ShowDialog (frame, iup.CENTER, gkinterface.GetYResolution () / 4 - 35)
		frame.active = "YES"
		return SetButtonState ()
	end
	
	function removePlayerButton.action ()
		casino.data.bannedList [matrix:getcel (selectedRow, 1)] = nil
		bannedTab:ReloadData ()
	end
	
	return bannedTab
end