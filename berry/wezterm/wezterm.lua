
local wezterm = require("wezterm")

local colors = {
	bg = "#F5F5F5",
	fg = "#363248",
	black = "#2b2839",
	red = "#d7757d",
	green = "#97baa3",
	yellow = "#c0a496",
	blue = "#91ace3",
	magenta = "#ab85d1",
	cyan = "#c28ebe",
	white = "#d5d1eb",
	cursor = "#91ace3",
}
local colors_f = {
	colors.black,
	colors.red,
	colors.green,
	colors.yellow,
	colors.blue,
	colors.magenta,
	colors.cyan,
	colors.white,
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return "  " .. tab.active_pane.title .. "  "
end)

return {
	font = wezterm.font("mononoki NF"),
	font_size = 14,
	window_close_confirmation = "NeverPrompt",
	window_padding = { left = 16, right = 16, top = 16, bottom = 16 },
	tab_max_width = 25,
	enable_wayland = true,
	colors = {
		foreground = colors.fg,
		background = colors.bg,
		ansi = colors_f,
		cursor_fg = colors.cursor,
		cursor_bg = colors.cursor,
		cursor_border = colors.cursor,
		brights = colors_f,
		tab_bar = {
			background = colors.bg,
			active_tab = {
				bg_color = colors.black,
				fg_color = colors.fg,
				intensity = "Bold",
			},
			inactive_tab = {
				bg_color = "#2b2839",
				fg_color = colors.fg,
			},
			inactive_tab_hover = {
				bg_color = "#2b2839",
				fg_color = colors.fg,
				italic = true,
			},
		},
	},
	show_tab_index_in_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	exit_behavior = "Close",
}
