--[[
Sell Items:
Sell price:
[Quantity] <Max>
<-100><-10><-1><+1><+10><+100>
--]]

function CreateQuantityPurchaseMenu()
	local dlg
	local amountstr1, amountstr2, amountstr3, amountstr4
	local titlestr
	local maxquantityallowed
	local maxaction, buyaction, cancelaction, pricecalc
	local neg100,neg10,neg1,pos1,pos10,pos100
	local buybutton, cancelbutton, maxbutton, quantityedit

	local function setprice(quantity)
		if quantity > 0 then
			buybutton.active = "YES"
		else
			buybutton.active = "NO"
		end
		local sellprice, unitcost = pricecalc(quantity)
		local totalprofit = (sellprice or 0) - ((unitcost or 0)*quantity)
		local color = GetProfitHexColor(totalprofit, 0)
		if totalprofit >= 0 then
			amountstr1.title = "Total Sell Price: "..comma_value(sellprice).." c"
			amountstr2.title = "Purchased Price: "..comma_value(unitcost or 0).." c x"..quantity.." = "..comma_value((unitcost or 0)*quantity).." c"
			amountstr3.title = "Unit profit: \127"..color..comma_value(quantity>0 and (math.floor(10*totalprofit/quantity)/10) or 0).." c"
			amountstr4.title = "Total profit: \127"..color..comma_value(totalprofit).." c"
		else
			local totalloss = -totalprofit
			amountstr1.title = "Total Sell Price: "..comma_value(sellprice).." c"
			amountstr2.title = "Purchased Price: "..comma_value(unitcost or 0).." c x"..quantity.." = "..comma_value((unitcost or 0)*quantity).." c"
			amountstr3.title = "Unit loss: \127"..color..comma_value(math.floor(10*totalloss/quantity)/10).." c"
			amountstr4.title = "Total loss: \127"..color..comma_value(totalloss).." c"
		end
	end

	local function updatequantity(numtoadd)
		local q = math.max(0, (tonumber(quantityedit.value) or 0) + numtoadd)
		q = math.min(q, maxquantityallowed)
		quantityedit.value = q
		setprice(q)
	end

	amountstr1 = iup.label{title="Sell Price: 0c", expand="YES"}
	amountstr2 = iup.label{title="Sell Price: 0c", expand="YES"}
	amountstr3 = iup.label{title="Sell Price: 0c", expand="YES"}
	amountstr4 = iup.label{title="Sell Price: 0c", expand="YES"}
	buybutton = iup.stationbutton{title="Sell", action=function() buyaction() end, active="NO"}
	cancelbutton = iup.stationbutton{title="Cancel", action=function() cancelaction() end}
	maxbutton = iup.stationbutton{title="Max"}
	quantityedit = iup.text{value="1",
		size="60x",
		action=function(self, ch, str)
			if ch == 13 then
				setprice(tonumber(str))
			else
				local quan = tonumber(str)
				if quan then setprice(quan) end
			end
		end,
	}
	function maxbutton:action()
		local q = maxaction()
		if q then
			quantityedit.value = q
			setprice(q)
		end
	end

	neg100 = iup.stationbutton{title="-100",action=function() updatequantity(-100) end}
	neg10 = iup.stationbutton{title="-10",action=function() updatequantity(-10) end}
	neg1 = iup.stationbutton{title="-1",action=function() updatequantity(-1) end}
	pos1 = iup.stationbutton{title="+1",action=function() updatequantity(1) end}
	pos10 = iup.stationbutton{title="+10",action=function() updatequantity(10) end}
	pos100 = iup.stationbutton{title="+100",action=function() updatequantity(100) end}

	titlestr = iup.label{title="Sell Selected Item", font=Font.H1, alignment='ACENTER', expand="HORIZONTAL"}

	local container = iup.vbox{
		amountstr1,
		amountstr2,
		amountstr3,
		amountstr4,
		iup.hbox{
			iup.label{title="Quantity:"},
			quantityedit,
			maxbutton,
		},
		iup.hbox{neg100,neg10,neg1,pos1,pos10,pos100},
		iup.hbox{
			iup.fill{},
			buybutton,
			iup.fill{},
			cancelbutton,
			iup.fill{},
		},
	}

	dlg = iup.dialog{
		iup.hbox{
			iup.fill{},
			iup.vbox{
				iup.fill{},
				iup.stationhighopacityframe{
					iup.stationhighopacityframebg{
						iup.vbox{
							titlestr,
							container,
						},
						expand="NO",
						size=dlgsize,
					},
				},
				iup.fill{},
			},
			iup.fill{},
		},
		defaultesc = cancelbutton,
		fullscreen="YES",
		bgcolor = bgcolor or "0 0 0 128 *",
		topmost="YES",
		show_cb=function()
			maxquantityallowed = maxaction()
			quantityedit.value = 1
			setprice(1)
			RegisterEvent(container, "STATION_UPDATE_PRICE")
		end,
		hide_cb=function()
			UnregisterEvent(container, "STATION_UPDATE_PRICE")
		end,
	}

	dlg:map()

	function dlg:SetupCallbacks(_invname, _pricecalc, _maxaction, _buyaction, _cancelaction)
		titlestr.title = "Sell "..tostring(_invname)
		pricecalc = _pricecalc
		maxaction = _maxaction
		buyaction = _buyaction
		cancelaction = _cancelaction
	end

	function dlg:GetQuantity()
		return tonumber(quantityedit.value)
	end

	function container:OnEvent(eventname, ...)
		if eventname == "STATION_UPDATE_PRICE" then
			updatequantity(0)
		end
	end

	return dlg
end

SellItemDialog = CreateQuantityPurchaseMenu()
