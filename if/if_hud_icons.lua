-- HUD addon/cargo

local function make_addon_icon(pic, quantity)
	local iconsize = "32x32" -- (Font.H4*2*HUD_SCALE).."x"..(Font.H4*2*HUD_SCALE)
	local icon = iup.label{title="",image=pic, size=iconsize}
	icon.bgcolor="255 255 255 255 &"
	icon.cx = 0
	icon.cy = 0
	local highlight = iup.label{title="",image="images/icon_powerupselect.tga", size=iconsize}
	highlight.bgcolor="255 255 255 255 +"
	highlight.cx = 0
	highlight.cy = 0
	local layers = iup.cbox{icon, highlight, size=iconsize, active="NO"}
	local quantitytext = iup.label{title=quantity and tonumber(quantity) or "", font=Font.H6*HUD_SCALE, fgcolor="255 255 255", wordwrap="NO", expand="HORIZONTAL", alignment="ARIGHT"}
--	local quantitytext = iup.label{title=quantity and tonumber(quantity) or "", font=Font.H6*HUD_SCALE, fgcolor="255 255 255", size=(Font.H4*1.5*HUD_SCALE), wordwrap="NO", expand="HORIZONTAL", alignment="ARIGHT"}
--	local hbox = iup.hbox{layers, iup.fill{size="5"}, quantitytext, alignment="ABOTTOM"}
	local hbox = iup.zbox{layers, quantitytext, alignment="SE", all="YES"}

	return {container=hbox, icon=icon, qtext=quantitytext, highlight=highlight}
end

local function make_cargo_icon(pic, quantity)
	local iconsize = "32x32" -- (Font.H4*2*HUD_SCALE).."x"..(Font.H4*2*HUD_SCALE)
	local image = iup.label{title="",image=pic, size=iconsize}
	image.bgcolor="255 255 255 255 &"
--	local quantitytext = iup.label{title=tonumber(quantity).."x", font=Font.H6*HUD_SCALE, fgcolor="255 255 255", wordwrap="NO", expand="HORIZONTAL", alignment="ARIGHT"}
	local quantitytext = iup.label{title="", font=Font.H6*HUD_SCALE, fgcolor="255 255 255", wordwrap="NO", expand="HORIZONTAL", alignment="ARIGHT"}
--	local quantitytext = iup.label{title=tonumber(quantity).."x", font=Font.H6*HUD_SCALE, fgcolor="255 255 255", size=(Font.H4*1.5*HUD_SCALE), wordwrap="NO", expand="HORIZONTAL", alignment="ARIGHT"}
--	local icon = iup.hbox{image, iup.fill{size="5"}, quantitytext, alignment="ABOTTOM"}
	local icon = iup.zbox{image, quantitytext, alignment="SE", all="YES"}
	
	return {container=icon, icon=image, qtext=quantitytext}
end


function HUD:CreateIconAreas()
	local allcargoicons = {}
	for i=1,20 do
		allcargoicons[i] = make_cargo_icon("images/icon_addon_empty.png", 99)
	end
	self.cargocolumn1 = iup.vbox{allcargoicons[1].container, allcargoicons[2].container}
	self.cargocolumn2 = iup.vbox{allcargoicons[3].container, allcargoicons[4].container}
	local firstcargolist = iup.hbox{
		self.cargocolumn1,
		self.cargocolumn2,
	}
	local restcargolist = iup.hbox{
		iup.vbox{allcargoicons[5].container, allcargoicons[6].container, allcargoicons[7].container, allcargoicons[8].container},
		iup.vbox{allcargoicons[9].container, allcargoicons[10].container, allcargoicons[11].container, allcargoicons[12].container},
		iup.vbox{allcargoicons[13].container, allcargoicons[14].container, allcargoicons[15].container, allcargoicons[16].container},
		iup.vbox{allcargoicons[17].container, allcargoicons[18].container, allcargoicons[19].container, allcargoicons[20].container},
	}

	local alladdonicons = {}
	for i=1,6 do
		alladdonicons[i] = make_addon_icon("images/icon_addon_empty.png", 99)
	end
	self.addoncolumn1 = iup.vbox{alladdonicons[1].container, alladdonicons[2].container, alladdonicons[3].container}
	self.addoncolumn2 = iup.vbox{alladdonicons[4].container, alladdonicons[5].container, alladdonicons[6].container}
	local alladdonlist = iup.hbox{
		self.addoncolumn1,
		self.addoncolumn2,
	}

	self.morecargoindicator = iup.label{title="", image=IMAGE_DIR.."hud_cargo_more.png", size="6x16", uv="0 0 .75 1", visible="NO"}
	self.morecargoindicator2 = iup.label{title="", image=IMAGE_DIR.."hud_cargo_more.png", size="6x16", uv="0 0 .75 1"}

	self.alladdonlist = alladdonlist
	self.firstcargolist = firstcargolist
	self.addonframe = iup.hudleftframe{alladdonlist, expand="NO"}
--	self.cargoframe = iup.zbox{iup.hudleftframe{firstcargolist, expand="NO"}, self.morecargoindicator, all="YES", alignment="NE"}
	self.cargoframe = iup.hudleftframe{firstcargolist, expand="NO"}
	self.restcargoframe = iup.hudleftframe{restcargolist, expand="NO"}
	self.alladdonicons = alladdonicons
	self.allcargoicons = allcargoicons
	self.missionupdateindicatorbutton = iup.button{title="m",image=IMAGE_DIR.."hud_updateicon.png", size="32x32", bgcolor="255 255 255 255 &", active="NO", DISABLEDTEXTCOLOR=tabseltextcolor}
	self.missionupdateindicator = iup.hudleftframe{
		self.missionupdateindicatorbutton,
		expand="NO",
		visible="NO",
	}
	self.voteindicatorbutton = iup.button{title="V",image=IMAGE_DIR.."hud_updateicon.png", size="32x32", bgcolor="255 255 255 255 &", active="NO", DISABLEDTEXTCOLOR=tabseltextcolor}
	self.voteindicator = iup.hudleftframe{
		self.voteindicatorbutton,
		expand="NO",
		visible="NO",
	}
end

function HUD:SetWeaponGroupHighlights()
	for k,icon in pairs(self.alladdonicons) do
		icon.highlight.visible = "NO"
	end

	local group1, group2, group3 = GetActiveShipSelectedWeaponGroupIDs()
	if not group1 then return end
	if not self.addonlist then return end

	local leadoffport1 = 0
	for portid,_ in pairs(GetActiveShipWeaponGroup(group1)) do
		local layers = self.addonlist[portid]
		if layers then
			layers.highlight.visible = "YES"
			leadoffport1 = portid
		end
	end
	self.leadoff_arrow.portid = leadoffport1
	for portid,_ in pairs(GetActiveShipWeaponGroup(group2)) do
		local layers = self.addonlist[portid]
		if layers then
			layers.highlight.visible = "YES"
		end
	end
	for portid,_ in pairs(GetActiveShipWeaponGroup(group3)) do
		local layers = self.addonlist[portid]
		if layers then
			layers.highlight.visible = "YES"
		end
	end
end

function HUD:ChangeAddonElement(close)
	self.invclosed = close

	self.restcargoframe.visible = close and "NO" or (self.morethan4items and self.visibility.cargo or "NO")
	self.morecargoindicator2.visible = close and "NO" or (self.morethan4items and self.visibility.cargo or "NO")
end

function HUD:SetupAddons()
	local needrefresh = false
	local shipitemid = GetActiveShipID()
--[[
	if not shipitemid then
		self.dlg:map()
		iup.Refresh(self.dlg)
		return
	end
--]]

	self.addonlist = {}

	local n = (GetActiveShipNumAddonPorts() or 0)-1
	local iconindex = 1
	for portid=2,n do  -- skip engine and powercell
		local itemid = GetActiveShipItemIDAtPort(portid)
		local itemicon = GetInventoryItemInfo(itemid)
		if itemicon then
			local ammo = GetAddonItemInfo(itemid)
			if ammo and (ammo < 0) then ammo = nil end
			local icon = self.alladdonicons[iconindex]
			if icon then
				iconindex = iconindex + 1
				icon.icon.image=itemicon
				icon.qtext.title=tonumber(ammo) or ""
				icon.container.visible = "YES"
				self.addonlist[portid] = icon
			else
				break  -- no more available icons to show, so let's stop.
			end
		end
	end
	local numvisibleicons = iconindex-1
	-- hide the rest of them
	while self.alladdonicons[iconindex] do
		self.alladdonicons[iconindex].container.visible = "NO"
		iconindex = iconindex + 1
	end
	-- if there are less than 2 columns, remove the second column
	if numvisibleicons < 4 then
		iup.Detach(self.addoncolumn2)
		needrefresh = true
	else
		local parent = iup.GetParent(self.addoncolumn2)
		if (not parent) or (parent == self.addoncolumn2) then
			iup.Append(self.alladdonlist, self.addoncolumn2)
			needrefresh = true
		end
	end

	local tmp_cargolist = {}
	for itemid,_ in PlayerInventoryPairs() do
		if GetInventoryItemContainerID(itemid) == shipitemid then
			local classtype = GetInventoryItemClassType(itemid)
			if (classtype == CLASSTYPE_GENERIC or classtype == CLASSTYPE_ADDON) and
					GetActiveShipPortIDOfItem(itemid) == nil then
				table.insert(tmp_cargolist, itemid)
			end
		end
	end

	table.sort(tmp_cargolist, function(a,b)
			local quan_a = GetInventoryItemQuantity(a)
			local quan_b = GetInventoryItemQuantity(b)
			if quan_a ~= quan_b then
				return quan_a < quan_b
			else
				return a < b
			end
		end)
	n = (#tmp_cargolist)
	if n > 4 then
		self.morecargoindicator.visible = self.visibility.cargo
		self.morethan4items = true
	else
		self.morecargoindicator.visible = "NO"
		self.morethan4items = false
	end
	iconindex = 1
	-- do this before making things visible
	if n >= 3 then
		local parent = iup.GetParent(self.cargocolumn2)
		if not parent then
			iup.Append(self.firstcargolist, self.cargocolumn2)
			needrefresh = true
		end
	end
	for i=1,n do
		local itemicon, itemname, itemquantity = GetInventoryItemInfo(tmp_cargolist[i])
		local icon = self.allcargoicons[iconindex]
		if icon then
			iconindex = iconindex + 1
			icon.icon.image=itemicon
			local quan = tonumber(itemquantity) or 0
			icon.qtext.title=quan > 1 and string.format("%ux", quan) or ""
			icon.container.visible = "YES"
		else
			break  -- no more available icons to show, so let's stop.
		end
	end
	-- hide the rest of them
	while self.allcargoicons[iconindex] do
		self.allcargoicons[iconindex].container.visible = "NO"
		iconindex = iconindex + 1
	end
	-- if there are less than 2 columns, remove the second column
	-- but do this after making things invisible
	if n < 3 then
		iup.Detach(self.cargocolumn2)
		needrefresh = true
	else
		self.cargocolumn2.visible = "YES"
	end

	self:SetWeaponGroupHighlights()
	if needrefresh then
		iup.Refresh(self.dlg)
	end
end

function HUD:ShowMissionIndicator()
	if self.missionupdateindicator.visible ~= "YES" then
		self.missionupdateindicator.visible = "YES"
		local keys = gkinterface.GetBindsForCommand("missionchat")
		self.missionupdateindicatorbutton.title = ((keys and keys[1]) or "m")

		local ypos = tonumber(self.missionupdateindicator.y)
		self.missionupdatetouchregion = gkinterface.CreateTouchRegion(nil,nil,"missionchat", false,false, false,false, false, false,
					4,ypos, 4+32,ypos+32
					)
	end

	-- bounce the icon out 20%.
	local twenty_percent = 0.2 * gkinterface.GetXResolution()

	local oldxpos = 4 -- tonumber(self.missionupdateindicator.x)
	local newxpos = oldxpos + twenty_percent
	iup.Animate(self.missionupdateindicator,
		oldxpos, nil, nil, nil,
		newxpos, nil, nil, nil, 1000, 1)

	oldxpos = oldxpos + 4 -- tonumber(self.missionupdateindicatorbutton.x)
	newxpos = oldxpos + twenty_percent
	iup.Animate(self.missionupdateindicatorbutton,
		oldxpos, nil, nil, nil,
		newxpos, nil, nil, nil, 1000, 1)
		
	-- timer to flash mission indicator .5Hz between white and cyan
	local whichcolor = false
	self.missionupdateindicatortimer = self.missionupdateindicatortimer or Timer()
	if not self.missionupdateindicatortimer:IsActive() then
		self.missionupdateindicatortimer:SetTimeout(2000, function()
				whichcolor = not whichcolor
				-- if whichcolor == true then white, else cyan
				if whichcolor then
					self.missionupdateindicatorbutton.DISABLEDTEXTCOLOR = "255 255 255 255"
				else
					self.missionupdateindicatorbutton.DISABLEDTEXTCOLOR = tabseltextcolor
				end
				
				self.missionupdateindicatortimer:SetTimeout(2000)
			end)
	end
end

function HUD:HideMissionIndicator()
	if self.missionupdateindicator then
		self.missionupdateindicator.visible = "NO"
		
		if self.missionupdatetouchregion then
			gkinterface.DestroyTouchRegion(self.missionupdatetouchregion)
			self.missionupdatetouchregion = nil
		end
	end
	
	if self.missionupdateindicatortimer then
		self.missionupdateindicatortimer:Kill()
	end
end
