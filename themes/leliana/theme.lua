foreground                          = "#a0a0a0"
background                          = "#141414"
black                               = "#1b1918"
red                                 = "#f22c40"
lightred                            = "#F85262"
green                               = "#5ab738"
lightgreen                          = "#7BD15B"
yellow                              = "#d5911a"
lightyellow                         = "#E9AD44"
blue                                = "#B450C5"
lightblue                           = "#5E8AF1"
magenta                             = "#E85B92"
lightmagenta                        = "#F181AC"
cyan                                = "#00ad9c"
lightcyan                           = "#26B3A4"
white                               = "#a8a19f"
gray                                = "#484848"
lightgray                           = "#554C49"

theme                               = {}

themes_dir                          = os.getenv("HOME") .. "/.config/awesome/themes/leliana"
theme.wallpaper                     = themes_dir .. "/wall.png"

theme.font                          = "Lemon"
theme.fg_normal                     = foreground
theme.fg_focus                      = magenta
theme.fg_urgent                     = lightmagenta
theme.bg_normal                     = background
theme.bg_focus                      = gray
theme.bg_urgent                     = background
theme.border_width                  = "1"
theme.border_normal                 = gray
theme.border_focus                  = magenta
theme.border_marked                 = red
theme.taglist_fg_focus              = theme.fg_focus
theme.textbox_widget_margin_top     = 1
theme.notify_fg                     = theme.fg_normal
theme.notify_bg                     = theme.bg_normal
theme.notify_border                 = magenta
theme.notify_border_width           = theme.border_width
theme.awful_widget_height           = 14
theme.awful_widget_margin_top       = 2
theme.mouse_finder_color            = "#CC9393"
theme.menu_height                   = "16"
theme.menu_width                    = "140"

theme.net_up                        = cyan
theme.net_down                      = green

theme.submenu_icon                  = themes_dir .. "/icons/submenu.png"
theme.taglist_squares_sel           = themes_dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel         = themes_dir .. "/icons/square_unsel.png"

theme.layout_tile                   = ""
theme.layout_uselesstile            = ""
theme.layout_fairv                  = ""
theme.layout_floating               = ""

theme.arrl                          = themes_dir .. "/icons/arrl.png"

theme.tasklist_disable_icon         = true
theme.tasklist_floating             = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical   = ""

theme.useless_gap_width = 5

theme.icon_mail = ""
theme.icon_music = ""
theme.icon_sound_off = ""
theme.icon_sound_low = ""
theme.icon_sound_med = ""
theme.icon_sound_high = ""

theme.widget_active = magenta

return theme
