theme                               = {}

themes_dir                          = os.getenv("HOME") .. "/.config/awesome/themes/leliana"
theme.wallpaper                     = themes_dir .. "/wall.png"

theme.font                          = "Terminus 9"
theme.fg_normal                     = "#DDDDFF"
theme.fg_focus                      = "#F0DFAF"
theme.fg_highlight                  = "#f22c40"
theme.fg_urgent                     = "#CC9393"
theme.bg_normal                     = "#141414"
theme.bg_focus                      = "#313131"
theme.bg_urgent                     = "#1A1A1A"
theme.border_width                  = "1"
theme.border_normal                 = "#3F3F3F"
theme.border_focus                  = "#6666ea"
theme.border_marked                 = "#CC9393"
theme.taglist_fg_focus              = "#D8D782"
theme.textbox_widget_margin_top     = 1
theme.notify_fg                     = theme.fg_normal
theme.notify_bg                     = theme.bg_normal
theme.notify_border                 = "#6666ea"
theme.notify_border_width           = theme.border_width
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2
theme.mouse_finder_color            = "#CC9393"
theme.menu_height                   = "16"
theme.menu_width                    = "140"

theme.submenu_icon                  = themes_dir .. "/icons/submenu.png"
theme.taglist_squares_sel           = themes_dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = themes_dir .. "/icons/square_unsel.png"

theme.layout_tile                   = themes_dir .. "/icons/tile.png"
theme.layout_uselesstile            = themes_dir .. "/icons/tilegaps.png"
theme.layout_fairv                  = themes_dir .. "/icons/fairv.png"
theme.layout_floating               = themes_dir .. "/icons/floating.png"

theme.arrl                          = themes_dir .. "/icons/arrl.png"
theme.arrl_dl                       = themes_dir .. "/icons/arrl_dl.png"
theme.arrl_ld                       = themes_dir .. "/icons/arrl_ld.png"

theme.tasklist_disable_icon         = true
theme.tasklist_floating             = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

theme.useless_gap_width = 5

return theme
