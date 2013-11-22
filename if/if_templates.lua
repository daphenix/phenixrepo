local tooltip_timer = Timer()

local oldiupbutton = iup.button
function iup.button(params)
	if params.tip then
		params.enterwindow_cb = function(self)
			if not ShowTooltips then return end
			tooltip_timer:SetTimeout(1000, function()
				local text = params.tip
				local xres = gkinterface.GetXResolution()
				local selfx = tonumber(self.x)
				local newx = selfx + tonumber(self.w)
				local newy = -tonumber(self.y)
				ShowTooltip(newx,newy,text)
				local newtooltipwidth = tonumber(ToolTip.w)
				local newtooltipy = tonumber(ToolTip.y)
				if ((newtooltipwidth + newx) >= xres) or (newtooltipy < 0) then
					if ((newtooltipwidth + newx) >= xres) then
						newx = -newx
					end
					if (newtooltipy < 0) then
						newy = (-newy) + tonumber(self.h)
					end
					ShowTooltip(newx,newy,text)
				end
			end)
		end
		params.leavewindow_cb = function(self)
			HideTooltip()
			tooltip_timer:Kill()
		end
	end
	return oldiupbutton(params)
end

local oldiuplabel = iup.label
function iup.label(params)
	if params.tip then
		params.enterwindow_cb = function(self)
			if not ShowTooltips then return end
			tooltip_timer:SetTimeout(1000, function()
				local text = params.tip
				local xres = gkinterface.GetXResolution()
				local selfx = tonumber(self.x)
				local newx = selfx + tonumber(self.w)
				local newy = -tonumber(self.y)
				ShowTooltip(newx,newy,text)
				local newtooltipwidth = tonumber(ToolTip.w)
				if (newtooltipwidth + newx) >= xres then
					ShowTooltip(-newx,newy,text)
				end
			end)
		end
		params.leavewindow_cb = function(self)
			HideTooltip()
			tooltip_timer:Kill()
		end
	end
	return oldiuplabel(params)
end

local oldiuptoggle = iup.toggle
function iup.toggle(params)
	if params.tip then
		params.enterwindow_cb = function(self)
			if not ShowTooltips then return end
			tooltip_timer:SetTimeout(1000, function()
				local text = params.tip
				local xres = gkinterface.GetXResolution()
				local selfx = tonumber(self.x)
				local newx = selfx + tonumber(self.w)
				local newy = -tonumber(self.y)
				ShowTooltip(newx,newy,text)
				local newtooltipwidth = tonumber(ToolTip.w)
				local newtooltipy = tonumber(ToolTip.y)
				if ((newtooltipwidth + newx) >= xres) or (newtooltipy < 0) then
					if ((newtooltipwidth + newx) >= xres) then
						newx = -newx
					end
					if (newtooltipy < 0) then
						newy = (-newy) + tonumber(self.h)
					end
					ShowTooltip(newx,newy,text)
				end
			end)
		end
		params.leavewindow_cb = function(self)
			HideTooltip()
			tooltip_timer:Kill()
		end
	end
	return oldiuptoggle(params)
end

function iup.stationtoggle(params)
	params.IMMARGIN=8
	params.image=IMAGE_DIR.."button.png"
	params.immouseover=IMAGE_DIR.."button.png"
	params.imcheck=IMAGE_DIR.."check.png"
	params.imcheckinactive=IMAGE_DIR.."check_disabled.png"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"
	params.fgcolor=params.fgcolor or tabunseltextcolor

	return iup.toggle(params)
end
function iup.stationradio(params)
	params.IMMARGIN=8
	params.image=IMAGE_DIR.."radio_bg.png"
	params.immouseover=IMAGE_DIR.."radio_bg.png"
	params.imcheck=IMAGE_DIR.."radio.png"
	params.imcheckinactive=IMAGE_DIR.."radio_disabled.png"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"
	params.fgcolor=params.fgcolor or tabunseltextcolor

	return iup.toggle(params)
end

function iup.stationbutton(params)
	params.image=params.image or IMAGE_DIR.."button.png"
	params.iminactive=params.iminactive or IMAGE_DIR.."button_greyed.png"
	params.immouseover=params.immouseover or IMAGE_DIR.."button_tab.png"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"
	params.centeruv=params.centeruv or ".5 .5 .5 .5"
--	params.uv=params.uv
--	params.glowborder=params.glowborder
	params.fgcolor=params.fgcolor or tabunseltextcolor
	params.disabledtextcolor = params.disabledtextcolor or "192 192 192"

	return iup.button(params)
end

function iup.stationsubframebg(params)
	params.image=IMAGE_DIR.."commerce_tab_bgcolor.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationsubframebgfiller()
	return iup.stationsubframebg{iup.vbox{iup.fill{}, iup.hbox{iup.fill{}}}}
end

function iup.stationsubframe(params)
	params.image=IMAGE_DIR.."commerce_tab_listbox_border.png"
	params.segmented=".5 .5 .5 .5" -- "0.3125 0.3125 0.6875 0.6875"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationsubframe_nomargin(params)
	params.image=IMAGE_DIR.."commerce_tab_listbox_border.png"
	params.segmented=".5 .5 .5 .5" -- "0.3125 0.3125 0.6875 0.6875"
	params.border = "0 0 0 0"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationsubhollowframe(params)
	params.image=IMAGE_DIR.."commerce_tab_fullborder.png"
	params.segmented="0.40625 0.40625 0.59375 0.59375"  -- 6.5, 6.5, 9.5, 9.5
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationsublist(params)
	params.image=IMAGE_DIR.."commerce_tab_listbox_border.png"
	params.marginx=params.marginx or 3
	params.marginy=params.marginy or 3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end

function iup.stationsubmultiline(params)
	params.image=IMAGE_DIR.."commerce_tab_listbox_border.png"
	params.marginx=params.marginx or 8
	params.marginy=params.marginy or 3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.stationsubtree(params)
	params.image=IMAGE_DIR.."commerce_tab_listbox_border.png"
	params.marginx=params.marginx or 3
	params.marginy=params.marginy or 3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.tree(params)
end

function iup.stationmainframebg(params)
	params.image=IMAGE_DIR.."root_tab_bgcolor.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationmainframe(params)
	params.image=IMAGE_DIR.."root_border.png"
	params.segmented="0.265625 0.265625 0.734375 0.734375" -- 8.5 8.5 23.5 23.5
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationnameframe(params)
	params.image=IMAGE_DIR.."station_name.png"
	params.segmented="0.34375 0.28125 0.59375 0.59375" -- 5.5 4.5 9.5 9.5
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationbuttonframe(params)
	params.image=IMAGE_DIR.."button.png"
	params.segmented=".5 .5 .5 .5"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationdoubleframe(params)
	return iup.stationmainframe{
			iup.stationsubhollowframe(params)
		}
end


local stationhighopacityframe_segments = string.format("%f %f %f %f", 5.5/16, 5.5/16, 9.5/16, 9.5/16)
function iup.stationhighopacityframe(params)
	params.image=IMAGE_DIR.."high_opacity_border.png"
	params.segmented=stationhighopacityframe_segments
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationhighopacitysubframe(params)
	params.image=IMAGE_DIR.."high_opacity_listbox_border.png"
--	params.segmented="0.3125 0.3125 0.625 0.625" -- 5 5 10 10
	params.segmented="0.5 0.5 0.5 0.5"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationhighopacitysublist(params)
	params.image=IMAGE_DIR.."high_opacity_listbox_border.png"
	params.marginx=3
	params.marginy=3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end

function iup.stationhighopacitysubmultiline(params)
	params.image=IMAGE_DIR.."high_opacity_listbox_border.png"
	params.marginx=8
	params.marginy=3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.stationhighopacityframebg(params)
	params.image=IMAGE_DIR.."high_opacity_bgcolor.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationhighopacityframebgfiller()
	return iup.stationhighopacityframebg{iup.vbox{iup.fill{}, iup.hbox{iup.fill{}}}}
end

function iup.stationprogressbar(params)
	params.LOWERTEXTURE = IMAGE_DIR.."progressbar.png"
	params.MIDDLETEXTURE = IMAGE_DIR.."progressbar.png"
	params.UPPERTEXTURE = IMAGE_DIR.."progressbar.png"
	params.segmented = ".5 .5 .5 .5"

	return iup.progressbar(params)
end

local hudchatsegmentedstr = string.format("%f %f %f %f", 8.5/32, 6.5/16, 21.5/32, 7.5/16)
function iup.hudchatframe(params)
	params.image=IMAGE_DIR.."hud_chat_border.png"
	params.SEGMENTED = hudchatsegmentedstr
	params.BORDER = "10 5 0 0"
	params.bgcolor=params.bgcolor or "255 255 255 255 &"
	return iup.frame(params)
end

function iup.hudrightframe(params)
	params.image=IMAGE_DIR.."hud_border.png"
	params.SEGMENTED = "0.5 0.5 0.5 0.5"
	params.BORDER = params.BORDER or "4 4 4 4"
	params.bgcolor=params.bgcolor or "255 255 255 255 &"
	return iup.frame(params)
end

function iup.hudleftframe(params)
	params.image=IMAGE_DIR.."hud_border.png"
	params.SEGMENTED = "0.5 0.5 0.5 0.5"
	params.BORDER = params.BORDER or "4 4 4 4"
	params.bgcolor=params.bgcolor or "255 255 255 255 &"
	return iup.frame(params)
end

function iup.hudchatframe_old(params)
--  params.value = 5*2
    params.image=IMAGE_DIR.."hud_logpanel_display.png"
    params.SEGMENTED = "0.515625 0.375 0.609375 0.625" -- 33 24 39 40
    params.BORDER = "13 7 13 3"
    return iup.frame(params)
end

function iup.hudrightframe_old(params)
--  params.value = 4*2 + 1
    params.image=IMAGE_DIR.."hud_display.png"
    params.SEGMENTED = "0.5 0.375 0.8125 0.625" -- 32 24 52 40
    params.ROTATION = "MIRROR"
    params.BORDER = "8 12 18 8"
    return iup.frame(params)
end

function iup.hudleftframe_old(params)
    params.image=IMAGE_DIR.."hud_display.png"
    params.SEGMENTED = "0.5 0.375 0.8125 0.625"
    params.BORDER = "18 12 8 8"
    return iup.frame(params)
end

function iup.pdasubframe_nomargin(params)
	params.image=IMAGE_DIR.."pda_sub_border_full.png"
	params.segmented=".5 .5 .5 .5" -- "0.3125 0.3125 0.6875 0.6875"
	params.border = "0 0 0 0"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.pdarootframe(params)
	params.image=IMAGE_DIR.."pda_root_border_full.png"
	params.segmented="0.28125 0.28125 0.65625 0.65625" -- 4.5 4.5 10.5 10.5
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.pdarootframebg(params)
	params.image=IMAGE_DIR.."pda_root_tab_bg.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.pdarootmultiline(params)
	params.image=IMAGE_DIR.."pda_sub_tab_listbox_border.png"
	params.marginx = params.marginx or 4
	params.marginy = params.marginy or 4
	params.border = params.border or "NO"
	params.bgcolor = params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.pdarootlist(params)
	params.image=IMAGE_DIR.."pda_sub_tab_listbox_border.png"
	params.marginx = params.marginx or 4
	params.marginy = params.marginy or 4
	params.border = params.border or "NO"
	params.bgcolor = params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end

function iup.pda_root_tabs(params)
	params.upperleftimage = (IMAGE_DIR.."pda_root_tab_left.png")
	params.upperrightimage = (IMAGE_DIR.."pda_root_tab_right.png")
	params.upperspacerimage = (IMAGE_DIR.."pda_root_tab_spacer.png")
	params.borderimagename = (IMAGE_DIR.."pda_root_tab_border.png")
	params.borderimagesegments = "0.28125 0 0.65625 0.65625"  -- 4.5 0 10.5 10.5
	params.selimage = (IMAGE_DIR.."pda_root_tab_selected.png")
	params.unselimage = (IMAGE_DIR.."pda_root_tab_unselected.png")
	params.imagecenteruv = "0.28125 0.28125 0.65625 0.46875" -- 4.5 4.5 10.5 7.5

	return iup.root_tabs(params)
end

function iup.pdasubmultiline(params)
	params.image=IMAGE_DIR.."pda_sub_tab_listbox_border.png"
	params.marginx = params.marginx or 4
	params.marginy = params.marginy or 4
	params.border = params.border or "NO"
	params.bgcolor = params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.pdasublist(params)
	params.image=IMAGE_DIR.."pda_sub_tab_listbox_border.png"
	params.marginx = params.marginx or 4
	params.marginy = params.marginy or 4
	params.border = params.border or "NO"
	params.bgcolor = params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end

function iup.pdasubmatrix(params)
	params.image=IMAGE_DIR.."pda_sub_tab_listbox_border.png"
	params.marginx = params.marginx or 4
	params.marginy = params.marginy or 4
	params.border = params.border or "NO"
	params.bgcolor = params.bgcolor or "255 255 255 255 *"

	return iup.matrix(params)
end

function iup.pdasubframebg(params)
	params.image=IMAGE_DIR.."pda_sub_tab_bg.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.roottabtemplate(params)
	local container
	local isvisible = false

	local curtab = params[1]

	container = iup.pda_sub_tabs{
		buttonselimage=IMAGE_DIR.."tab.button_selected.png",
		buttonunselimage=IMAGE_DIR.."tab.button_unselected.png",
		buttonmouseoverimage=IMAGE_DIR.."tab.button_mouseover.png",
		buttonimagecenteruv=string.format("%f %f %f %f", 10/32, 10/32, 10/32, 10/32),
		buttonimageuv=string.format("0 0 %f %f", 21/32, 21/32),
		buttonimageglowborder="4",
		selimage1 = IMAGE_DIR.."pda_sub_tab1_sel.png",
		unselimage1 = IMAGE_DIR.."pda_sub_tab1_unsel.png",
		image1centeruv = "0.5 0.25 0.5 0.75",
		selimage2 = IMAGE_DIR.."pda_sub_tab2_sel.png",
		unselimage2 = IMAGE_DIR.."pda_sub_tab2_unsel.png",
		image2centeruv = "0.5 0.53125 0.5 0.75",
		upperrightimage = IMAGE_DIR.."pda_sub_tab_right.png",
		upperspacerimage = IMAGE_DIR.."pda_sub_tab_right.png",
		borderimagename = IMAGE_DIR.."pda_sub_tab_bottom.png",
		borderimagesegments = "0.5625 0.28125 1 0.71875",  -- "4.5 4.5 8 11.5"
		seltextcolor=tabseltextcolor,
		unseltextcolor=tabunseltextcolor,
		tabchange_cb = function(self, newtab, oldtab)
			curtab = newtab
			if isvisible then
				oldtab:OnHide()
				newtab:OnShow()
			end
		end,
		secondary=params.secondary,
		unpack(params)
	}

	function container:OnShow()
		isvisible = true
		curtab:OnShow()
	end

	function container:OnHide()
		isvisible = false
		curtab:OnHide()
	end

	function container:k_any(ch)
		if curtab.k_any then return curtab:k_any(ch) else return iup.CONTINUE end
	end

	return container
end

function iup.pdasubsubframebg(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_bg.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end
iup.stationsubsubframebg = iup.pdasubsubframebg

function iup.stationsubsubframehdivider(params)
	return iup.stationsubsubframebg{
			iup.vbox{iup.fill{}},
			size=params.size..'x',
		}
end

function iup.stationsubsubframevdivider(params)
	return iup.stationsubsubframebg{
			iup.hbox{iup.fill{}},
			size='x'..params.size,
		}
end

function iup.stationsubframehdivider(params)
	return iup.stationsubframebg{
			iup.vbox{iup.fill{}},
			size=params.size..'x',
		}
end

function iup.stationsubframevdivider(params)
	return iup.stationsubframebg{
			iup.hbox{iup.fill{}},
			size='x'..params.size,
		}
end

function iup.pdasubsublist(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 0
	params.marginy=params.marginy or 0
	params.spacing=params.spacing or 0
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end
iup.stationsubsublist = iup.pdasubsublist

function iup.stationsubsubmultiline(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 4
	params.marginy=params.marginy or 3
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.stationsubsubtree(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 0
	params.marginy=params.marginy or 0
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.tree(params)
end

function iup.pdasubsubmatrix(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 0
	params.marginy=params.marginy or 0
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.matrix(params)
end

function iup.stationsubsubframe(params)
	params.image=IMAGE_DIR.."pda_sub_sub_tab_listbox_border.png"
	params.segmented="0.5 0.5 0.5 0.5"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.stationsubsubframe2(params)
	params.image=IMAGE_DIR.."pda_sub_sub_border_full.png"
	params.segmented=string.format("%f %f %f %f", 8.5/32, 8.5/32, 23.5/32, 23.5/32)
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.subsubtabtemplate(params)
	local container
	local isvisible = false

	local curtab = params[1]

	container = iup.sub_tabs{
		buttonselimage=IMAGE_DIR.."tab.button_selected.png",
		buttonunselimage=IMAGE_DIR.."tab.button_unselected.png",
		buttonmouseoverimage=IMAGE_DIR.."tab.button_mouseover.png",
		buttonimagecenteruv=string.format("%f %f %f %f", 10/32, 10/32, 10/32, 10/32),
		buttonimageuv=string.format("0 0 %f %f", 21/32, 21/32),
		buttonimageglowborder="4",
--		alignment = "ABOTTOM",
		alignment = "ATOP",
		selimage1 = IMAGE_DIR.."pda_sub_sub_tab_sel.png",
		unselimage1 = IMAGE_DIR.."pda_sub_sub_tab_unsel.png",
		image1centeruv = "0.5 0.625 0.5 0.625",
		selimage2 = IMAGE_DIR.."pda_sub_sub_tab_sel.png",
		unselimage2 = IMAGE_DIR.."pda_sub_sub_tab_unsel.png",
		image2centeruv = "0.5 0.625 0.5 0.625",
		upperleftimage = IMAGE_DIR.."pda_sub_sub_tab_left.png",
		upperleftsegments = "0 0 0 0",
		upperrightimage = IMAGE_DIR.."pda_sub_sub_tab_right.png",
		upperrightsegments = "1 0 1 0",
		upperrightsize = "0x0",
		borderimagename = IMAGE_DIR.."pda_sub_sub_tab_border.png",
--		borderimagesegments = "0.265625 0.265625 0.734375 0.828125",  -- "8.5 8.5 23.5 26.5"
		borderimagesegments = "0.265625 0.171875 0.734375 0.734375",  -- "8.5 5.5 23.5 23.5"
--		tabbuttonoverlap = "-2x-4",
		tabbuttonoverlap = "0x-2",
		seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
		tabchange_cb = function(self, newtab, oldtab)
			curtab = newtab
			if isvisible then
				oldtab:OnHide()
				newtab:OnShow()
			end
		end,
		secondary = iup.hbox{iup.stationbutton{title="Help", hotkey=iup.K_F1, tip="Help for this interface", action=function() curtab:OnHelp() end}, iup.fill{}},
		unpack(params)
	}
	
	function container:OnShow()
		isvisible = true
		curtab:OnShow()
	end

	function container:OnHide()
		isvisible = false
		curtab:OnHide()
	end

	function container:OnEvent(eventname, ...)
	end

	function container:k_any(ch)
		if curtab.k_any then return curtab:k_any(ch) else return iup.CONTINUE end
	end

	return container
end

function iup.subsubsubtabtemplate(params)
	local container
	local isvisible = false

	local curtab = params[1]

	container = iup.sub_tabs{
		alignment = "ATOP",
		selimage1 = IMAGE_DIR.."pda_sub_sub_sub_tab_sel.png",
		unselimage1 = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer.png",
		image1centeruv = "0.28125 0.125 0.46875 0.125",
		selimage2 = IMAGE_DIR.."pda_sub_sub_sub_tab_sel.png",
		unselimage2 = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer.png",
		image2centeruv = "0.28125 0.125 0.46875 0.125",
		upperleftimage = IMAGE_DIR.."pda_sub_sub_sub_tab_left.png",
		upperleftsegments = "1 0 1 0",
		upperrightimage = IMAGE_DIR.."pda_sub_sub_sub_tab_right.png",
		upperrightsegments = "0 0 0 0",
		upperrightsize = "0x0",
		upperspacerimage = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer.png",
		borderimagename = IMAGE_DIR.."pda_sub_sub_sub_tab_border.png",
		borderimagesegments = string.format("%f %f %f %f", 4.5/16, 0, 11.5/16, 11.5/16),
		tabbuttonoverlap = "-5x0",
		seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
		tabchange_cb = params.tabchange_cb or function(self, newtab, oldtab)
			curtab = newtab
			if isvisible then
				oldtab:OnHide()
				newtab:OnShow()
			end
		end,
		unpack(params)
	}
	
	function container:OnShow()
		isvisible = true
		curtab:OnShow()
	end

	function container:OnHide()
		isvisible = false
		curtab:OnHide()
	end

	function container:OnEvent(eventname, ...)
	end

	function container:k_any(ch)
		if curtab.k_any then return curtab:k_any(ch) else return iup.CONTINUE end
	end

	return container
end

function iup.pdasubsubsubframebg(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_tab_bg.png"
	params.segmented="0 0 1 1"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.pdasubsubsublist(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 4
	params.marginy=params.marginy or 4
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.list(params)
end

function iup.pdasubsubsubtree(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 4
	params.marginy=params.marginy or 4
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.tree(params)
end

function iup.pdasubsubsubmultiline(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_tab_listbox_border.png"
--	params.segmented=string.format("%f %f %f %f", 4.5/16, 4.5/16, 11.5/16, 11.5/16)
	params.marginx=params.marginx or 8
	params.marginy=params.marginy or 4
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.multiline(params)
end

function iup.pdasubsubsubmatrix(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_tab_listbox_border.png"
	params.marginx=params.marginx or 4
	params.marginy=params.marginy or 4
	params.border=params.border or "NO"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.matrix(params)
end

function iup.pdasubsubsubframe2(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_border.png"
	params.segmented=string.format("%f %f %f %f", 4.5/16, 4.5/16, 11.5/16, 11.5/16)
	params.border = "4 4 4 4"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.pdasubsubsubframefull2(params)
	params.image=IMAGE_DIR.."pda_sub_sub_sub_border_full.png"
	params.segmented=string.format("%f %f %f %f", 4.5/16, 4.5/16, 11.5/16, 11.5/16)
	params.border = "4 4 4 4"
	params.expand=params.expand or "YES"
	params.bgcolor=params.bgcolor or "255 255 255 255 *"

	return iup.frame(params)
end

function iup.subsubsubtabtemplate2(params)
	local container
	local isvisible = false

	local curtab = params[1]

	container = iup.sub_tabs{
		alignment = "ATOP",
		selimage1 = IMAGE_DIR.."pda_sub_sub_sub_tab_sel2.png",
		unselimage1 = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer2.png",
		image1centeruv = "0.28125 0.125 0.46875 0.125",
		selimage2 = IMAGE_DIR.."pda_sub_sub_sub_tab_sel2.png",
		unselimage2 = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer2.png",
		image2centeruv = "0.28125 0.125 0.46875 0.125",
		upperleftimage = IMAGE_DIR.."pda_sub_sub_sub_tab_left2.png",
		upperleftsegments = "1 0 1 0",
		upperrightimage = IMAGE_DIR.."pda_sub_sub_sub_tab_right2.png",
		upperrightsegments = "0 0 0 0",
		upperrightsize = "0x0",
		upperspacerimage = IMAGE_DIR.."pda_sub_sub_sub_tab_spacer2.png",
		borderimagename = IMAGE_DIR.."pda_sub_sub_sub_tab_border2.png",
		borderimagesegments = string.format("%f %f %f %f", 4.5/16, 0, 11.5/16, 11.5/16),
		tabborder = "4 0 4 3",
		seltextcolor=tabseltextcolor, unseltextcolor=tabunseltextcolor,
		tabchange_cb = params.tabchange_cb or function(self, newtab, oldtab)
			curtab = newtab
			if isvisible then
				oldtab:OnHide()
				newtab:OnShow()
			end
		end,
		unpack(params)
	}
	
	function container:OnShow()
		isvisible = true
		curtab:OnShow()
	end

	function container:OnHide()
		isvisible = false
		curtab:OnHide()
	end

	function container:OnEvent(eventname, ...)
	end

	function container:k_any(ch)
		if curtab.k_any then return curtab:k_any(ch) else return iup.CONTINUE end
	end

	return container
end

function iup.itemlisttemplate(params, issubsub)
	params.expand = params.expand or "YES"
	params.size = params.size or "THIRDx1"
	params.control = params.control or "YES"

	if issubsub then
		return iup.stationsubsublist(params)
	else
		return iup.stationsublist(params)
	end
end

-- creates a matrix, feed it the columndefs and default sort column.
--
-- need to define matrix:update() and matrix:reset()
-- define custom matrix:fgcolor_cb or any other _cb's after calling.
--

--[[
i.e.

local my_matrix = iup.matrix_template(sortfuncs, 1)
local sortfuncs = {
	[1] = {
		title="Name",
		alignment="ALEFT",
		sort = function(a,b) -- how to sort column 1 
			return a.name < b.name
		end,
		},
	[2] = {
		title="Location",
		alignment="ALEFT",
		sort = function(a,b)
			if a.location == b.location then
				return a.name < b.name
			elseif (not a.location) or a.location == 0 then
				return false
			elseif (not b.location) or b.location == 0 then
				return true
			else
				return a.location < b.location
			end
		end,
		},
	update_entry = function(matrix, index, data)
		local c = (data.location and data.location ~= 0 and "200 200 200") or "128 128 128"
		matrix:setcell(index, 1, " "..data.name)
		matrix:setcell(index, 2, " "..((data.location and data.location ~= 0 and (ShortLocationStr(data.location))) or "Not Logged In"))
		matrix:setattribute("FGCOLOR", index, -1, c)
	end,
	matrix = iup.pdasubsubmatrix,
}
]]

function iup.matrix_template(columndefs, defsort)
	local alpha = ListColors.Alpha
	local even, odd = ListColors[0], ListColors[1]

	local bg = {
		[0] = even.." "..alpha,
		[1] = odd.." "..alpha,
	}
	local bg_numbers = ListColors.Numbers

	local matrix
	local sortedlist
	local update_matrix
	local sort_key = defsort -- default sort
	local numcolumns = (#columndefs)
	local function set_sort_mode(mode)
		-- clicked on title of column
		sort_key = mode
		-- color the text accordingly
		for i=1,numcolumns do
			matrix:setattribute("FGCOLOR", 0, i, mode == i and tabseltextcolor or tabunseltextcolor)
		end
	end

	matrix = columndefs.matrix or iup.pdasubsubmatrix{
		numcol = numcolumns,
		expand = "YES",
		size="200x100",
	}
	for i=1,numcolumns do
		matrix["ALIGNMENT"..i] = columndefs[i].alignment
		matrix["0:"..i] = columndefs[i].title
	end
	set_sort_mode(defsort)
	function matrix:fgcolor_cb(row, col)
		local c = bg_numbers[math.fmod(row,2)]
		return c[1],c[2],c[3],c[4],iup.DEFAULT
	end
	matrix.bgcolor_cb = matrix.fgcolor_cb
	function matrix:click_cb(row, col)
		if row == 0 then
			set_sort_mode(col)
			update_matrix(self)
		elseif columndefs.on_sel then
			columndefs.on_sel(matrix, row, sortedlist[row])
--			update_matrix(self)
		end
	end
	function matrix:edition_cb()
		return iup.IGNORE
	end

	local function sort_list(sort_key, list)  -- how to sort the matrix
		table.sort(list, columndefs[sort_key].sort)
	end

	local function reload_matrix(matrix, list) -- reload all data
		matrix.numlin = (#list)
	
		for index,v in ipairs(list) do
			columndefs.update_entry(matrix, index, v)
		end
	end
	
	local function reset_matrix(self, characterlist)  -- purge, sort and reload
		matrix.dellin = "1--1"  -- one way of deleting all items in the matrix
		sortedlist = characterlist
		sort_list(sort_key, sortedlist)
		reload_matrix(matrix, sortedlist)
	end

	update_matrix = function(self)
		set_sort_mode(sort_key)
		sort_list(sort_key, sortedlist)
		reload_matrix(matrix, sortedlist)
	end

	matrix.update = update_matrix
	matrix.reset = reset_matrix

	return matrix
end


--


dofile(IF_DIR.."if_tabs.lua")
