function navmenu_template(showjumpbutton, close_cb, issubsub)
	local update
	local zoombutton, navmap, desc
	local jumpbutton, distancetext, undolastbutton, systemnotesbutton
	local currentpath
	local clickedsector
	local clickedsystem
	local mapmode = true
	local notesdlg_visible = false
	local set

	SystemNotes = {}
	local system_notes_heading = '\n[Sector Notes]\n'

	-- heading to search/gsub on
	local system_notes_regexp_heading = '\n%[Sector Notes%]\n'

	local _multiline, _frame, _framebg
	if issubsub then
		_multiline = iup.stationsubsubmultiline
		_frame = iup.stationsubsubframe
		_framebg = iup.stationsubsubframebg
	else
		_multiline = iup.stationsubmultiline
		_frame = iup.stationsubframe
		_framebg = iup.stationsubframebg
	end

	if showjumpbutton then
		jumpbutton = iup.stationbutton{title="Jump", hotkey=iup.K_j}
		distancetext = iup.label{title="", expand="HORIZONTAL", alignment="ARIGHT"}

		function jumpbutton:action()
			local dist = radar.GetNearestObjectDistance()
			if dist < 0 or dist >= GetMinJumpDistance() then
				close_cb(self)
				gkinterface.GKProcessCommand("Activate")
			end
		end
	end
	navmap = iup.navmap{size="%55x350", expand="YES"}
	zoombutton = iup.stationbutton{title="Zoom to Universe", hotkey=iup.K_z}
	undolastbutton = iup.stationbutton{title="Undo last click", hotkey=iup.K_u}
	systemnotesbutton = iup.stationbutton{title="List Notes", hotkey=iup.K_l}
	desc = _multiline{value="", expand="YES", readonly="YES"}

	-- system notes stuff
	local function addnote()
		local id = tonumber(desc.index)
		if not id then return false end
		local  location, system
		
		if mapmode then -- sector
			location = ShortLocationStr(id)
			system = GetSystemID(id)
		else -- system
			location = SystemNames[id+1]
			desc.value = desc.value..'\n' -- needed because system text is not \n terminated
			system = id+1
			id = 'name'
		end
		-- open question dialog. 
		local dlg = msgpromptdlgtemplateml()
		--show system/sector, ok/cancel, text field.
		local note_to_add
		local edit = SystemNotes[system] and SystemNotes[system][id] and SystemNotes[system][id]:gsub("\\n","\n") or ''
		dlg:SetString(edit)
		dlg:SetMessage("Note to add to "..location, edit,
			"OK", function()
				HideDialog(dlg)
				note_to_add = dlg:GetString()
				-- if the new note is not equal to the old note then save it.
				if note_to_add ~= edit then
					SystemNotes[system][id] = note_to_add
					desc.value = desc.value..system_notes_heading..note_to_add
					SaveSystemNotes(spickle(SystemNotes[system]),system)
				end
			end,
			"Cancel", function() HideDialog(dlg) end
		)
		ShowDialog(dlg,iup.CENTER,iup.CENTER)
	end

	local function delnote()
		local id = tonumber(desc.index)
		if not id then return false end
		local location
		local system
		
		if mapmode then -- sector
			location = ShortLocationStr(id)
			system = GetSystemID(id)
		else -- system
			location = SystemNames[id+1]
			system = id+1
			id = 'name'
		end
		
		if SystemNotes[system] and SystemNotes[system][id] then
			-- open yes/no dialog. 
			local dlg = multidlgtemplate2()
			dlg:SetMessage('Delete note '..location..'?', SystemNotes[system][id]:gsub("\\n","\n"),
				"YES", function()
					desc.value = desc.value:gsub(SystemNotes[system][id],'')
					desc.value = desc.value:gsub(system_notes_regexp_heading,'')
					SystemNotes[system][id] = id == 'name' and '' or nil
					SaveSystemNotes(spickle(SystemNotes[system]),system)
					purchaseprint("Deleted note for "..location)
					HideDialog(dlg)
				end,
			"NO", function() HideDialog(dlg) end
			)
		ShowDialog(dlg,iup.CENTER,iup.CENTER)
		end
	end

	-- here we show a dialog box with the system notes on a matrix
	local function list_notes()
		local note_list
		local sort_tbl = {}
		
		local alpha, selalpha = ListColors.Alpha, ListColors.SelectedAlpha
		local even, odd, sel = ListColors[0], ListColors[1], ListColors[2]
		local bg_color = {
			[0] = even.." "..alpha,
			[1] = odd.." "..alpha,
			[2] = sel.." "..selalpha,
		}
		
		local dlg

		local oldrow
		local edit_button = iup.stationbutton{title='Edit', hotkey = iup.K_e}
		local cancel_button = iup.stationbutton{title='Close'}
		local del_button = iup.stationbutton{title='Delete', hotkey = iup.K_d}
		local help_button = iup.stationbutton{title='Help', hotkey = iup.K_F1,
			action=HelpSystemNotes}
		local errorlbl = iup.label{title=''}
		local num_record = iup.label{title=''}
					
		note_list = iup.pdasubsubmatrix{
			numcol=2,
			expand='YES',
			size='%75x%44',
			resize='YES',
			edition_cb = function() edit_button:action() return iup.IGNORE end }
		
		function cancel_button:action()
			HideDialog(dlg)
		end

		local search_text = iup.text{expand='HORIZONTAL',}
		
		
		dlg = iup.dialog{
			iup.stationhighopacityframe{
				iup.stationhighopacityframebg{
					iup.vbox{
						
						note_list,
						iup.hbox{
							edit_button, 
							del_button, 
							iup.fill{},
							errorlbl,
							iup.hbox{iup.label{title='Search:'},search_text,},
							iup.fill{}, 
							iup.hbox{iup.label{title='Matches:'},num_record,},
							help_button, 
							cancel_button, 
							gap=15, 
							alignment="ACENTER"
						},
					},
				},
			},
			topmost='YES',
			border='YES',
			menubox='NO',
			resize='NO',
			size='%80x%50',
			bgcolor="0 0 0 0 +",
			defaultesc=cancel_button,
			hide_cb = function() notesdlg_visible = false systemnotesbutton.active="YES" end,
		}
		dlg:map()

		local scrollbar_width = Font.Default
		local wid = getwidth(note_list) - scrollbar_width
		note_list['0:1'] = 'Location'
		note_list.WIDTH1 = wid /3
		note_list.ALIGNMENT1 = 'ALEFT'
		note_list:setattribute("FGCOLOR", 0, 1, tabunseltextcolor)
		
		note_list['0:2'] = 'Sector/System Notes'
		note_list.WIDTH2 = wid * 2 /3
		note_list.ALIGNMENT2 = 'ALEFT'
		note_list:setattribute("FGCOLOR", 0, 2, tabunseltextcolor)
		
		-- purge matrix, fill, sort and dumps data into the matrix.
		local function reset_matrix()
			local systemnote_errors = 0
			sort_tbl = {}
			
			for system,system_data in pairs(SystemNotes) do
				for systemid,sectorid in pairs(system_data) do
					-- this changes all the regexp characters into % prefixed.
					local search_string = search_text.value:gsub("[%^%$%(%)%%%.%-%[%]]", "%%%1")
					--

					-- this dumps all words into wordtbl, for searches
					-- format of: bractus tycorp
					--   searchs for 'bractus' and 'tycorp'
					-- format of: helio "devus d3"
					--   search for 'helio' and 'devus d3'
					local wordtbl = {}
					local rest = search_string:lower():gsub([[(["'])(.-)%1]], function (_, s) table.insert(wordtbl,s:lower()) return ' ' end)
					for word in rest:gmatch("(%S+)%s*") do 
						table.insert( wordtbl, word:lower()) 
					end
					
			-- this searches wordtbl for matches in system/sector and note
			local function find_match(string1, string2)
				local count = 0
				string1 = filter_colorcodes(tostring(string1):lower()) -- system/sector
				string2 = filter_colorcodes(tostring(string2):lower()) -- notes
				for k,v in pairs(wordtbl) do
					if v:match('\^%%%-') then -- use -<word> matches
						v = v:gsub('\^%%%-','')
						if not (string1:match(v) or string2:match(v)) then
							count = count + 1
						end
					elseif string1:match(v) or string2:match(v) then
						count = count + 1
					end
				end
				-- if all phrases match then we have a listing
				if count == #wordtbl or #wordtbl == 0 then return true
				else return false end
			end -- end function
					
					if systemid == 'error' then
						systemnote_errors = systemnote_errors + 1
						table.insert(sort_tbl,{system,'(*) '..sectorid})

					-- this is for systems
					elseif systemid == 'name' and #sectorid > 0 and find_match(SystemNames[system],sectorid) then
						table.insert(sort_tbl,{system,sectorid})

					-- this is for sectors
					elseif systemid ~= 'name' and find_match(LocationStr(systemid),sectorid) then
						table.insert(sort_tbl,systemid)
					end
				end
			end

			local error_flag = {} -- flag show errors do not show up in the matrix more than once

			-- sorts by system name first, then all sectors under that.
			table.sort(sort_tbl,function(a,b)
				if type(a) == 'table' then 
					a = SystemNames[a[1]]
				elseif type(a) == 'number' then 
					a = LocationStr(a) 
				end
				if type(b) == 'table' then 
					b = SystemNames[b[1]]
				elseif type(b) == 'number' then 
					b = LocationStr(b) 
				end
				return a < b
			end)

			note_list.dellin = "1--1"
			local location,note
			for line,v in ipairs(sort_tbl) do
				-- v = id, Sector_Note_Tbl[id][v] = note
				if tonumber(v) then -- number means sector
					location = LocationStr(v)
					note = SystemNotes[GetSystemID(v)][v]:gsub("\n","\\n")
				elseif type(v) == 'table' then	--table means system
					location = SystemNames[v[1]]
					if SystemNotes[v[1]].error and not error_flag[v[1]] then
						note = '(*) '..SystemNotes[v[1]].error
						error_flag[v[1]] = v
					else
						note = SystemNotes[v[1]].name
					end
				end
				note_list.ADDLIN = line
				note_list:setcell(line, 1, location)
				note_list:setcell(line, 2, note)
				note_list:setattribute("BGCOLOR",line,-1,bg_color[math.fmod(line,2)])
			end
			
			if systemnote_errors > 0 then
				errorlbl.title = '(*) Errors: [\127ff0000'..systemnote_errors..'\127FFFFFF]'
			else
				errorlbl.title = ''
			end

			-- # record label
			num_record.title = #sort_tbl
		end
		
		function note_list:click_cb(line,col)
			if line == 0 then
				if oldrow then note_list:setattribute('BGCOLOR',oldrow,-1,bg_color[2]) end
			else
				if oldrow then note_list:setattribute('BGCOLOR',oldrow,-1,bg_color[math.fmod(oldrow,2)]) end
				note_list:setattribute('BGCOLOR',line,-1,bg_color[2])
				oldrow = line
			end
		end

		function edit_button:action()
			-- dialog box here, yes/no
			if oldrow then 
				local error_flag = false -- if we are going to replace the errors
				local confirm = msgpromptdlgtemplateml()
				local value = sort_tbl[oldrow]
				if not value then return end
				local location, note, system, id
				if type(value) == 'table' then -- system
					id = 'name'
					location = SystemNames[value[1]]
					system = value[1]
					note = value[2] --SystemNotes[system].name
				else -- sector
					id = value					
					location = ShortLocationStr(value)
					system = GetSystemID(value)
					note = SystemNotes[system][value]:gsub("\n","\\n")
				end
				if note:match("\(\*\)") then
					-- allow the user to turn error listings into labels for the system
					note = SystemNotes[system].error
					error_flag = true
				else
					error_flag = false
				end
--				confirm:SetString(note or '')
				confirm:SetMessage('Edit note '..location..'?',note:gsub("\\n","\n") or '',
					"OK", function()
						if note then
							SystemNotes[system][id] = confirm:GetString()
							if error_flag then
								SystemNotes[system].error = nil
								error_flag = false
							end
							reset_matrix()
							oldrow = nil
							SaveSystemNotes(spickle(SystemNotes[system]),system)
							purchaseprint(" note for "..location.." changed.")
							HideDialog(confirm)
						end
					end,
					"Cancel", function() reset_matrix() HideDialog(confirm) end
					)
				ShowDialog(confirm,iup.CENTER,iup.CENTER)
			end
		end

		function search_text:action(key)
			if key == iup.K_CR or key == 13 then  -- iup.K_CR issues not being 13
				reset_matrix() 
			end
		end 

		--deletes the current line and refreshes the matrix
		function del_button:action()
			-- dialog box here, yes/no
			if oldrow then 
				local error_flag = false -- error checking
				local confirm = multidlgtemplate2()
				local value = sort_tbl[oldrow]
				if not value then return end
				local location, note, system, id
				if type(value) == 'table' then -- system
					id = 'name'
					location = SystemNames[value[1]]
					system = value[1]
					note = value[2] --SystemNotes[system].name
				else -- sector
					id = value					
					location = ShortLocationStr(value)
					system = GetSystemID(value)
					note = SystemNotes[system][value]
				end
				if note:match("\(\*\)") then
					-- allow the user to turn error listings into labels for the system
					note = SystemNotes[system].error
					error_flag = true
				else
					error_flag = false
				end
				note = note:gsub("\\n","\n")
				confirm:SetMessage('Delete note '..location..'?', note,
					"YES", function()
						if note then
							SystemNotes[system][id] = id == 'name' and '' or nil
							if error_flag then
								SystemNotes[system].error = nil
								error_flag = false
							end
							reset_matrix()
							oldrow = nil
							SaveSystemNotes(spickle(SystemNotes[system]),system)
							purchaseprint("Deleted note for "..location)
							HideDialog(confirm)
						end
					end,
					"NO", function() reset_matrix() HideDialog(confirm) end
					)
				ShowDialog(confirm,iup.CENTER,iup.CENTER)
			end
		end -- end function del_button

		-- fill the matrix with our stuff and show the dialog box
		reset_matrix()
		ShowDialog(dlg, iup.CENTER,iup.CENTER)
	end


	function systemnotesbutton:action()
		if not notesdlg_visible then
			list_notes()
			notesdlg_visible = true
			if self.active == "YES" then self.active = "NO" end
		end
	end
	
	function zoombutton:action()
		mapmode = not mapmode
		
		set()
		--[[
		if not mapmode then
			zoombutton.title="Zoom to System"
			navmap:loadmap(1,"lua/maps/universemap.lua",0)
			navmap.currentid = GetCurrentSystemid() - 1
			navmap.clickedid = clickedsystem - 1
		else
			zoombutton.title="Zoom to Universe"
			navmap:loadmap(2,string.format("lua/maps/system%02dmap.lua",clickedsystem), clickedsystem-1)
			navmap.currentid = GetCurrentSectorid()
			navmap.clickedid = clickedsector
		end
		navmap:setpath(currentpath)
		--]]
	end

	function navmap:mouseover_cb(index, str)
		local note = ""
		local id = tonumber(index) or index
		local system
		local conqueringfaction

		if not mapmode then
			if SystemNotes[id+1] and #SystemNotes[id+1].name > 0  then -- system
				-- need to format for system text, not \n terminated
				note = '\n'..system_notes_heading..(SystemNotes[id+1].name or "")
			end
		elseif mapmode then
			system = GetSystemID(id)
			if SystemNotes[system] and SystemNotes[system][id] then-- sector
				note = system_notes_heading..(SystemNotes[system][id]:gsub("\\n","\n") or "")
			end
			note = (GetBotSightedInfoForSector(id) or "")..note

			conqueringfaction = GetConqueredStatus(id)
		end
		if conqueringfaction then
			desc.value = "Currently controlled by "..FactionArticle[conqueringfaction].." "..FactionNameFull[conqueringfaction].."\n\n"..(str and string.gsub(str, "|", "\n") or "")..note
		else
			desc.value = (str and string.gsub(str, "|", "\n") or "")..note
		end
		desc.index = index
	end

	function navmap:click_cb(index, modifiers)
		if not mapmode then
			clickedsystem = index + 1
		else

			-- if player is not in a training sector, warn them that they will be fired upon if they enter a training sector.
			if (GetCurrentSectorid() ~= index) and IsTrainingSector(index) then
				local continue
				QuestionDialog:SetMessage("WARNING!\nIf you enter a training sector, you will be shot on sight!\nDo you want to continue?",
					"Yes", function() continue=true return iup.CLOSE end,
					"No", function() return iup.CLOSE end,
					"ACENTER")
				PopupDialog(QuestionDialog, iup.CENTER, iup.CENTER)
				
				if not continue then
					navmap.clickedid = clickedsector
					return
				end
			end

			clickedsector = index

			if string.byte(modifiers, 1) == iup.K_S then
				if NavRoute.GetFinalDestination() == index then
					NavRoute.undo()
				else
					NavRoute.addbyid(index)
				end
			else
				if index == GetCurrentSectorid() then
					NavRoute.clear()
				else
					NavRoute.SetFinalDestination(index)
				end
			end
			update()
		end
	end

	set = function()
		if mapmode then
			zoombutton.title="Zoom to Universe"
			navmap:loadmap(2,string.format("lua/maps/system%02dmap.lua",clickedsystem), clickedsystem-1)
			navmap.currentid = GetCurrentSectorid()
			navmap.clickedid = clickedsector
			
			-- display conquered sectors in displayed system
			local sectors = GetConqueredSectorsInSystem(clickedsystem)
			if sectors then
				for sectorid,faction in pairs(sectors) do
					navmap["COLOR"..sectorid] = ShipPalette_string[FactionColor[faction]]
				end
			end
		else
			zoombutton.title="Zoom to System"
			navmap:loadmap(1,"lua/maps/universemap.lua",0)
			navmap.currentid = GetCurrentSystemid() - 1
			navmap.clickedid = clickedsystem - 1
		end
		navmap:setpath(currentpath)
	end

	local function setup()
		local cursec = GetCurrentSectorid()
		clickedsector = NavRoute.GetFinalDestination() or cursec
		clickedsystem = GetSystemID(cursec)
		currentpath = GetFullPath(cursec, NavRoute.GetCurrentRoute())
		set()
	end

	local function init()
		mapmode = true
		zoombutton.title="Zoom to Universe"
		desc.value = ""
		if showjumpbutton then
			distancetext.title = ""
			jumpbutton.active = "NO"
		end
		if NavRoute.GetFinalDestination() then
			undolastbutton.active = "YES"
		else
			undolastbutton.active = "NO"
		end
		setup()
	end

	update = function()
		currentpath = GetFullPath(GetCurrentSectorid(), NavRoute.GetCurrentRoute())
		navmap:setpath(currentpath)

		if NavRoute.GetFinalDestination() then
			undolastbutton.active = "YES"
		else
			undolastbutton.active = "NO"
		end
	end

	local function enter_sector()
		setup()
	end

	local function undo_last()
		clickedsector = NavRoute.GetFinalDestination() or GetCurrentSectorid()
		if mapmode then
			navmap.clickedid = clickedsector
		end
		update()
	end
	undolastbutton.action = function() NavRoute.undo() end

	local buttonarea
	if showjumpbutton then
		buttonarea = iup.vbox{
			distancetext,
			iup.hbox{zoombutton,iup.fill{},jumpbutton, alignment="ACENTER"},
			iup.hbox{undolastbutton,iup.fill{},systemnotesbutton},
			anignment="ARIGHT",
			gap=2,
			margin="2x2",
		}
	else
		buttonarea = iup.vbox{
			iup.hbox{zoombutton,iup.fill{}, alignment="ACENTER"},
			iup.hbox{undolastbutton,iup.fill{},systemnotesbutton},
			anignment="ARIGHT",
			gap=2,
			margin="2x2",
		}
	end

	local container
	if issubsub then
		container = 
			iup.hbox{
				_frame{
					iup.hbox{navmap},
				},
				iup.stationsubsubframehdivider{size=5},
				iup.vbox{
					desc,
					_framebg{
						buttonarea
					},
				},
			}
	else
		container = 
			iup.hbox{
				_frame{
					iup.hbox{navmap, margin="-5x-5"},
				},
				iup.vbox{
					desc,
					_framebg{
						buttonarea
					},
				},
			}
	end

	container.init = init
	container.setup = setup
	container.update = update
	container.undo_last = undo_last
	container.enter_sector = enter_sector
	container.update_conquered_sectors = set

	function container:k_any(key)
		if key == iup.K_a then 
			addnote()
		elseif key == iup.K_d then 
			delnote()
		elseif key == iup.K_j or 
			key == iup.K_u or
			key == iup.K_z then
			return iup.IGNORE
		end		
		return iup.CONTINUE
	end

	function container.SetClickedSector(newsectorid)
		clickedsector = newsectorid
		if mapmode then
			navmap.clickedid = clickedsector
		end
		update()
	end
	function container.SetDesc(str)
		desc.value = str
	end

	return container, distancetext, jumpbutton, zoombutton, undolastbutton
end
