-- missions menu
local function create_notestab()

	local container
	local edit = {} -- table of all mission list tabs.
	
	--MAX_TABS for now is a constant 9 value.
	-- several reference points below use it.
	local MAX_TABS = 9 -- 9 because 10 makes the dialog too tall for 800x600.

	local function save_tabs()
	 local savetxt = ""
		for x = 1,MAX_TABS do 
			savetxt = savetxt.."###BEGINPAGE"..x.."###"..edit[x].value.."###ENDPAGE"..x.."###"
		end
		SaveMissionNotes(savetxt)
	end

	for x = 1,MAX_TABS do
		 edit[x] = iup.stationsubsubmultiline{expand="YES", size="1x1"}
		 edit[x].tabtitle = gkini.ReadString(GetPlayerName(), "Tab"..x, "Page "..x) 
		-- on quirk here, 10 tabs, 1-9 = page 1-9, page 10 = 0
		if x == 10 then edit[x].hotkey=iup.K_0
		else edit[x].hotkey=iup.K_0 + x
		end
	 end

	--	local edittabs = iup.roottabtemplate{unpack(edit)}
	--sub_tabs works
	-- pda_sub_tabs works but puts some clietns off the screen, bottom
	local edittabs = iup.roottabtemplate{
		tabchange_cb = function(self,new,old) save_tabs() end,
		unpack(edit),
		}

	container = iup.vbox{
		iup.pdasubsubframebg{iup.label{title="Notes: Select page number to view", expand="HORIZONTAL"},},
		edittabs,
	}

	function container:OnShow()
		local mission_txt = LoadMissionNotes()
		if string.find(mission_txt, "###BEGINPAGE1###") and string.find(mission_txt, "###ENDPAGE1###") then
			for x = 1,MAX_TABS do
				edit[x].value = string.match(mission_txt, "###BEGINPAGE"..x.."###(.-)###ENDPAGE"..x.."###")
			end
		elseif string.find(mission_txt, "###BEGINPAGE1###") == nil and string.find(mission_txt, "###ENDPAGE1###") == nil then
			edit[1].value = tostring(mission_txt)
		end
	end

	function container:OnHide()
		save_tabs()
	end
	return container
end

local function create_advancementtab()
	local isvisible = false
	local multiline = iup.stationsubsubmultiline{readonly="YES", expand="YES", size="1x1"}
	local scrolledback = false
	local container
	local loglines = {}

	container = iup.hbox{
		multiline
	}

	RegisterEvent(container, "CHAT_MSG_SECTORD_MISSION")
	RegisterEvent(container, "CHAT_MSG_MISSION")
	RegisterEvent(container, "PLAYER_ENTERED_GAME")

	local queue = {}

	function container:OnShow()
		isvisible = true
		local wasscrolledback = scrolledback
		if next(queue) then
			for k,v in ipairs(queue) do
				table.insert(loglines, v)
			end
			local newstr = table.concat(loglines, "\n")
			local len = string.len(newstr)
			while len > 32000 do
				-- if it's too long, remove the oldest ones.
				len = len - (string.len(loglines[1])+1)
				table.remove(loglines, 1)
				newstr = nil
			end
			newstr = newstr or table.concat(loglines, "\n")
			multiline.value = newstr
			queue = {}
		end
		if not wasscrolledback then
			multiline.scroll = "BOTTOM"
		end
	end
	function container:OnHide()
		isvisible = false
	end
	function container:OnEvent(eventname, ...)
		local arg1 = ...
		if ((eventname == "CHAT_MSG_SECTORD_MISSION") and ((arg1.missionid or 0) == 0)) or 
			((eventname == "CHAT_MSG_MISSION") and ((arg1.missionid or 0) == 0))  then
			if isvisible then
				table.insert(loglines, arg1.msg)
				local newstr = table.concat(loglines, "\n")
				local len = string.len(newstr)
				while len > 32000 do
					-- if it's too long, remove the oldest ones.
					len = len - (string.len(loglines[1])+1)
					table.remove(loglines, 1)
					newstr = nil
				end
				newstr = newstr or table.concat(loglines, "\n")
				local wasscrolledback = scrolledback
				multiline.value = newstr
--				multiline.append = "\n"
				if not wasscrolledback then
					multiline.scroll = "BOTTOM"
				end
			else
				table.insert(queue, arg1.msg)
			end
		elseif eventname == "PLAYER_ENTERED_GAME" then
			loglines = {}
			multiline.value = ""
			scrolledback = false
			queue = {}
		end
	end

	-- make sure last line is visible unless player is scrolled up
	function multiline:caret_cb(r,c)
		if r == 1 then
			scrolledback = false
		else
			scrolledback = true
		end
	end

	return container
end

local function add_text(text, color, missionstatus, missionstatus_elements)
	if string.sub(text, -1) == "\n" then
		text = string.sub(text, 1, -2)
	end
	local control = iup.label{title=text, fgcolor=color}
	iup.Append(missionstatus, control)
	table.insert(missionstatus_elements, control)
end
local function add_controls(controls, missionstatus, missionstatus_elements, isactive)
	local dlg = iup.dialog{
		iup.vbox(controls),
		bgcolor="0 0 0 0 +",
		border="NO",menubox="NO",resize="NO",
		active=isactive and "YES" or "NO",
	}
	iup.Append(missionstatus, dlg)
	table.insert(missionstatus_elements, dlg)
end

local function recursetags(choices, curstr, missionstatus, missionstatus_elements, tag, codetable, markupindex, on_selection, missionlist, isactive, islast)
	local thetype = type(tag)
	if thetype == "table" then
		local tagfunc = TagFuncs[ tag[0] ]
		if tagfunc then
			local control, text, recurse = tagfunc(tag, codetable, markupindex, on_selection, missionlist, isactive, islast)
			if control then
				table.insert(choices, control)
			elseif text then
				curstr = (curstr and (curstr..tostring(text))) or tostring(text)
			elseif recurse then
				choices, curstr = recursetags(choices, curstr, missionstatus, missionstatus_elements, recurse, codetable, markupindex, on_selection, missionlist, isactive, islast)
			end
		end
	elseif thetype == "string" and tag ~= "" then
		-- add controls that are ready
		if next(choices) then
			-- add the text we already had before the buttons
			if curstr then
				add_text(curstr, islast and isactive and "255 255 255" or "160 160 160", missionstatus, missionstatus_elements)
			end
			add_controls(choices, missionstatus, missionstatus_elements, isactive)
			choices = {}
			curstr = tag
		else
			curstr = (curstr and (curstr..tag)) or tag
		end
	end

	return choices, curstr
end

local function fill_mission_log(isactive, strtable, missionstatus, missionstatus_elements, on_selection, missionlist)
	local numlines = (#strtable)
	for _index,codetable in ipairs(strtable) do
		local islast = (_index == numlines)
		local curstr
		local choices = {}
		for k,v in ipairs(codetable) do
			choices, curstr = recursetags(choices, curstr, missionstatus, missionstatus_elements, v, codetable, k, on_selection, missionlist, isactive, islast)
		end
		if curstr then
			add_text(curstr, islast and isactive and "255 255 255" or "160 160 160", missionstatus, missionstatus_elements)
		end
		if next(choices) then
			add_controls(choices, missionstatus, missionstatus_elements, isactive)
		end
	end
end

local bulletimage = "images/treeleaf.png" -- IMAGE_DIR.."radio_bg.png"
local checkimage = IMAGE_DIR.."check.png"

local function create_missionlogtab()
	local isvisible = false
	local container
	local curlist_lut
	local fill_missionstatus
	local selectthisone
	local missionobjectivecontainer

	local missionlist = iup.stationsubsublist{expand="VERTICAL", size="THIRDx1", marginx="3"}
	local missionobjectives = iup.stationsubsublist{control="YES", expand="YES", size="1x1", marginx="3"}
	local missionobjectivesseparator = iup.stationsubsubframevdivider{size=4}
	local missionstatus = iup.stationsubsublist{control="YES", expand="YES", size="1x175", marginx="3"}
	local missionstatus_elements = {}
	local missionobjectives_elements = {}
	local abortmissionbutton = iup.stationbutton{
		title="Abort",
		action=function()
			local index = tonumber(missionlist.value)
			local i = curlist_lut and curlist_lut[index]
			local name, strtbl, id = GetActiveMissionInfo(i)
			function MissionAbortDialog.yes_fn()
				AbortMission(id)
			end
			MissionAbortDialog.no_fn = nil
			ShowDialog(MissionAbortDialog, iup.CENTER, iup.CENTER)
		end,
		}

	missionobjectivecontainer = iup.vbox{missionobjectives, missionobjectivesseparator}

	container = iup.hbox{
			missionlist,
			iup.stationsubsubframehdivider{size=5},
			iup.vbox{
				missionobjectivecontainer,
				missionstatus,
				iup.stationsubsubframebg{
					iup.hbox{iup.fill{}, abortmissionbutton, expand="YES", margin="2x"},
				},
			},
		}

	local function clear_missionstatus()
		missionstatus[1] = nil
		missionstatus.value = 0
		local curfocus = iup.GetFocus()
		if curfocus and iup.GetType(curfocus) ~= "text" then
			iup.SetFocus(missionstatus) -- because button being destroyed may have focus
		end
		if next(missionstatus_elements) then
			for k,v in pairs(missionstatus_elements) do
				v:destroy()
			end
			missionstatus_elements = {}
		end
	end
	local function clear_missionobjectives()
		missionobjectives[1] = nil
		missionobjectives.value = 0
		if next(missionobjectives_elements) then
			for k,v in pairs(missionobjectives_elements) do
				v:destroy()
			end
			missionobjectives_elements = {}
		end
	end

	local function on_selection(index, forceactive)
		if not isvisible then return end
		local name, strtbl, id, finishedreason, objectives
		local i = curlist_lut[index]
		if not i then
			fill_missionstatus({index==1 and {"You do not currently have a mission. Go to the Mission Board to sign up for a new mission."} or {""}}, nil, false)
			return
		end
		if i > 0 then
			name, strtbl, id, objectives = GetActiveMissionInfo(i)
		else
			name, strtbl, id, finishedreason, objectives = GetFinishedMissionInfo(-i)
		end
		fill_missionstatus(strtbl, objectives, (forceactive==nil) and i > 0 or forceactive)
	end

	fill_missionstatus = function(strtable, objectives, isactive)
		if not isvisible then return end
		clear_missionstatus()
		fill_mission_log(isactive, strtable, missionstatus, missionstatus_elements, on_selection, missionlist)
		missionstatus:map()
		missionstatus[1] = 1
		abortmissionbutton.active = isactive and "YES" or "NO"
		
		if objectives and (#objectives > 0) then
			clear_missionobjectives()

			-- add objective list and force parent to recalc control positions.
			iup.Append(missionobjectivecontainer, missionobjectives)
			iup.Append(missionobjectivecontainer, missionobjectivesseparator)
			iup.Refresh(container)

			-- fill in objectives
			local items = {}
			for index,row in ipairs(objectives) do
				local col = (isactive and (row.done~="yes") and "255 255 255") or "128 128 128"
				local img = (row.done=="yes") and checkimage or bulletimage
				img = iup.label{title="",image=img}
--				local img = iup.stationtoggle{active="NO",value=(row.done=="yes") and "ON" or "OFF"}
				table.insert(items, iup.hbox{expand="HORIZONTAL", iup.fill{size="10"}, img, iup.label{fgcolor = col, title=tostring(row[1])}})
			end
			add_controls(items, missionobjectives, missionobjectives_elements, false)
			
			-- finalize
			missionobjectives:map()
			missionobjectives[1] = 1
			missionobjectives.scroll = "TOP"
		else
			clear_missionobjectives()

			-- remove objective list and force parent to recalc control positions.
			iup.Detach(missionobjectives)
			iup.Detach(missionobjectivesseparator)
			iup.Refresh(container)
		end
		missionstatus.scroll = "BOTTOM"
	end

	function missionlist:action(_, index, selection_state)
		if selection_state == 1 then
			on_selection(index)
			iup.SetFocus(self)
		else
			clear_missionstatus()
			clear_missionobjectives()
		end
	end

	local function set_selmission(missionid)
		if not missionid then
			missionlist.value = 0
			return
		end
		local name, str, id, finishedreason, objectives
		local curselmission = tonumber(missionlist.value or 0)
		for k,i in pairs(curlist_lut) do
			if i > 0 then
				name, str, id, objectives = GetActiveMissionInfo(i)
			else
				name, str, id, finishedreason, objectives = GetFinishedMissionInfo(-i)
			end
			if id == missionid and curselmission ~= k then
				missionlist.value = k
				return
			end
		end
	end

	local function update_mission(missionid)
		local index = tonumber(missionlist.value)
		local i = curlist_lut and curlist_lut[index]
		if not i then
			fill_missionstatus({index==1 and {"You do not currently have a mission. Go to the Mission Board to sign up for a new mission."} or {""}}, nil, false)
			return
		end
		local name, strtbl, id, finishedreason, objectives
		if i > 0 then
			name, strtbl, id, objectives = GetActiveMissionInfo(i)
		else
			name, strtbl, id, finishedreason, objectives = GetFinishedMissionInfo(-i)
		end
		if not missionid or id == missionid then
			fill_missionstatus(strtbl, objectives, i > 0)
		end
	end

	local function update_list()
		curlist_lut = {}
		local nummissions = GetNumActiveMissions()
		local j = 1
		local selectthisone_index
		for i=1,nummissions do
			local missionname, str, id = GetActiveMissionInfo(i)
			if selectthisone == id then selectthisone_index = j end
			missionlist[j] = missionname
			curlist_lut[j] = i
			j = j + 1
		end
		-- add a 'No Current Mission' if there's no active mission
		if nummissions == 0 then
			missionlist[j] = "No Current Mission"
			j = j + 1
		end

		missionlist[j] = ""
		j = j + 1

		nummissions = GetNumFinishedMissions()
		for i=1,nummissions do
			local missionname, missionstr, id, finishedreason = GetFinishedMissionInfo(i)
			if not selectthisone_index and (selectthisone == id) then selectthisone_index = j end
			missionlist[j] = missionname.." ("..(finishedreason or "Completed")..")"
			curlist_lut[j] = -i
			j = j + 1
		end
		missionlist[j] = nil

		if selectthisone_index then
			missionlist.value = selectthisone_index
			selectthisone = nil
		else
			if tonumber(missionlist.value) == 0  and j > 1 then
				missionlist.value = 1
			end
		end
	end

	local function receive_mission_msg(msg, missionid)
		if missionid == 0 then return end
		update_mission(missionid)
	end

	function container:OnShow()
		isvisible = true
		update_list()
		update_mission(nil)
		HUD:HideMissionIndicator()
	end
	function container:OnHide()
		isvisible = false
		HUD:HideMissionIndicator()
	end

	RegisterEvent(container, "CHAT_MSG_SECTORD_MISSION")
	RegisterEvent(container, "CHAT_MSG_MISSION")
	RegisterEvent(container, "MISSION_NOTIFICATION")
	RegisterEvent(container, "MISSION_ADDED")
	RegisterEvent(container, "MISSION_REMOVED")
	RegisterEvent(container, "MISSION_UPDATED")
	function container:OnEvent(eventname, ...)
		local arg1 = ...
		if (eventname == "CHAT_MSG_SECTORD_MISSION") and ((arg1.missionid or 0) ~= 0) then
			receive_mission_msg(arg1.msg, arg1.missionid or 0)
		elseif (eventname == "CHAT_MSG_MISSION") and ((arg1.missionid or 0) ~= 0) then
			receive_mission_msg(arg1.msg, arg1.missionid or 0)
		elseif eventname == "MISSION_NOTIFICATION" then
			gksound.GKPlaySound("mission.updated")
			HUD:ShowMissionIndicator()
		elseif eventname == "MISSION_ADDED" or
			eventname == "MISSION_REMOVED" or
			eventname == "MISSION_UPDATED" then
			if eventname == "MISSION_UPDATED" then
				-- mission was updated, select it.
				if not curlist_lut then
					update_list()
				end
				set_selmission(arg1)
			elseif eventname == "MISSION_ADDED" then
				selectthisone = arg1
			else -- MISSION_REMOVED
				selectthisone = arg1
			end
			if isvisible then
				update_list()
				update_mission(nil)
			end
		end
	end

	return container
end

local function create_tab4()
	local container

	container = iup.hbox{iup.vbox{}}
	function container:OnShow()
	end
	function container:OnHide()
	end

	return container
end

function CreateMissionsPDATab()
	local tab1, tab2, tab3, tab4, tab4infobutton

	tab1 = create_notestab() tab1.tabtitle="Mission Notes" tab1.hotkey=iup.K_1
	tab2 = create_advancementtab() tab2.tabtitle="Advancement Logs"  tab2.hotkey=iup.K_v
	tab3 = create_missionlogtab() tab3.tabtitle="Mission Logs"  tab3.hotkey=iup.K_l
	tab4, tab4infobutton = CreateStationMissionBuyTab() tab4.tabtitle="Mission Board"  tab4.hotkey=iup.K_b

	tab1.OnHelp = HelpPDAMissionNotes
	tab2.OnHelp = HelpPDAAdvancementLog
	tab3.OnHelp = HelpPDAMissionLog
	tab4.OnHelp = HelpStationMission

	return iup.subsubtabtemplate{tab4, tab3, tab1, tab2}, tab1, tab2, tab3, tab4, tab4infobutton
end
