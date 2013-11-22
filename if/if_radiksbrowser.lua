-- RadiKS (nee life) Browser!


RadiKS = {consolehistory = {}, consolehistoryindex = 1, keypositions = {}, lastkeypos = 0, table = {}, subs = {}}

--local matrixcb = function(...)
--					 printtable(args)
--				 end

radiksmatrix = iup.matrix({resizematrix="NO",expand="NO",
							  numcol=2,numlin=20,
							  numcol_visible=2,numlin_visible=20,
							  width1="%50", width2="%50",
							  alignment1="ALEFT", alignment2="ALEFT",
							  edition_cb=matrixparamsedition_cb,
							  size="%89x%85"})
--,"VALUE_CB"=matrixcb})
radiksmatrix:setcell(1,1,"key")
radiksmatrix:setcell(1,2,"value")

cb = function(k,v,o) 
		 local keytype = type(k)
		 local valtype = type(v)
		 
--		 if (keytype == "string" or keytype == "number") and (valtype == "string" or valtype == "number") then
		 
		 local keypos
		 if RadiKS.keypositions[k] then
			 keypos = RadiKS.keypositions[k]
		 else
			 keypos = RadiKS.lastkeypos + 1
			 RadiKS.lastkeypos = keypos
			 RadiKS.keypositions[k] = keypos
		 end
		 
		 RadiKS.table[k] = v
		 print("k:"..StrTable(k).." pos:"..keypos)
		 radiksmatrix:setcell(keypos,1,StrTable(k))
		 radiksmatrix:setcell(keypos,2,string.sub(StrTable(v),1,90))
--	 end
	 end



local radikstextentry = 
	iup.text{
	expand="HORIZONTAL",
	wanttab = "YES",
	action=function(self, ch, str)
			   if ch == iup.K_UP then
				   if RadiKS.consolehistoryindex < (#RadiKS.consolehistory) then
					   RadiKS.consolehistoryindex = RadiKS.consolehistoryindex + 1
					   self.value = RadiKS.consolehistory[RadiKS.consolehistoryindex]
				   end
			   elseif ch == iup.K_DOWN then
				   if RadiKS.consolehistoryindex > 1 then
					   RadiKS.consolehistoryindex = RadiKS.consolehistoryindex - 1
					   self.value = RadiKS.consolehistory[RadiKS.consolehistoryindex]
				   else
					   RadiKS.consolehistoryindex = 0
					   self.value = RadiKS.consolehistory[0]
				   end
			   elseif ch == 13 then -- FIXME: this should be KEY_RETURN after we fix IUP/OnChar/OnKey/blah
				   if self.value == "" then return end
				   self.value = ""
				   
				   --				print(str)
				   local weirdfun,err = loadstring("return {"..string.gsub(str,"(%a[%w_]*)","\"%1\"").."}")
				   if not weirdfun then
					   print(err)
					   return iup.DEFAULT
				   else
					   local address = weirdfun()
					   print("address: "..StrTable(address))
					   local oldsub = RadiKS.subs[1]
					   if oldsub then 
						   Unsubscribe(oldsub) 
						   clearmatrix()
					   end
					   RadiKS.subs[1] = Subscribe(address,cb)
				   end
				   
				   table.insert(RadiKS.consolehistory, 1, str)
				   RadiKS.consolehistory[0] = ""
				   RadiKS.consolehistoryindex = 0
			   elseif ch == 9 then -- FIXME
				   self.value = tabcomplete(self.value, self.caret)
				   RadiKS.consolehistory[0] = self.value
			   elseif ch == 27 or gkinterface.GetCommandForKeyboardBind(ch) == "ConsoleToggle" then -- FIXME
				   RadiKSBrowser:hide()
				   return iup.IGNORE
			   else
				   RadiKS.consolehistory[0] = str
			   end
			   return iup.DEFAULT
		   end}


RadiKSBrowser = iup.dialog{
	iup.vbox{
--		iup.label{title="RadiKS Browser", alignment="ACENTER", expand="HORIZONTAL", fgcolor="0 223 191", font=Font.H1},
--				radikstable,
		radiksmatrix,
		radikstextentry,
	},
	topmost="YES",
	size="%90x%90",
	startfocus = radikstextentry,
}

function RadiKSBrowser:k_any(ch)
	print("rks:k_any")
	if gkinterface.GetCommandForKeyboardBind(ch) == "radiks" then
		HideDialog(self)
		ShowDialog(HUD.dlg)
		return iup.IGNORE
	end
	return iup.CONTINUE
end

function RadiKSBrowser:setup()
	print("rks:setup")
	if RadiKS.subs then print("already subbed")
	else
		table.insert(RadiKS.subs, Subscribe({"characters",GetCharacterID(),"all"}, cb))
	end
end

RegisterEvent(RadiKSBrowser, "RADIKS_BROWSER_TOGGLE")
RegisterEvent(RadiKSBrowser, "UNLOAD_INTERFACE")

function RadiKSBrowser:OnEvent(eventname, ...)
	print("rks:onevent: "..eventname)
	if eventname == "RADIKS_BROWSER_TOGGLE" then
		if RadiKSBrowser.visible == "YES" then
			HideDialog(RadiKSBrowser)
--			ShowDialog(HUD.dlg)
		elseif HUD.dlg.visible == "YES" then
--			HideDialog(HUD.dlg)
			RadiKSBrowser:setup()
			ShowDialog(RadiKSBrowser, iup.CENTER, iup.CENTER)
		end
	elseif eventname == "UNLOAD_INTERFACE" then
		ClearSubs()
	end
end

local function matrixparamsedition_cb() 
	print("matrixparamsedition_cb")
	return iup.IGNORE 
end

function clearmatrix()
	local lastrow = RadiKS.lastkeypos
	local delrange = "1-"..lastrow
--	while lastrow > 0 do
	print("clearmatrix: "..delrange)
	radiksmatrix.dellin = delrange
	radiksmatrix.numlin = 20
	radiksmatrix.numlin_visible = 20
	RadiKS.lastkeypos = 0
	RadiKS.table = {}
end
