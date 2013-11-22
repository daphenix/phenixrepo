MAX_ACCOMICONS = 20
MAX_ACCOMICON_COLUMNS = 5
MAX_ACCOMICON2_COLUMNS = 4

function AccomplishmentTemplate(click_cb)
	local accombox, accomicons, curcharid
	local accomiconsize = "64x64"

	local button_cb
	accomicons = {}
	accomthing = {}
	for i=1,MAX_ACCOMICONS do
		local index = i
		local icon
		if click_cb then
			button_cb = function()
				local accomtype, accomlevel = GetAccomplishmentType(index, curcharid)
				click_cb(GetAccomplishmentDescription(accomtype, accomlevel))
			end
		end
		icon = iup.button{title="",image="",size=accomiconsize,expand="NO",
			bgcolor="255 255 255 255 *",
			action = button_cb,
			enterwindow_cb=function(self)
				local accomtype, accomlevel = GetAccomplishmentType(index, curcharid)
				ShowTooltip(tonumber(icon.x), -tonumber(icon.y), GetAccomplishmentName(accomtype, accomlevel))
			end,
			leavewindow_cb=function(self)
				HideTooltip()
			end,
			}
		accomicons[i] = icon
	end
	accombox = {margin = "5x5",gap=5,expand="YES"}
	accombox[1] = iup.fill{}
	for i=1,MAX_ACCOMICONS/MAX_ACCOMICON_COLUMNS, 1 do
		local row = {gap=5,expand="YES"}
		for j=1,MAX_ACCOMICON_COLUMNS do
			row[j] = accomicons[j + (i-1)*MAX_ACCOMICON_COLUMNS]
		end
		accombox[1+i] = iup.hbox(row)
	end
	accombox[(MAX_ACCOMICONS/MAX_ACCOMICON_COLUMNS)+2] = iup.fill{}

	accombox = iup.vbox(accombox)

	function accombox:ClearAccomplishments()
		for index=1,MAX_ACCOMICONS do
			accomicons[index].visible = "NO"
			accomicons[index].size = "1x1"
		end
	end
	function accombox:UpdateAccomplishments(charid)
		curcharid = charid
		local n = GetNumAccomplishments(charid)
		if n > MAX_ACCOMICONS then n = MAX_ACCOMICONS end
		local nextindex = 1
		for index=1,n do
			local accomtype, accomlevel = GetAccomplishmentType(index, charid)
			if accomtype and accomlevel then
				local icon = accomicons[nextindex]
				nextindex = nextindex + 1
				icon.image = GetAccomplishmentTexture(accomtype, accomlevel)
				icon.uv = GetAccomplishmentUV(accomtype, accomlevel)
				icon.visible = "YES"
				icon.size = GetAccomplishmentSize(accomtype, accomlevel) or accomiconsize
			end
		end
		iup.GetDialog(accombox).size = nil
	end
	return accombox
end



local function makesubdlg(istitleonly)
	local fontsize = Font.Default
	local titletext
	local iconimages = {}
	local mouseovertextlist = {}

	local region

	if istitleonly then
		titletext = iup.label{title="Desc", font=Font.H1, size="200x30"}
		region = iup.frame{titletext, bgcolor="0 0 0 0 *"}
	else
		local hbox = {alignment="ACENTER", margin="5x5"}
		table.insert(hbox, iup.fill{})
		for i=1,MAX_ACCOMICON2_COLUMNS do
			local index = i
			local button = iup.button{title="", image="",size="96x32",
				bgcolor="255 255 255 255 *",
				enterwindow_cb=function(self)
					ShowTooltip(tonumber(iconimages[index].x), -tonumber(iconimages[index].y), mouseovertextlist[index] or "")
				end,
				leavewindow_cb=function(self)
					HideTooltip()
				end,
			}
			table.insert(iconimages, button)
			table.insert(hbox, button)
		end
		table.insert(hbox, iup.fill{})
		
		region = iup.pdasubframe_nomargin{iup.hbox(hbox), size="1x1", expand="YES"}
	end

	local dlgtable

	dlgtable = iup.dialog{
		region,
		border="NO",menubox="NO",resize="NO",
		shrink="YES",
		bgcolor="0 0 0 0 +",
	}

	function dlgtable:SetIcon(index, img, imguv, imgsize, click_cb, mouseovertext)
		local iconimg = iconimages[index]
		if not img then
			iconimg.visible = "NO"
			iconimg.size = "1x32"
			iconimg.action = nil
			mouseovertextlist[index] = ""
		else
			iconimg.size = imgsize or "96x32"
			iconimg.uv = imguv or "0 0 1 1"
			iconimg.visible = "YES"
			iconimg.image = tostring(img)
			iconimg.action = click_cb
			mouseovertextlist[index] = mouseovertext
		end
	end
	function dlgtable:SetTitle(titlestring)
		if titletext then
			titletext.title = titlestring or ""
			titletext.alignment = "ACENTER"
			titletext.expand = "YES"
		end
	end
	
	dlgtable.istitle = istitleonly and true

	return dlgtable
end

local _accomdlgcache = { {},{} }
local function get_accomdlg(istitle)
	local dlg
	local cache = _accomdlgcache[istitle and 2 or 1]
	if cache[1] then
		dlg = table.remove(cache)
		dlg.incache = false
	else
		dlg = makesubdlg(istitle)
	end
	return dlg
end

local function store_accomdlg(dlg)
	if not dlg.incache then
		local cache = _accomdlgcache[dlg.istitle and 2 or 1]
		dlg.incache = true
		table.insert(cache, dlg)
	end
end

function clear_accomlistbox(listcontrol, itemlist)
	local curselindex

	listcontrol[1] = nil
	listcontrol.value = 0 -- this will cause the sel callback to not send unsel

	if not itemlist then return 0 end

	for k,subdlg in ipairs(itemlist) do
		if subdlg.sel then
			curselindex = k
			subdlg.sel = false
		end
		iup.Detach(subdlg)
		store_accomdlg(subdlg)
	end

	return curselindex
end

-- int end_index setup_cb(start_index, item_list, subdlg)

function fill_accomlistbox(listcontrol, itemlist, setup_cb, click_cb)
	local _itemlist = {}
	local numitems = (#itemlist)
	local k=1
	while (k<=numitems) do
		local v = itemlist[k]

		local subdlg = get_accomdlg(v.title)

		table.insert(_itemlist,subdlg)

		k = setup_cb(k, itemlist, subdlg, click_cb)

		if listcontrol then iup.Append(listcontrol, subdlg) end
	end

	if listcontrol then
		listcontrol:map()
		if (#_itemlist) == 0 then
			listcontrol.scroll = "TOP"
		end

		listcontrol[1] = 1
	end

	return _itemlist
end

function setup_accomrow(start_index, itemlist, subdlg, click_cb)
	local i=1
	while(i<=MAX_ACCOMICON2_COLUMNS) do
		local iconinfo = itemlist[start_index]
		if not iconinfo then break end
		if iconinfo.title then
			if i == 1 then
				subdlg:SetTitle(iconinfo.title)
				return start_index + 1
			else
				break
			end
		end
		local icontexture, iconuv, iconsize
		local accomtype, accomlevel = GetAccomplishmentType(iconinfo.index, iconinfo.charid)
		if accomtype > 0 then
			icontexture = GetAccomplishmentTexture(accomtype, accomlevel)
			iconuv = GetAccomplishmentUV(accomtype, accomlevel)
			iconsize = GetAccomplishmentSize(accomtype, accomlevel)
		end
		subdlg:SetIcon(i, icontexture, iconuv,
			iconsize or iconinfo.size or "64x64",
			function()
				if click_cb then
					local desc = GetAccomplishmentDescription(accomtype, accomlevel)
					local cur, nxt = GetAccomplishmentLevels(iconinfo.index)
					desc = string.gsub(desc, "<current>", tostring(cur))
					desc = string.gsub(desc, "<nextvalue>", tostring(nxt))
					desc = string.gsub(desc, "<diffvalue>", tostring(nxt - cur))
					click_cb(desc, accomtype, accomlevel)
				end
			end,
			(accomtype > 0) and GetAccomplishmentName(accomtype, accomlevel) or "")
		start_index = start_index + 1
		i = i + 1
	end
	while(i<=MAX_ACCOMICON2_COLUMNS) do
		subdlg:SetIcon(i, nil)
		i = i + 1
	end
	
	subdlg.size = nil

	return start_index
end

local accomcategories = {
	{category = "special", title = "S p e c i a l", notvisibleempty = true},
	{category = "combat", title = "C o m b a t"},
	{category = "trading", title = "T r a d i n g"},
	{category = "mining", title = "M i n i n g"},
	{category = nil, title = "O t h e r", notvisibleempty = true},
}
local numaccomcategories = (#accomcategories)

function AccomplishmentTemplate2(click_cb)
	local listcontrol
	local listboxlist

--	listcontrol = iup.itemlisttemplate({size="416x1", expand="VERTICAL"}, false)
	listcontrol = iup.itemlisttemplate({size="0x0"}, false)

	function listcontrol:ClearAccomplishments()
		clear_accomlistbox(listcontrol, listboxlist)
	end
	function listcontrol:ReloadAccomplishments(charid)
		local cursel = clear_accomlistbox(listcontrol, listboxlist)
		self:UpdateAccomplishments(charid)
		if listboxlist[cursel] then listboxlist[cursel].action() end
	end
	function listcontrol:UpdateAccomplishments(charid)
		local maxwidth = tonumber(listcontrol.W) - 30 -- for borders and scrollbar
		MAX_ACCOMICON2_COLUMNS = math.floor(maxwidth/92)
		local n = GetNumAccomplishments(charid)
		local accomlist = {}
		for i=1,numaccomcategories do
			local curcategory = accomcategories[i].category
			local beginningindex = (#accomlist)
			local numadded = 0
			for index=1,n do
				local accomtype, accomlevel = GetAccomplishmentType(index, charid)
				local infocategory = GetAccomplishmentCategory(accomtype, accomlevel)
				local i = index
				if infocategory == curcategory then
					table.insert(accomlist, {index=i, charid=charid})
					numadded = numadded + 1
				end
			end
			if (numadded > 0) or not accomcategories[i].notvisibleempty then
				if numadded == 0 then
					table.insert(accomlist, {size="96x32"})
				end
				table.insert(accomlist, beginningindex+1, {title = accomcategories[i].title})
			end
		end
		listboxlist = fill_accomlistbox(listcontrol, accomlist, setup_accomrow, click_cb)
		iup.GetDialog(listcontrol).size = nil
	end
	return listcontrol
end
