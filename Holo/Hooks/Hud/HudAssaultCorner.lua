if Holo.Options:GetValue("HudBox") and Holo:ShouldModify("Hud", "HudAssault") then
	function HUDAssaultCorner:UpdateHolo()
		if not alive(self._bg_box) then -- Try not to crash :c
			Holo:log("[ERROR] Something went wrong when trying to modify HUDAssaultCorner")
			return
		end
		local wave = alive(self._wave_bg_box)
		local hostages_panel = self._hud_panel:child("hostages_panel")
		local num_hostages = self._hostages_bg_box:child("num_hostages")
		local num_waves = self._wave_bg_box and self._wave_bg_box:child("num_waves")
		local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
		local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
		local assault_panel = self._hud_panel:child("assault_panel")
		local casing_panel = self._hud_panel:child("casing_panel")
		local wave_panel = self._hud_panel:child("wave_panel")
		local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
		self._box_width = 242 
		self._box_height = 32
		HUDBGBox_recreate(self._bg_box,{
			name = "Assault",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._casing_bg_box,{
			name = "Casing",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._noreturn_bg_box,{
			name = "NoPointOfReturn",
			w = self._box_width,
			h = self._box_height,
		})
		HUDBGBox_recreate(self._hostages_bg_box ,{
			name = "Hostages",
			w = self._box_height,
			h = self._box_height,
		})		
		if wave then
			HUDBGBox_recreate(self._wave_bg_box ,{
				name = "WavesSurvived",
				w = 42,
				h = self._box_height,
			})
		end
		self._hud_panel:child("buffs_panel"):set_alpha(0)
		assault_panel:set_size(self._box_width, 40)
		Holo.Utils:SetPosition(assault_panel, "Assault")
		casing_panel:set_size(self._box_width, 40)
		Holo.Utils:SetPosition(casing_panel, "Casing")
		point_of_no_return_panel:set_size(self._box_width, 40)
		Holo.Utils:SetPosition(point_of_no_return_panel, "NoPointOfReturn")
		hostages_panel:set_size(70, 40)
		hostages_panel:set_righttop(self._hud_panel:w(), 0)
		if wave then
			wave_panel:set_size(160, 40)
			wave_panel:set_righttop(hostages_panel:left() - 4, 0)
		end
		if self._is_offseted and not self._always_not_offseted then
			hostages_panel:set_y(self._bg_box:h() + 8)
			if wave then
				wave_panel:set_y(hostages_panel:y())
			end
		end
		self._bg_box:set_right(assault_panel:w())
		self._casing_bg_box:set_right(assault_panel:w())
		self._noreturn_bg_box:set_right(assault_panel:w())
		self._hostages_bg_box:set_right(hostages_panel:w())
		hostages_panel:child("hostages_icon"):set_right(self._hostages_bg_box:left())
		if wave then
			local icon = wave_panel:child("hostages_icon") or wave_panel:child("waves_icon") --Who knows they decide to fix the typo xd
			icon:set_right(self._wave_bg_box:left())
		end
		assault_panel:child("icon_assaultbox"):hide()
		casing_panel:child("icon_casingbox"):hide()
		point_of_no_return_panel:child("icon_noreturnbox"):hide()
		point_of_no_return_text:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		point_of_no_return_timer:set_color(Holo:GetColor("TextColors/NoPointOfReturn"))
		num_hostages:set_color(Holo:GetColor("TextColors/Hostages"))
		num_hostages:set_shape(0,0,num_hostages:parent():size())
		if wave then
			num_waves:set_color(Holo:GetColor("TextColors/WavesSurvived"))
			num_waves:set_shape(0,0,num_waves:parent():size())
		end
		Holo.Utils:Apply({point_of_no_return_timer, point_of_no_return_text, num_hostages, num_waves}, {blend_mode = "normal", font = "fonts/font_medium_noshadow_mf", font_size = self._box_height - 6, y = -4})
		num_hostages:set_y(-2)
		if wave then
			num_waves:set_y(-2)
		end

		if self.update_banner_pos then
			self:update_banner_pos()
		end
	end	
	Hooks:PostHook(HUDAssaultCorner, "init", "HoloInit", function(self)
		self._top_right = {}		
		Holo:AddSetPositionClbk(function(setting, pos)
			if pos:match("TopRight") then
				self._top_right[setting] = true
			elseif self._top_right[setting] then
				self._top_right[setting] = nil
			end
			self._always_offseted = false
			self._always_not_offseted = table.size(self._top_right) == 0
			for k in pairs(self._top_right) do
				if k ~= "Assault" and k ~= "Casing" and k ~= "NoPointOfReturn" then
					self._always_offseted = true
					break
				end
			end
			self:_set_hostage_offseted(self._is_offseted)
		end)
		self:UpdateHolo()
		Holo:AddUpdateFunc(callback(self, self, "UpdateHolo"))
	end)
	function HUDAssaultCorner:_show_icon_assaultbox(icon)
		icon:set_alpha(1)
		Swoosh:work(icon, "rotation", 360, "callback", function()
			icon:set_rotation(0)
		end)
	end
	function HUDAssaultCorner:left_grow(o, clbk)
		local right = o:right()
		Swoosh:work(o, 
			"w", self._box_width, 
			"speed", 4,
			"after", function()
				o:set_right(right)
			end,
			"callback", clbk
		)
	end	
	Hooks:PostHook(HUDAssaultCorner, "_start_assault", "HoloStartAssault", function(self)
		if alive(self._bg_box) then
			self._bg_box:stop()
			self._bg_box:child("text_panel"):stop()
			self._bg_box:show()
			self:left_grow(self._bg_box)
	 		self._bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._bg_box, Holo:GetColor("TextColors/Assault"))
	 		if alive(self._wave_bg_box) then
	 			self._wave_bg_box:child("bg"):stop()
	 		end
	 	end
	end)
	Hooks:PostHook(HUDAssaultCorner, "_end_assault", "HoloEndAssault", function(self)
		if self:is_safehouse_raid() then		
			self._wave_bg_box:stop()
			self._wave_bg_box:child("num_waves"):stop()
			self._wave_bg_box:child("num_waves"):animate(callback(nil, Swoosh, "flash_icon"), 2, nil, true)
			self._hud_panel:child("assault_panel"):child("icon_assaultbox"):stop()
			self:_close_assault_box()
			self._wave_bg_box:child("bg"):stop()
		end			
	end)
	function HUDAssaultCorner:_animate_wave_completed(panel)
	end
	Hooks:PostHook(HUDAssaultCorner, "sync_set_assault_mode", "HoloSyncSetAssaultMode", function(self)
		self:UpdateHolo()
	end)
	function HUDAssaultCorner:_update_assault_hud_color(color) end
	function HUDAssaultCorner:_animate_text(text_panel, bg_box, color, color_function)
		local text_list = (bg_box or self._bg_box):script().text_list
		local text_index = 0
		local texts = {}
		local padding = 10
		local function create_new_text(text_panel, text_list, text_index, texts)
			text_panel:set_size(600, text_panel:parent():h())
			text_panel:set_center_x(10)
			if texts[text_index] and texts[text_index].text then
				text_panel:remove(texts[text_index].text)
				texts[text_index] = nil
			end
			color_function = nil
			local text_id = text_list[text_index]
			local text_string = ""
			if type(text_id) == "string" then
				text_string = managers.localization:to_upper_text(text_id)
			elseif text_id == Idstring("risk") then
				for i = 1, managers.job:current_difficulty_stars() do
					text_string = text_string .. managers.localization:get_default_macro("BTN_SKULL")
				end
			end
			local text = text_panel:text({
				text = text_string,
				align = "center",
				vertical = "center",
				blend_mode = color_function and "add",
				color = color_function and color_function() or color or self._assault_color,
				font_size = text_panel:h() - 6,
				font = "fonts/font_medium_mf",
			})
			local _, _, w, h = text:text_rect()
			text:set_size(w, h)
			texts[text_index] = {
				x = text_panel:w() + w * 0.5 + padding * 2,
				text = text
			}
		end
		while true do
			local dt = coroutine.yield()
			local last_text = texts[text_index]
			if last_text and last_text.text then
				if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
					text_index = text_index % #text_list + 1
					create_new_text(text_panel, text_list, text_index, texts)
				end
			else
				text_index = text_index % #text_list + 1
				create_new_text(text_panel, text_list, text_index, texts)
			end
			local speed = 90
			for i, data in pairs(texts) do
				if data.text then
					data.text:configure({
						color = color_function and color_function() or color or self._assault_color,
						font_size = text_panel:h() - 6,
					})
					managers.hud:make_fine_text(data.text)
					data.x = data.x - dt * speed
					data.text:set_center_x(data.x)
					data.text:set_center_y(text_panel:h() * 0.5)
					if 0 > data.x + data.text:w() * 0.5 then
						text_panel:remove(data.text)
						data.text = nil
					end
				end
			end
			start_speed = nil
		end
	end
	Hooks:PostHook(HUDAssaultCorner, "_animate_show_casing", "HoloAnimateShowCasing", function(self, casing_panel, delay_time)
		if alive(self._casing_bg_box) then
			self._casing_bg_box:child("text_panel"):stop()
			self._casing_bg_box:child("text_panel"):animate(callback(self, self, "_animate_text"), self._casing_bg_box, Holo:GetColor("TextColors/Casing"))
			self._casing_bg_box:stop()
			self._casing_bg_box:show()
			self:left_grow(self._casing_bg_box)
		end
	end)
	Hooks:PostHook(HUDAssaultCorner, "_animate_show_noreturn", "HoloAnimateShowNoReturn", function(self, point_of_no_return_panel)
		if alive(self._noreturn_bg_box) then
			local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
			local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
			local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
			self._noreturn_bg_box:stop()
			self._noreturn_bg_box:show()
			self:left_grow(self._noreturn_bg_box, function()
				point_of_no_return_text:show()
				point_of_no_return_timer:show()
			end)
		end
	end)
	function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
		local function flash_timer(o)
			local t = 0
			while t < 0.5 do
				t = t + coroutine.yield()
				local font_size = (tweak_data.hud_corner.noreturn_size)
				o:set_font_size(math.lerp(font_size, font_size * 1.25, n))
			end
		end
		local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
		point_of_no_return_timer:animate(flash_timer)
	end
	local SetHostageOffseted = HUDAssaultCorner._set_hostage_offseted
	function HUDAssaultCorner:_set_hostage_offseted(is_offseted, ...)
		self._is_offseted = is_offseted
		if self._always_offseted then
			is_offseted = true
		end
		if self._always_not_offseted then
			is_offseted = false
		end
		SetHostageOffseted(self, is_offseted, ...)
	end
	Hooks:PostHook(HUDAssaultCorner, "set_control_info", "HoloSetControlInfo", function(self)
		if alive(self._hostages_bg_box) then
			self._hostages_bg_box:child("bg"):stop()
			self._hostages_bg_box:child("num_hostages"):stop()
			self._hostages_bg_box:child("num_hostages"):animate(callback(nil, Swoosh, "flash_icon"), 2, nil, true)
		end
	end)
	Hooks:PostHook(HUDAssaultCorner, "_animate_wave_started", "HoloAnimateWaveStarted", function(self)
		if alive(self._wave_bg_box) then
			self._wave_bg_box:child("bg"):stop()
			self._wave_bg_box:child("num_waves"):stop()
			self._wave_bg_box:child("num_waves"):animate(callback(nil, Swoosh, "flash_icon"), 2, nil, true)
		end
	end)
	function HUDAssaultCorner:get_completed_waves_string() --OVK can you make stuff less fucking ugly?
		return string.format("%s / %s", managers.groupai:state():get_assault_number() or 0, self._max_waves or 0)
	end
end
 
 