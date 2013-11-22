-- HUD progress bars

local __iup_sa = iup.StoreAttribute

function HUD:StartWeaponProgress(itemid, percent, timestamp, rate)
	local progress = self.progressbars.items[itemid]
	local curtime = gkmisc.GetGameTime()
	local value = math.floor(percent + gkmisc.DiffTime(timestamp, curtime)*rate)
	if not progress then
		progress = iup.progressbar{value = value, title="", active="NO", size=HUDSize(.1,.01), expand="NO", minvalue=0, maxvalue=100, lowercolor="0 153 102 255 *", uppercolor="0 153 102 128 *"}
		self.progressbars.container:append(progress)
		self.progressbars.items[itemid] = {control = progress, percent=percent, rate=rate, timestamp=timestamp}
		progress.visible = "YES"
		self.dlg:map()
		iup.Refresh(self.dlg)
	else
		if percent > 1 then
			self:StopWeaponProgress(itemid)
		else
			progress.control.value = value
			progress.percent = percent
			progress.timestamp = timestamp
			progress.rate = rate
		end
	end
end

function HUD:StopWeaponProgress(itemid)
	local progress = self.progressbars.items[itemid]
	if progress then
		progress = progress.control
		self.progressbars.items[itemid] = nil
		progress:detach()
		progress:destroy()
		iup.Refresh(self.dlg)
	end
end

function HUD:UpdateWeaponProgress(delta)
	local curtime = gkmisc.GetGameTime()
	for k,v in pairs(self.progressbars.items) do
		local value = math.floor(v.percent + gkmisc.DiffTime(v.timestamp, curtime)*v.rate)
		if value >= 100 then
			self:StopWeaponProgress(k)
		else
			__iup_sa(v.control, "VALUE", value)
		end
	end
end

function HUD:RemoveAllWeaponProgress()
	for k,v in pairs(self.progressbars.items) do
		local progress = v.control
		progress:detach()
		progress:destroy()
	end
	self.progressbars.items = {}
end
