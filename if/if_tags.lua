-- pseudo-html tag stuff

-- <button title="title" expand="YES|NO" alignment="ALEFT|ARIGHT|ACENTER" msg="response string displayed in log" action="string to send back to server"/>
-- <keybind cmd="command"/>
-- <hr color="255 255 255" size="12"/>
-- <hudtext>blah blah blah</hudtext>
-- <table><tr><th></th></tr><tr><td></td></tr></table>
-- <ul><li visible="no"></li><li done="yes"></li></ul>
-- <div></div>
-- <countdown time="123456789"/>
TagFuncs = {}
function TagFuncs.button(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	if not isactive or not islast then
		return nil, nil
	end
	local title = xmlobject.title or xmlobject[1]
	local preserve = xmlobject.preserve
	local actiontext = tostring(xmlobject.action or "")
	local msg = tostring(xmlobject.msg or (title and "\n"..title.."\n") or "\n")
--	local msg = tostring(xmlobject.msg or title or "\n")
	local control = iup.stationbutton{
		title=title or "button",
		expand=xmlobject.expand or "YES",
		alignment = xmlobject.alignment or "ALEFT",
		tip = xmlobject.tip,
		image = xmlobject.image,
		size = xmlobject.size,
		action=function()
			SendChat(actiontext, "MISSION")
			-- replace button with msg text
			if not preserve then codetable[markupindex] = msg end
			-- remove all other buttons, replacing them with an empty string
			for a,b in ipairs(codetable) do
				if b ~= xmlobject and type(b) == "table" and b[0] == "button" then
					codetable[a] = ""
				end
			end
			-- force it to refresh (but don't put any buttons in)
--			on_selection(tonumber(missionlist.value), false)
			on_selection(tonumber(missionlist.value))
		end}

	return control
end
function TagFuncs.keybind(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	return nil, XMLTagToString(xmlobject)
end
function TagFuncs.hr(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	return iup.hbox{alignment="ACENTER",size="x"..(xmlobject.size or "12"),iup.fill{size='10'},iup.label{title="",image="",expand="YES",size="x1",fgcolor=xmlobject.color},iup.fill{size='10'}}
end

local function matrixparamsedition_cb() return iup.IGNORE end

function TagFuncs.table(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	local matrixparams = {resizematrix="YES",expand="YES"}
	local numcol,numlin = 0,0
	local clickevents
	
	local hasheader = false
	for index,row in ipairs(xmlobject) do
		local numcolsinrow = 0
		if row[0] == "tr" then
			numlin = numlin + 1
			for _,col in ipairs(row) do
				if col[0] == "td" then
					numcolsinrow = numcolsinrow + 1
				elseif col[0] == "th" then
					hasheader = true
				end
			end
		end
		numcol = math.max(numcol, numcolsinrow)
	end
	if hasheader then numlin = numlin - 1 end  -- <th> always has to come before the <td> to make this work.
	
	matrixparams.numcol = xmlobject.numcol or numcol
	matrixparams.numlin = xmlobject.numrow or numlin
	matrixparams.numcol_visible = xmlobject.numcol_visible or numcol
	matrixparams.numlin_visible = xmlobject.numrow_visible or numlin
	matrixparams.edition_cb = matrixparamsedition_cb
	local control = iup.matrix(matrixparams)

	for rowindex,row in ipairs(xmlobject) do
		if row[0] == "tr" then
			for colindex,col in ipairs(row) do
				if col[0] == "td" then
					local therow = rowindex - (hasheader and 1 or 0)
					control:setcell(therow, colindex, tostring(col[1]))  -- <th> always has to come before the <td> to make this work.
					if col.fgcolor or row.fgcolor or xmlobject.fgcolor then control:setattribute("FGCOLOR", therow, colindex, col.fgcolor or row.fgcolor or xmlobject.fgcolor) end
					if col.bgcolor or row.bgcolor or xmlobject.bgcolor then control:setattribute("BGCOLOR", therow, colindex, col.bgcolor or row.bgcolor or xmlobject.bgcolor) end
					if col.onclick then
						clickevents = clickevents or {}
						clickevents[(therow*numcol) + colindex] = tostring(col.onclick)
					end
				elseif col[0] == "th" then
					control:setcell(0, colindex, tostring(col[1]))
				end
			end
		end
	end

	if clickevents then
		function control:enteritem_cb(rowindex, colindex)
			local clickevent = clickevents[(rowindex*numcol) + colindex]
			if clickevent then
				SendChat(clickevent, "MISSION")
			end
		end
	end

	return control
end

local bulletimage = "images/treeleaf.png" -- IMAGE_DIR.."radio_bg.png"
function TagFuncs.ul(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	local items = {}
	for index,row in ipairs(xmlobject) do
		if (row[0] == "li") and (row.visible ~= "no") then
			local col = (isactive and (row.done~="yes") and "255 255 255") or "128 128 128"
			table.insert(items, iup.hbox{expand="HORIZONTAL", iup.fill{size="10"}, iup.label{title="",image=bulletimage}, iup.label{fgcolor = col, title=tostring(row[1])}})
		end
	end
	return iup.vbox(items)
end

function TagFuncs.div(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	return nil, nil, xmlobject[1]
end

function TagFuncs.countdown(xmlobject, codetable, markupindex, on_selection, missionlist, isactive, islast)
	if xmlobject.time then
		local endtime = tonumber(xmlobject.time)
		-- find diff between then and now.
		endtime = endtime - os.time()
--		endtime = gkmisc.DiffTime(gkmisc.GetGameTime() - tonumber(xmlobject.time))
		local difftime = math.max(0, endtime)
		return nil, format_time(difftime*1000, true)
	end
	return nil, nil, xmlobject[1]
end
