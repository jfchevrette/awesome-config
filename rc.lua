-- {{{ Required libraries
require("lfs")
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
require("eminent.eminent")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local lain = require("lain")

local home = os.getenv("HOME")
local awesomeexit = home .. "/.local/bin/awesomeexit "

-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = err
        })
        in_error = false
    end)
end
-- }}}

-- disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end

-- {{{ Run program once
-- http://awesome.naquadah.org/wiki/Autostart#The_native_lua_way
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
        -- All directories in /proc containing a number, represent a process
        if tonumber(dir) ~= nil then
          local f, err = io.open("/proc/"..dir.."/cmdline")
          if f then
            local cmdline = f:read("*all")
            f:close()
            if cmdline ~= "" then
              coroutine.yield(cmdline)
            end
          end
        end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
   assert(type(process) == "string")
   local regex_killer = {
      ["+"]  = "%+", ["-"] = "%-",
      ["*"]  = "%*", ["?"]  = "%?" }

   for p in processwalker() do
      if p:find(process:gsub("[-+?*]", regex_killer)) then
          return
      end
   end
   return awful.util.spawn(cmd or process)
end
-- }}}

-- {{{ Autostart
run_once("compton -b")
run_once("parcellite -n")
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(home .. "/.config/awesome/themes/leliana/theme.lua")
naughty.config.defaults.border_width = beautiful.notify_border_width
naughty.config.defaults.border_color = beautiful.notify_border

-- common
modkey = "Mod4"
altkey = "Mod1"
terminal = "termite" or "xterm"
terminal_float = terminal .. " --class=float-term --geometry 700x400"
editor = "vim"
editor_cmd = terminal .. " --geometry 1000x600 --class=" .. editor .. " -e " .. editor

-- user defined
browser = "firejail firefox"
telegram = "firejail telegram"
mail = terminal .. " --geometry 1000x600 --class=mutt -e mutt"
musicplr = terminal .. " --geometry 1000x600 --class=ncmpcpp -e ncmpcpp"
file_manager = "thunar"
dmenu_args = string.format("-i -nf '%s' -nb '%s' -sb '%s' -sf '%s' -fn '%s'",
    beautiful.fg_normal, beautiful.bg_normal, beautiful.bg_focus, beautiful.fg_focus, beautiful.font)

local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    lain.layout.uselesstile,
    awful.layout.suit.fair,
}
-- }}}

-- {{{ Tags
tags = {
    names = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, layouts[2])
end
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

gamesmenu = {
    { "minecraft", "java -jar " .. home .. "/.minecraft/Minecraft.jar" },
    { "morrowind", "openmw-launcher" },
}

configmenu = {
    { "gtk appearance", "lxappearance" },
}

awesomemenu = {
    { "manual", terminal_float .. " -e 'man awesome'" },
    { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
    { "restart", awesome.restart }
}

systemmenu = {
    { "awesome", awesomemenu },
    { "config", configmenu },
    { "logout", awesome.quit },
    { "lock", awesomeexit .. "lock" },
    { "suspend", awesomeexit .. "suspend" },
    { "reboot", awesomeexit .. "reboot" },
    { "shutdown", awesomeexit .. "shutdown" }
}


-- {{{ Menu
mymainmenu = awful.menu({
    items = {
        { "terminal", terminal_float },
        { "web browser", browser },
        { "games", gamesmenu },
        { "system", systemmenu }
    }
})
-- }}}

-- {{{ Wibox
markup = lain.util.markup

-- Textclock
datewidget = awful.widget.textclock("%a %d %b", 60)
timewidget = awful.widget.textclock("%H:%M:%S", 1)

-- calendar
lain.widgets.calendar:attach(datewidget, { font_size = 10 })

-- Maildir check
mailicon = wibox.widget.textbox(markup(beautiful.fg_normal, beautiful.icon_mail))
mailwidget = wibox.widget.background(lain.widgets.maildir({
    timeout = 180,
    ignore_boxes = { "Drafts", "Junk", "Sent", "Trash" },
    mailpath = home .. "/.mail",
    external_mail_cmd = "mbsync -q ndev revthefox foxbnc foxdev",
    settings = function()
        if newmail ~= "no mail" then
            mailicon:set_markup(markup(beautiful.widget_active, beautiful.icon_mail))
            widget:set_text(" " .. newmail)
        else
            widget:set_text("")
            mailicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_mail))
        end
    end
}))

-- MPD
local mpdicon = wibox.widget.textbox(markup(beautiful.fg_normal, beautiful.icon_music))
mpdwidget = lain.widgets.mpd({
    music_dir = home .. "/music",
    cover_size = "50",
    settings = function()
        mpd_notification_preset = {
            title   = "Now playing",
            timeout = 6,
            text    = string.format("%s (%s)\n%s", mpd_now.artist,
                mpd_now.album, mpd_now.title)
        }

        local artist = ""
        local title = ""
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title = mpd_now.title
            mpdicon:set_markup(markup(beautiful.widget_active, beautiful.icon_music))
        elseif mpd_now.state == "pause" then
            artist = " mpd "
            title = "paused"
            mpdicon:set_markup(markup(beautiful.widget_active, beautiful.icon_music))
        else
            mpdicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_music))
        end

        widget:set_markup(markup(beautiful.widget_active, artist) .. title)
    end
})

-- ALSA volume
local volicon = wibox.widget.textbox(markup(beautiful.fg_normal, beautiful.icon_sound_high))
volumewidget = lain.widgets.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_sound_off))
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_sound_low))
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_sound_med))
        else
            volicon:set_markup(markup(beautiful.fg_normal, beautiful.icon_sound_high))
        end

        widget:set_text(" " .. volume_now.level .. "%")
    end
})

-- Net
netwidget = lain.widgets.net({
    settings = function()
        widget:set_markup(markup(beautiful.net_down, net_now.received)
                .. " " ..
                markup(beautiful.net_up, net_now.sent))
    end
})

-- Separators
space = wibox.widget.textbox(' ')
separator = wibox.widget.textbox()
separator:set_markup(markup(beautiful.bg_urgent, beautiful.bar_separator_char))

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(awful.button({}, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({}, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end))


-- Writes a string representation of the current layout in a textbox widget
-- https://bbs.archlinux.org/viewtopic.php?pid=1195757#p1195757
function updatelayoutbox(l, s)
    local screen = s or 1
    l:set_markup(markup(beautiful.fg_focus, beautiful["layout_" .. awful.layout.getname(awful.layout.get(screen))]))
end

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()

    -- Create a textbox widget which will contains a short string representing the
    -- layout we're using.  We need one layoutbox per screen.
    mylayoutbox[s] = wibox.widget.textbox()
    updatelayoutbox(mylayoutbox[s], s)

    awful.tag.attached_connect_signal(s, "property::selected", function ()
        updatelayoutbox(mylayoutbox[s], s)
    end)
    awful.tag.attached_connect_signal(s, "property::layout", function ()
        updatelayoutbox(mylayoutbox[s], s)
    end)

    mylayoutbox[s]:buttons(awful.util.table.join(
            awful.button({}, 1, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 3, function() awful.layout.inc(layouts, -1) end),
            awful.button({}, 4, function() awful.layout.inc(layouts, 1) end),
            awful.button({}, 5, function() awful.layout.inc(layouts, -1) end)))

    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the upper left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(space)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(space)

    -- Widgets that are aligned to the upper right
    local right_layout = wibox.layout.fixed.horizontal()
    local right_layout_toggle = true
    local function right_layout_add(...)
        local arg = { ... }
            right_layout:add(space)
            right_layout:add(separator)
            right_layout:add(space)
            for i, n in pairs(arg) do
                right_layout:add(n)
            end
    end

    if s == 1 then
        right_layout:add(wibox.widget.systray())
    end

    right_layout_add(mpdicon, mpdwidget)
    right_layout_add(mailicon, mailwidget)
    right_layout_add(volicon, volumewidget)
    right_layout_add(netwidget)
    right_layout_add(datewidget)
    right_layout_add(timewidget)
    right_layout_add(mylayoutbox[s], space)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    mywibox[s]:set_widget(layout)
end

-- {{{ Mouse Bindings
root.buttons(awful.util.table.join(awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(-- Take a screenshot
    awful.key({ modkey }, "s", function() awful.util.spawn(home .. "/.local/bin/pstepw -s") end),
    awful.key({ modkey }, "l", function() awful.util.spawn(awesomeexit .. "lock") end),

    -- By direction client focus
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show menu
    awful.key({ modkey }, "w",
        function()
            mymainmenu:toggle()
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "Left", function() awful.client.swap.byidx(1) end),
    awful.key({ modkey, "Shift" }, "Right", function() awful.client.swap.byidx(-1) end),
    awful.key({ modkey, "Shift" }, "Up", function() awful.tag.incnmaster(-1) end),
    awful.key({ modkey, "Shift" }, "Down", function() awful.tag.incnmaster(1) end),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ modkey, "Mod1" }, "Right", function() awful.tag.incmwfact(0.05) end),
    awful.key({ modkey, "Mod1" }, "Left", function() awful.tag.incmwfact(-0.05) end),
    awful.key({ modkey, "Mod1" }, "Down", function() awful.client.incwfact(0.05) end),
    awful.key({ modkey, "Mod1" }, "Up", function() awful.client.incwfact(-0.05) end),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift" }, "r", awesome.restart),

    -- Widgets
    awful.key({ "Control", altkey }, "m", function() awful.util.spawn_with_shell(musicplr) end),
    awful.key({ "Control", altkey }, "e", function() awful.util.spawn_with_shell(mail) end),

    -- Start recording (desktop)
    awful.key({ modkey, altkey }, "r", function() awful.util.spawn_with_shell(home .. "/scripts/screencast -m desktop") end),

    -- Start recording (window)
    awful.key({ modkey, altkey }, "w", function() awful.util.spawn_with_shell(home .. "/scripts/screencast -m window") end),

    -- Stop recording
    awful.key({ modkey, altkey }, "x", function() awful.util.spawn("pkill -f 'x11grab'") end),

    -- ALSA volume control
    awful.key({ altkey }, "Up",
        function()
            awful.util.spawn("amixer -q set Master 1%+")
            volumewidget.update()
        end),
    awful.key({ altkey }, "Down",
        function()
            awful.util.spawn("amixer -q set Master 1%-")
            volumewidget.update()
        end),
    awful.key({}, "XF86AudioRaiseVolume",
        function()
            awful.util.spawn("amixer -q set Master 1%+")
            volumewidget.update()
        end),
    awful.key({}, "XF86AudioLowerVolume",
        function()
            awful.util.spawn("amixer -q set Master 1%-")
            volumewidget.update()
        end),

    -- MPD control
    awful.key({}, "XF86AudioPlay",
        function()
            awful.util.spawn_with_shell("mpc toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Up",
        function()
            awful.util.spawn_with_shell("mpc toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function()
            awful.util.spawn_with_shell("mpc stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function()
            awful.util.spawn_with_shell("mpc prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function()
            awful.util.spawn_with_shell("mpc next")
            mpdwidget.update()
        end),

    awful.key({ modkey }, "p", function() awful.util.spawn(home .. "/.local/bin/passmenu " .. dmenu_args, false) end),
    awful.key({ modkey, "Control" }, "p", function() awful.util.spawn("passmenu --type " .. dmenu_args, false) end),


    -- User programs
    awful.key({}, 'XF86Calculator', function() awful.util.spawn('galculator') end),
    awful.key({ modkey }, "b", function() awful.util.spawn(browser) end),
    awful.key({ modkey }, "f", function() awful.util.spawn(file_manager) end),
    awful.key({ modkey }, "t", function() awful.util.spawn(telegram) end),
    awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),
    awful.key({ modkey }, "d", function () awful.util.spawn_with_shell('rofi -show run') end),
    awful.key({ modkey }, "r", function() awful.util.spawn_with_shell('rofi -show run') end),

    -- Run a small prompt to execute Lua within Awesome's Lua runtime
    awful.key({ modkey }, "x",
        function()
            awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
        end))

clientkeys = awful.util.table.join(awful.key({ modkey, "Shift" }, "f", function(c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, }, "o", awful.client.movetoscreen),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewonly(tag)
                end
            end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = mouse.screen
                local tag = awful.tag.gettags(screen)[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if client.focus and tag then
                        awful.client.movetotag(tag)
                    end
                end
            end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = awful.tag.gettags(client.focus.screen)[i]
                    if tag then
                        awful.client.toggletag(tag)
                    end
                end
            end))
end

clientbuttons = awful.util.table.join(awful.button({}, 1, function(c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false,
            callback = awful.placement.centered
        }
    },
    {
        rule = { class = "mpv" },
        properties = { floating = true }
    },

    {
        rule = { class = "Virt-manager" },
        properties = { floating = true }
    },

    {
        rule = { class = "vim" },
        properties = { floating = true }
    },

    {
        rule = { class = "Thunar" },
        properties = { floating = true }
    },

    {
        rule = { class = "Mumble" },
        properties = { floating = true }
    },

    {
        rule = { class = "Xarchiver" },
        properties = { floating = true }
    },

    {
        rule = { class = "Galculator" },
        properties = { floating = true }
    },

    {
        rule = { role = "task_dialog" },
        properties = { floating = true }
    },

    {
        rule = { role = "pop-up" },
        properties = { floating = true }
    },

    {
        rule = { class = "Pinentry-gtk-2" },
        properties = { floating = true }
    },

    {
        rule = { name = "Minecraft*" },
        properties = { floating = true }
    },

    {
        rule = { class = "Sxiv" },
        properties = { floating = true }
    },

    {
        rule = { class = "ncmpcpp" },
        properties = { floating = true }
    },

    {
        rule = { class = "mutt" },
        properties = { floating = true }
    },

    {
        rule = { class = "Firefox" },
        properties = { tag = tags[1][1] }
    },

    {
        rule = { instance = "plugin-container" },
        properties = { tag = tags[1][1], floating = true }
    },

    {
        rule = { class = "Gimp" },
        properties = { tag = tags[1][4] }
    },

    {
        rule = { class = "float-term" },
        properties = { floating = true }
    },

    {
        rule = { class = "Gimp", role = "gimp-image-window" },
        properties = {
            maximized_horizontal = true,
            maximized_vertical = true
        }
    },
}
-- }}}

-- {{{ Signals
-- signal function to execute when a new client appears.
-- local sloppyfocus_last = { c = nil }
client.connect_signal("manage", function(c, startup)
    if not startup and not c.size_hints.user_position
            and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
            awful.button({}, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end))

        -- widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- the title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c, { size = 16 }):set_widget(layout)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_color = beautiful.border_normal
        else
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end)
-- }}}

-- {{{ No DPMS for fullscreen clients
local fullscreened_clients = {}

local function remove_client(tabl, c)
    local index = awful.util.table.hasitem(tabl, c)
    if index then
        table.remove(tabl, index)
        if #tabl == 0 then
            awful.util.spawn("xset s on")
            awful.util.spawn("xset +dpms")
        end
    end
end

client.connect_signal("property::fullscreen",
    function(c)
        if c.fullscreen then
            table.insert(fullscreened_clients, c)
            if #fullscreened_clients == 1 then
                awful.util.spawn("xset s off")
                awful.util.spawn("xset -dpms")
            end
        else
            remove_client(fullscreened_clients, c)
        end
    end)

client.connect_signal("unmanage",
    function(c)
        if c.fullscreen then
            remove_client(fullscreened_clients, c)
        end
    end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    if #clients > 0 then -- Fine grained borders and floaters control
        for _, c in pairs(clients) do -- Floaters always have borders
        -- No borders with only one humanly visible client
            if layout == "max" then
                c.border_width = 0
            elseif awful.client.floating.get(c) or layout == "floating" then
                c.border_width = beautiful.border_width
            elseif #clients == 1 then
                clients[1].border_width = 0
                if layout ~= "max" then
                    awful.client.moveresize(0, 0, 2, 0, clients[1])
                end
            else
                c.border_width = beautiful.border_width
            end
        end
    end
end)
end
-- }}}
