--[[
	Wait Queue Tab screen for Casino
	
	GUI management for wait queue functions
]]
function casino.ui:CreateWaitQueueTab (bannedTab)
	local notifyPlayerButton = iup.stationbutton {title="Notify Player", font=casino.ui.font, active="NO"}
	local banPlayerButton = iup.stationbutton {title="Ban Player", font=casino.ui.font, active="NO"}
	local selectedRow = 0

	local function SetButtonState ()
		notifyPlayerButton.active = "NO"
		banPlayerButton.active = "NO"
		if selectedRow > 0 then
			notifyPlayerButton.active = "YES"
			banPlayerButton.active = "YES"
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
		bgcolor = casino.ui.bgcolor
	}
	
	-- Set Headers
	matrix:setcell (0, 1, "Index")
	matrix:setcell (0, 2, "Name")
	matrix:setcell (1, 1, string.rep (" ", 5))
	matrix:setcell (1, 2, string.rep (" ", 27))
	
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
	
	function matrix:Set (row, name)
		if name then
			matrix:setcell (row, 1, tostring (row))
			matrix:setcell (row, 2, tostring (name))
		end
		matrix.alignment1 = "ALEFT"
		matrix.alignment2 = "ALEFT"
		matrix.width1 = 75
		matrix.width2 = 400
	end
	
	function matrix.click_cb (self, row, col)
		self:SetSelectedRow (self, row)
		return SetButtonState ()
	end
	
	local waitQueueTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				matrix,
				iup.fill {size = 25},
				iup.hbox {
					iup.fill {},
					notifyPlayerButton,
					banPlayerButton;
					expand = "HORIZONTAL"
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Wait Queue",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function waitQueueTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function waitQueueTab:ReloadData ()
		local list = casino.data.waitQueue
		local name, acct, v
		waitQueueTab:ClearData ()
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
		iup.Refresh (waitQueueTab)
	end
	waitQueueTab:ReloadData ()
	
	function notifyPlayerButton.action ()
		local playerName = matrix:getcell (selectedRow, 1)
		casino:SendMessage (playerName, "A spot has opened in the Casino!")
		table.remove (casino.data.waitQueue, selectedRow)
		selectedRow = 0
		waitQueueTab:ReloadData ()
		return SetButtonState ()
	end
	
	function banPlayerButton.action ()
		local frame = casino.ui:GetBanPlayerPopup (matrix:getcell (selectedRow, 1), waitQueueTab, bannedTab)
		ShowDialog (frame, iup.CENTER, gkinterface.GetYResolution () / 4 - 35)
		frame.active = "YES"
		selectedRow = 0
		return SetButtonState ()
	end
	
	return waitQueueTab
end