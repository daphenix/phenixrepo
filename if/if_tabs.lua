function iup.root_tabs(params)
	local whole
	local tabtextfont = params.font or Font.H4
	local tabpartheight = tabtextfont*1.5
	local tabchange_cb = params.tabchange_cb
	local upper_left_imagename = params.upperleftimage or (IMAGE_DIR.."root_tab_left.png")
	local upper_left_imagesize = params.upperleftsize or ("19x"..tabpartheight)
	local upper_left_imagesegments = params.upperleftsegments or "1 0 1 0"
	local upper_right_imagename = params.upperrightimage or (IMAGE_DIR.."root_tab_right.png")
	local upper_right_imagesize = params.upperrightsize or ("x"..tabpartheight)
	local upper_right_imagesegments = params.upperrightsegments or "0 0 .5 0"
	local upper_spacer_imagename = params.upperspacerimage or (IMAGE_DIR.."root_tab_spacer.png")
	local upper_spacer_imagesegments = params.upperspacersegments or "0 0 .5 0"
	local border_imagename = params.borderimagename or (IMAGE_DIR.."root_tab_border.png")
	local border_imagesegments = params.borderimagesegments or "0.265625 0 0.734375 0.46875"  -- 8.5 0 23.5 17.5
	local tab_sel_imagename = params.selimage or (IMAGE_DIR.."root_tab_sel.png")
	local tab_unsel_imagename = params.unselimage or (IMAGE_DIR.."root_tab_unsel.png")
	local tab_imagecenteruv = params.imagecenteruv or "0.375 0.46875 0.53125 0.46875" -- 11 16 19 16  -> 12 15 17 15
	local color = "255 255 255 255 *"
	local zboxargs = {}
	local zbox
	local curtab
	local seltextcolor = params.seltextcolor or "255 255 255"
	local unseltextcolor = params.unseltextcolor or "128 128 128"
	local upperleftimage = iup.label{title="", image=upper_left_imagename, segmented=upper_left_imagesegments, size=upper_left_imagesize, expand="NO", bgcolor=color}
	local buttonlist = {upperleftimage}
	local i=1
	for k,t in ipairs(params) do
		local button
		local tab = t
		if tab.spacer == true then
			button = iup.frame{
				iup.vbox{iup.hbox{iup.label{title="",expand=tab.expand, size=tab.size}},iup.fill{}},
				image=upper_spacer_imagename,
				segmented=upper_spacer_imagesegments,
				border = "0 0 0 0",
				expand="YES",
				bgcolor="255 255 255 255 *",
			}
		else
			zboxargs[i] = tab
			button = iup.button{title=tab.tabtitle or 'tab'..i,
				hotkey=tab.hotkey,
				size="x"..tabpartheight,
				font=tabtextfont,
				image=i==1 and tab_sel_imagename or tab_unsel_imagename,
				impressed=i==1 and tab_sel_imagename or tab_unsel_imagename,
				bgcolor=color,
				fgcolor=i==1 and seltextcolor or unseltextcolor,
				centeruv=tab_imagecenteruv,
				action=function(self)
					local oldvalue = zbox.value
					zbox.value = tab
					if self ~= curtab then
						if curtab then
							curtab.image=tab_unsel_imagename
							curtab.impressed=tab_unsel_imagename
							curtab.fgcolor=whole.unseltextcolor
						end
						curtab = self
						self.image=tab_sel_imagename
						self.impressed=tab_sel_imagename
						self.fgcolor=whole.seltextcolor
					end
					if tabchange_cb then tabchange_cb(whole, tab, oldvalue) end
				end}
			curtab = curtab or button
			i=i+1
		end

		table.insert(buttonlist, button)
	end

--	local upperrightimage = iup.label{title="", image=upper_right_imagename, segmented=upper_right_imagesegments, size=upper_right_imagesize, expand="HORIZONTAL", bgcolor=color}
	local upperrightimage = iup.frame{
				iup.vbox{iup.hbox{iup.fill{}}, iup.fill{}},
				image=upper_right_imagename,
				segmented=upper_right_imagesegments,
				border = "0 0 0 0",
				expand="YES",
				bgcolor=color,
			}

	if params.alignment == "ABOTTOM" then
		-- swap them because we want the anchor to be on the right side.
		upperrightimage, upperleftimage = upperleftimage, upperrightimage
		buttonlist[1] = upperleftimage
	end

	table.insert(buttonlist, upperrightimage)
	local topregion = iup.hbox(buttonlist)
	zbox = iup.zbox(zboxargs)
	local bottomregion = iup.frame{iup.vbox{iup.hbox{zbox, iup.fill{}}, iup.fill{}}, image=border_imagename, segmented=border_imagesegments, expand="YES", bgcolor=color}
	if params.alignment == "ABOTTOM" then
		-- swap them because we want the tabs to be on the bottom
		topregion, bottomregion = bottomregion, topregion
	end
	whole = iup.vbox{topregion, bottomregion, expand="YES"}
	whole.seltextcolor = seltextcolor
	whole.unseltextcolor = unseltextcolor

	for k,t in ipairs(params) do
		buttonlist[t] = buttonlist[k+1]
	end

	function whole:SetTabTextColor(index, color)
		buttonlist[index].fgcolor = color
	end
	function whole:SetTabText(index, str)
		buttonlist[index].title = str
	end
	function whole:SetTab(index)
		if buttonlist[index].action then
			buttonlist[index]:action()
		end
	end
	function whole:GetTab()
		return zbox.value
	end
	function whole:GetTabButton(index)
		return buttonlist[index]
	end

	return whole
end

function iup.sub_tabs(params)
	local whole
	local tabchange_cb = params.tabchange_cb
	
	local upper_left_imagename = params.upperleftimage
	local upper_left_imagesize = params.upperleftsize
	local upper_left_imagesegments = params.upperleftsegments
	local upper_right_imagename = params.upperrightimage or (IMAGE_DIR.."commerce_tab_right_small.png")
	local upper_right_imagesize = params.upperrightsize or "8x8"
	local upper_right_imagesegments = params.upperrightsegments or "1 0 1 0"
	local border_imagename = params.borderimagename or (IMAGE_DIR.."commerce_tab_border.png")
	local border_imagesegments = params.borderimagesegments or "0.8125 0.40625 1 0.59375" -- 6.5 6.5 8 9.5
	local tab1_sel_imagename = params.selimage1 or (IMAGE_DIR.."commerce_tab_sel1.png")
	local tab1_unsel_imagename = params.unselimage1 or (IMAGE_DIR.."commerce_tab_unsel1.png")
	local tab1_imagecenteruv = params.image1centeruv or "0.3125 0.171875 0.8125 0.6875" -- 10 5.5 26 22
	local tab2_sel_imagename = params.selimage2 or (IMAGE_DIR.."commerce_tab_sel2.png")
	local tab2_unsel_imagename = params.unselimage2 or (IMAGE_DIR.."commerce_tab_unsel2.png")
	local tab2_imagecenteruv = params.image2centeruv or "0.3125 0.328125 0.8125 0.6875" -- 10 10.5 26 22
	local upper_spacer_imagename = params.upperspacerimage or (IMAGE_DIR.."commerce_tab_spacer.png")
	local upper_spacer_imagesegments = params.upperspacersegments or "0 0 .5 0"
	local tabtextfont = params.font or Font.H4
	local button_sel_imagename = params.buttonselimage
	local button_unsel_imagename = params.buttonunselimage
	local button_imagecenteruv = params.buttonimagecenteruv
	local button_imageuv = params.buttonimageuv
	local button_glowborder = params.buttonimageglowborder
	local buttonmouseoverimage = params.buttonmouseoverimage

	local color = "255 255 255 255 *"
	local seltextcolor = params.seltextcolor or "255 255 255"
	local unseltextcolor = params.unseltextcolor or "128 128 128"
	local zboxargs = {}
	local zbox
	local curtabindex=1
	local tablist = {}
	local buttonlist = {}
	local i=1
	local max_width
	local upperleftimage
	if upper_left_imagename then
		upperleftimage = iup.label{title="", image=upper_left_imagename, segmented=upper_left_imagesegments, size=upper_left_imagesize, expand="NO", bgcolor=color}
	end
	while params[i] do
		local tab = params[i]
		local tabframe
		local button
		if tab.spacer == true then
			tabframe = iup.frame{
				iup.vbox{iup.hbox{iup.label{title="",expand=tab.expand, size=tab.size}},iup.fill{}},
				image=upper_spacer_imagename,
				segmented=upper_spacer_imagesegments,
				border = "0 0 0 0",
				expand="YES",
				bgcolor="255 255 255 255 *",
			}
			button = true
			zboxargs[i] = iup.fill{}
		else
			local index = i
			zboxargs[i] = tab
			button = iup.stationbutton{
				image=i==1 and button_sel_imagename or button_unsel_imagename,
				immouseover=buttonmouseoverimage,
				centeruv=button_imagecenteruv,
				uv=button_imageuv,
				glowborder=button_glowborder,
				hotkey=tab.hotkey,
				title=tab.tabtitle or 'tab'..i,
				expand=(params.alignment=="ATOP" or params.alignment=="ABOTTOM") and "NO" or "HORIZONTAL",
				fgcolor=i==curtabindex and seltextcolor or unseltextcolor,
				action=function(self)
					local oldvalue = zbox.value
					zbox.value = tab
					if index ~= curtabindex then
						local curtab = tablist[curtabindex]
						if curtab then
							if curtabindex == 1 then
								curtab.image=tab1_unsel_imagename
							else
								curtab.image=tab2_unsel_imagename
							end
							buttonlist[curtabindex].fgcolor=whole.unseltextcolor
							if button_unsel_imagename then
								buttonlist[curtabindex].image=button_unsel_imagename
							end
						end
						curtabindex = index
						curtab = tablist[curtabindex]
						if index == 1 then
							curtab.image=tab1_sel_imagename
						else
							curtab.image=tab2_sel_imagename
						end
						self.fgcolor=whole.seltextcolor
						if button_sel_imagename then
							self.image=button_sel_imagename
						end
					end
					if tabchange_cb then tabchange_cb(whole, tab, oldvalue) end
				end,
			}
			local b = button
			if params.tabbuttonoverlap then
				b = iup.hbox{button, margin=params.tabbuttonoverlap}
			end
			tabframe = iup.frame{
				b,
				expand="HORIZONTAL",
				bgcolor=color,
				border=params.tabborder,
				image=i==1 and tab1_sel_imagename or tab2_unsel_imagename,
				segmented=i==1 and tab1_imagecenteruv or tab2_imagecenteruv,
			}

		end
		table.insert(buttonlist, button)
		buttonlist[params[i]] = button
		table.insert(tablist, tabframe)
		i=i+1
	end

	local lowerrightimage
	if params.secondary then
		local align
		if params.alignment == "ABOTTOM" then
			align = "SW"
		elseif params.alignment == "ATOP" then
			align = "NE"
		else
			align = "SE"
		end
		lowerrightimage = iup.label{size=upper_right_imagesize, title="", image=upper_right_imagename, segmented=upper_right_imagesegments, expand="YES", bgcolor=color}
		lowerrightimage = iup.zbox{
			lowerrightimage,
			params.secondary,
			all = "YES",
			alignment = align,
		}
--[[
		lowerrightimage = iup.frame{
--			iup.frame{
--				iup.vbox{
					params.secondary,
					iup.fill{},
--				},
--				expand="YES",
--				bgcolor=color,
--				image=IMAGE_DIR.."button.png",
--				segmented=".5 .5 .5 .5",
--			},
			expand="YES",
			bgcolor=color,
			image=upper_right_imagename, -- IMAGE_DIR.."commerce_tab_right.png",
			segmented=upper_right_imagesegments, -- "0.3125 0.328125 0.8125 0.6875",  -- 10 10.5 26 22
		}
--]]
	else
--		lowerrightimage = iup.label{size=upper_right_imagesize, title="", image=upper_right_imagename, segmented=upper_right_imagesegments, expand="YES", bgcolor=color}
		lowerrightimage = iup.frame{
					iup.vbox{iup.hbox{iup.fill{}}, iup.fill{}},
					image=upper_right_imagename,
					segmented=upper_right_imagesegments,
					border = "0 0 0 0",
					expand="YES",
					bgcolor=color,
				}
	end
	zbox = iup.zbox(zboxargs)
	local bodyregion = iup.frame{iup.vbox{iup.hbox{zbox, iup.fill{}}, iup.fill{}}, image=border_imagename, segmented=border_imagesegments, expand="YES", bgcolor=color}
	if params.alignment == "ABOTTOM" or params.alignment == "ATOP" then
		if params.alignment == "ATOP" then
--			tablist.expand="VERTICAL"
		elseif params.alignment == "ABOTTOM" then
			tablist.expand="NO"
		end
		upperleftimage.expand = "VERTICAL"
		local tabregion
		if upperleftimage then
			tabregion = iup.hbox{lowerrightimage, iup.hbox(tablist), upperleftimage, expand="HORIZONTAL"}
		else
			tabregion = iup.hbox{iup.hbox(tablist), lowerrightimage, expand="HORIZONTAL"}
		end
		if params.alignment == "ATOP" then
			whole = iup.vbox{tabregion, bodyregion, expand="YES"}
		elseif params.alignment == "ABOTTOM" then
			whole = iup.vbox{bodyregion, tabregion, expand="YES"}
		end
	else
		tablist.expand="HORIZONTAL"
		local tabregion
		if upperleftimage then
			tabregion = iup.vbox{upperleftimage, iup.vbox(tablist), lowerrightimage, expand="VERTICAL"}
		else
			tabregion = iup.vbox{iup.vbox(tablist), lowerrightimage, expand="VERTICAL"}
		end
		whole = iup.hbox{bodyregion, tabregion, expand="YES"}
	end
whole=iup.frame{
	bgcolor="0 0 0 0 *",
	segmented="0 0 1 1",
	whole
	}
	whole.seltextcolor = seltextcolor
	whole.unseltextcolor = unseltextcolor

	function whole:SetTabTextColor(index, color)
		buttonlist[index].fgcolor = color
	end
	function whole:SetTab(index)
		if buttonlist[index].action then
			buttonlist[index]:action()
		end
	end
	function whole:GetTab()
		return zbox.value
	end
	function whole:GetTabButton(index)
		return buttonlist[index]
	end

	return whole
end

iup.pda_sub_tabs = iup.sub_tabs
