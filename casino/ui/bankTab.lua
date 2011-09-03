--[[
	Bank Tab screen for Casino
	
	GUI management for bank functions
]]
function casino.ui:CreateBankTab ()
	local profitTrigger = iup.text {value=casino.data.profitTrigger, font=casino.ui.font, size="100x"}
	local profitTransferAmount = iup.text {value=casino.data.profitTransferAmount, font=casino.ui.font, size="100x"}
	local lossTrigger = iup.text {value=casino.data.lossTrigger, font=casino.ui.font, size="100x"}
	local lossTransferAmount = iup.text {value=casino.data.lossTransferAmount, font=casino.ui.font, size="100x"}
	local createAccountButton = iup.stationbutton { title="Create Account", font=casino.ui.font}
	local closeAccountButton = iup.stationbutton { title="Close Account", font=casino.ui.font, active="NO"}
	local selectedRow = 0

	local function SetButtonState ()
		closeAccountButton.active = "NO"
		if selectedRow > 0 then
			closeAccountButton.active = "YES"
		end
	end

	-- Build Data Matrix
	local matrix = iup.pdasubmatrix {
		numcol = 4,
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
	matrix:setcell (0, 1, "Name")
	matrix:setcell (0, 2, "Balance")
	matrix:setcell (0, 3, "Credit")
	matrix:setcell (0, 4, "Bet")
	matrix:setcell (1, 1, string.rep (" ", 27))
	matrix:setcell (1, 2, string.rep (" ", 15))
	matrix:setcell (1, 3, string.rep (" ", 15))
	matrix:setcell (1, 4, string.rep (" ", 15))
	
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
	
	function matrix:Set (row, data)
		if data then
			matrix:setcell (row, 1, tostring (data.player))
			matrix:setcell (row, 2, tostring (data.balance))
			matrix:setcell (row, 3, tostring (data.credit))
			matrix:setcell (row, 4, tostring (data.bet))
		end
		matrix.alignment1 = "ALEFT"
		matrix.alignment2 = "ARIGHT"
		matrix.alignment3 = "ARIGHT"
		matrix.width1 = 175
		matrix.width2 = 100
		matrix.width3 = 100
		matrix.width4 = 100
	end
	
	function matrix.click_cb (self, row, col)
		self:SetSelectedRow (self, row)
		return SetButtonState ()
	end

	local bankTab = iup.pdasubframe_nomargin {
		iup.hbox {
			iup.fill {size = 5},
			iup.vbox {
				iup.hbox {
					iup.label {title="Profit Trigger: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor, size="120x"},
					profitTrigger,
					iup.fill {},
					iup.label {title="Profit Transfer: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					profitTransferAmount;
					expand="YES"
				},
				iup.hbox {
					iup.label {title="Loss Trigger: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor, size="120x"},
					lossTrigger,
					iup.fill {},
					iup.label {title="Loss Transfer: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
					lossTransferAmount;
					expand="YES"
				},
				iup.fill {size = 5},
				matrix,
				iup.fill {size = 25},
				iup.hbox {
					iup.fill {},
					createAccountButton,
					closeAccountButton;
					expand = "HORIZONTAL"
				},
				iup.fill {};
				expand = "YES"
			};
			expand = "YES"
		};
		tabtitle="Bank",
		font=casino.ui.font,
		expand = "YES"
	}
	
	function bankTab:DoSave ()
		casino.data.profitTrigger = tonumber (profitTrigger.value)
		casino.data.profitTransferAmount = tonumber (profitTransferAmount.value)
		casino.data.lossTrigger = tonumber (lossTrigger.value)
		casino.data.lossTransferAmount = tonumber (lossTransferAmount.value)
	end
	
	function bankTab:ClearData ()
		local i
		for i=1, tonumber (matrix.numlin) do
			matrix.dellin = 1
		end
	end
	
	function bankTab:ReloadData ()
		local list = {}
		local name, acct, v
		for name, acct in pairs (casino.bank.trustAccount) do
			table.insert (list, {
				player = name,
				balance = acct.balance,
				credit = acct.creditLine,
				bet = acct.currentBet
			})
		end
		table.sort (list, function (a,b)
			return a.player < b.player
		end)
		bankTab:ClearData ()
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
		profitTrigger.value = casino.data.profitTrigger
		profitTransferAmount.value = casino.data.profitTransferAmount
		lossTrigger.value = casino.data.lossTrigger
		lossTransferAmount.value = casino.data.lossTransferAmount
		iup.Refresh (bankTab)
	end
	bankTab:ReloadData ()
	
	-- Define local popup for new accounts
	local playerName = iup.text {value = "", size="150x"}
	local accountBalance = iup.text {value = "", size="100x"}
	local newAccountPopup = nil
	
	local function GetNewAccountPopup ()
		if not newAccountPopup then
			local createButton = iup.stationbutton {title="Create", font=casino.ui.font}
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
							iup.label {title="Account Balance: ", font=casino.ui.font, fgcolor=casino.ui.fgcolor},
							accountBalance,
							iup.fill {size=5};
							expand = "HORIZONTAL"
						},
						iup.fill {size=15},
						iup.hbox {
							iup.fill {},
							createButton,
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
			
			function createButton:action ()
				casino.bank:OpenAccount (playerName.value, tonumber (accountBalance.value), true)
				HideDialog (frame)
				frame.active = "NO"
				bankTab:ReloadData ()
			end
			
			function cancelButton:action ()
				HideDialog (frame)
				frame.active = "NO"
			end
			newAccountPopup = frame
		else
			playerName.value = ""
			accountBalance.value = ""
		end
		
		return newAccountPopup
	end
	
	function createAccountButton:action ()
		local frame = GetNewAccountPopup ()
		ShowDialog (frame, iup.CENTER, gkinterface.GetYResolution () / 4 - 35)
		frame.active = "YES"
		return SetButtonState ()
	end
	
	function closeAccountButton:action ()
		casino.bank:CloseAccount (matrix:getcell (selectedRow, 1), true)
		selectedRow = 0
		bankTab:ReloadData ()
		return SetButtonState ()
	end
	
	return bankTab
end