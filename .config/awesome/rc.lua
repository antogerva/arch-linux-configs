--[[    $HOME/.config/awesome/rc.lua
        Awesome Window Manager configuration file by STxza        
        - only works with awesome-git newer than 31/12/2008 
        - last update: 02/01/2009                                                ]]--
        
io.stderr:write("\n\r::: Awesome Loaded @ ", os.time(), " :::\r\n")
-------------------------------------------------------------------------------------
-- {{{ Imports

-- Load default libraries
require("awful")
require("beautiful")
require("naughty")
require("wicked")
require("revelation")

-- Load my functions
require("functions")

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Variable definitions

-- Themes define colours, icons, and wallpapers
theme_path = os.getenv("HOME").."/.config/awesome/themes/stxza"

-- Load theme
beautiful.init(theme_path)

-- Apps
terminal = "SHELL=/bin/zsh urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser = "/usr/bin/firefox"
fileManager = "pcmanfm"

-- Volume
cardid = 0
channel = "Master"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

-- Table of clients that should be set floating. The index may be either
-- the application class or instance. The instance is useful when running
-- a console app in a terminal like (Music on Console)
--    xterm -name mocp -e mocp
floatapps =
{
    ["gimp"] = true,
    ["transmission"] = true
}

-- Applications to be moved to a pre-defined tag by class or instance.
-- Use the screen and tags indices.
apptags =
{
    ["Firefox"] = { screen = 1, tag = 2 },
    ["transmission"] = { screen = 1, tag = 2 },
    ["pcmanfm"] = { screen = 1, tag = 4 },
    ["geeqie"] = { screen = 1, tag = 6 },
    ["gvim"] = { screen = 1, tag = 3 },
    ["geany"] = { screen = 1, tag = 3 },
    ["Gimp"] = { screen = 1, tag = 5 },
    ["Eclipse"] = { screen = 1, tag = 3 },
    ["OpenOffice.org 3.1"] = { screen = 1, tag = 6 }
}

-- Define if we want to use titlebar on all applications.
use_titlebar = false

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Tags

-- Define tags table.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = {}
    -- Create 6 tags per screen.
    for tagnumber = 1, 6 do
        tags[s][tagnumber] = tag(tagnumber)
        -- Add tags to screen one by one
        tags[s][tagnumber].screen = s
        -- Set mwfacts
        awful.tag.setmwfact(0.618033988769, tags[s][tagnumber])
    end
    
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end

-- Layout presets
awful.layout.set(awful.layout.suit.tile.bottom, tags[1][1])
awful.layout.set(awful.layout.suit.tiled, tags[1][2])
awful.layout.set(awful.layout.suit.max, tags[1][4])
awful.layout.set(awful.layout.suit.floating, tags[1][5])
awful.layout.set(awful.layout.suit.max, tags[1][6])

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Wibox
-- Please note the functions feeding some of the widgets are found in functions.lua

-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

-- Main menu
mymainmenu = awful.menu.new({ items = { { "Term"    , terminal },
                                        { "FF" , browser },
                                        { "PCManFM"     , fileManager },
                                        { "Gvim"        , "gvim" },
                                        { "Gimp"        , "gimp" },
                                        { "Screen"      , terminal.." -e screen -RR" },
                                        { "Awesome"     , myawesomemenu }
                                      }
                                      , border_width = beautiful.border_width_menu
                            })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon)
                                            , menu = mymainmenu 
                                   })

-- Create a systray
mysystray = widget({ type = "systray", align = "right" })

-- Simple spacer we can use to get cleaner code
spacer = " "

-- Separator icon
separator = widget({ type = "imagebox", name = "separator", align = "right" })
separator.image = image(awful.util.getdir("config").."/icons/separators/link2.png")

-- Create the clock widget
clockwidget = widget({ type = "textbox", name = "clockwidget", align = "right" })
-- Run it once so we don't have to wait for the hooks to see our clock
clockInfo("%d/%m/%Y", "%T")

-- Create the wifi widget
wifiwidget = widget({ type = "textbox", name = "wifiwidget", align = "right" })
-- Run it once so we don't have to wait for the hooks to see our signal strength
wifiInfo("wlan0")

-- Create the battery widget
batterywidget = widget({ type = "textbox", name = "batterywidget", align = "right" })
-- Run it once so we don't have to wait for the hooks to see our percentage
batteryInfo("BAT0")

-- Create the memory widget
memwidget = widget({ type = "textbox", name = "memwidget", align = "right" })
-- Run it once so we don't have to wait for the hooks to see our memory usage
memInfo()

-- Create the File Sys Usage widget
fswidget = widget({ type = 'textbox', name = 'fswidget', align = 'right' })
wicked.register(fswidget, wicked.widgets.fs, 
    spacer..setFg(beautiful.fg_focus, "/:")..'${/ usep}%'..spacer..setFg(beautiful.fg_focus, "~:")..'${/home usep}%'..spacer, 
15)

-- Create the CPU Usage, CPU Temps, GPU Temp widget
syswidget = widget({ type = 'textbox', name = 'syswidget', align = 'right' })
wicked.register(syswidget, 'cpu', sysInfo, 15, nil, 2)

-- Create the volume widget
volumewidget = widget({ type = 'textbox', name = 'volumewidget', align = 'right' })
wicked.register(volumewidget, getVol, "$1", 15)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = { button({ }, 1, awful.tag.viewonly),
                      button({ modkey }, 1, awful.client.movetotag),
                      button({ }, 3, function (tag) tag.selected = not tag.selected end),
                      button({ modkey }, 3, awful.client.toggletag),
                      button({ }, 4, awful.tag.viewnext),
                      button({ }, 5, awful.tag.viewprev) 
                    }
                      
mytasklist = {}
mytasklist.buttons = { button({ }, 1, function (c) client.focus = c; c:raise() end),
                       button({ }, 3, function () awful.menu.clients({ width=250 }) end),
                       button({ }, 4, function () awful.client.focus.byidx(1) end),
                       button({ }, 5, function () awful.client.focus.byidx(-1) end) 
                     }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = widget({ type = "textbox", align = "left" })
    
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = widget({ type = "imagebox", align = "right" })
    mylayoutbox[s]:buttons({ button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                             button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                             button({ }, 5, function () awful.layout.inc(layouts, -1) end) 
                           })
                             
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist.new(function(c)
                                                if c == client.focus then
                                                  return awful.widget.tasklist.label.currenttags(c, s)
                                                end
                                              end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = wibox({ 
        position = "bottom", 
        height = 16, 
        fg = beautiful.fg_normal, 
        bg = beautiful.bg_normal, 
        border_color = beautiful.border_wibox, 
        border_width = beautiful.border_width_wibox
    })
    
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {  --mylauncher,
                            mytaglist[s],
                            mytasklist[s],
                            mypromptbox[s],
                            separator,
                            syswidget,
                            separator,
                            memwidget,
                            separator,
                            fswidget,
                            separator,
                            wifiwidget,
                            separator,
                            batterywidget,
                            separator,
                            volumewidget,
                            separator,
                            clockwidget,
                            s == 1 and mysystray or nil,
                            mylayoutbox[s] 
                         }
    mywibox[s].screen = s
end

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Mouse bindings

awesome.buttons({
    button({ }, 3, function () mymainmenu:toggle() end),
    button({ }, 4, awful.tag.viewnext),
    button({ }, 5, awful.tag.viewprev)
})

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Key bindings

-- Bind keyboard digits
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(6, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    -- Mod+F1-F6 focuses tag 1-6
    key({ modkey }, "F"..i,
        function ()
            local screen = mouse.screen
            if tags[screen][i] then
                awful.tag.viewonly(tags[screen][i])
            end
        end):add()
    -- Mod+Ctrl+F1-F6 additionally shows clients from tag 1-6
    key({ modkey, "Control" }, "F"..i,
        function ()
            local screen = mouse.screen
            if tags[screen][i] then
                tags[screen][i].selected = not tags[screen][i].selected
            end
        end):add()
    -- Mod+Shift+F1-F6 moves the current client to tag 1-6
    key({ modkey, "Shift" }, "F"..i,
        function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
            end
        end):add()
    -- Mod+Ctrl+Shift+F1-F6 toggles the current client to tag 1-6    
    key({ modkey, "Control", "Shift" }, "F"..i,
        function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.toggletag(tags[client.focus.screen][i])
            end
        end):add()
end

-- Standard Bindings
-- Change Tags
key({ modkey }              , "Left"    , awful.tag.viewprev):add()
key({ modkey }              , "Right"   , awful.tag.viewnext):add()
key({ modkey }              , "Escape"  , awful.tag.history.restore):add()

-- Client launching
key({ modkey }              , "x"       , function () awful.util.spawn(terminal) end):add()
key({ modkey }              , "f"       , function () awful.util.spawn(browser) end):add()
key({ modkey }              , "p"       , function () awful.util.spawn(fileManager) end):add()
key({ modkey }              , "g"       , function () awful.util.spawn("geany") end):add()
key({ modkey }              , "e"       , function () awful.util.spawn("eclipse") end):add()
key({ modkey }              , "o"       , function () awful.util.spawn("soffice-dev") end):add()

-- Client control
key({ modkey }              , "c"       , function () client.focus:kill() end):add()
key({ modkey, "Shift" }     , "r"       , function () client.focus:redraw() end):add()
key({ modkey, "Control" }   , "space"   , awful.client.floating.toggle):add()
key({ modkey }              , "j"       , function () awful.client.focus.byidx(1); client.focus:raise() end):add()
key({ modkey }              , "k"       , function () awful.client.focus.byidx(-1);  client.focus:raise() end):add()
key({ modkey }              , "m"       , function () if client.focus then client.focus.maximized_horizontal = not client.focus.maximized_horizontal
                                                             client.focus.maximized_vertical = not client.focus.maximized_vertical end end):add()
                                                             
-- Awesome control
key({ modkey, "Control" }   , "r"       , function () mypromptbox[mouse.screen].text = awful.util.escape(awful.util.restart()) end):add()
key({ modkey, "Shift" }     , "q"       , awesome.quit):add()
key({ modkey }              , "r"       , function () awful.prompt.run({ prompt = "Run: " }, mypromptbox[mouse.screen], awful.util.spawn, awful.completion.bash, os.getenv("HOME").."/.cache/awesome/history") end):add()

-- Layout control
key({ modkey }              , "space"   , function () awful.layout.inc(layouts, 1) end):add()
key({ modkey, "Shift" }     , "space"   , function () awful.layout.inc(layouts, -1) end):add()
key({ modkey }              , "l"       , function () awful.tag.incmwfact(0.05) end):add()
key({ modkey }              , "h"       , function () awful.tag.incmwfact(-0.05) end):add()
key({ modkey, "Shift" }     , "h"       , function () awful.tag.incnmaster(1) end):add()
key({ modkey, "Shift" }     , "l"       , function () awful.tag.incnmaster(-1) end):add()
key({ modkey, "Control" }   , "h"       , function () awful.tag.incncol(1) end):add()
key({ modkey, "Control" }   , "l"       , function () awful.tag.incncol(-1) end):add()

-- Shows or hides the statusbar
key({ modkey }, "b", function () 
    if mywibox[mouse.screen].screen == nil then 
        mywibox[mouse.screen].screen = mouse.screen
    else
        mywibox[mouse.screen].screen = nil
    end
end):add()

-- Mod+Tab: Run revelation
key({ modkey, "Control" }, "z", revelation.revelation):add()

-- Rotate clients and focus master
key({ modkey }, "Tab", function ()
    local allclients = awful.client.visible(client.focus.screen)
  
    for i,v in ipairs(allclients) do
      if allclients[i+1] then
        allclients[i+1]:swap(v)
      end
    end
    awful.client.focus.byidx(-1)
  end):add()

-- The other way 'round!
key({ modkey, "Shift" }, "Tab", function ()
    local allclients = awful.client.visible(client.focus.screen)
    local toswap

    for i,v in ipairs(allclients) do
      if toswap then
        toswap:swap(v)
        toswap = v
      else
        toswap = v
      end
    end
    awful.client.focus.byidx(-1)
  end):add()

-- }}}
-------------------------------------------------------------------------------------
-- {{{ Hooks

-- Hook function to execute when focusing a client.
awful.hooks.focus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_focus
    end
end)

-- Hook function to execute when unfocusing a client.
awful.hooks.unfocus.register(function (c)
    if not awful.client.ismarked(c) then
        c.border_color = beautiful.border_normal
    end
end)

-- Hook function to execute when marking a client
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)

-- Hook function to execute when unmarking a client.
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)

-- Hook function to execute when the mouse enters a client.
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- Hook function to execute when a new client appears.
awful.hooks.manage.register(function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end
    
    if use_titlebar then
        -- Add a titlebar
        awful.titlebar.add(c, { modkey = modkey })
    end
    
    -- Add mouse bindings
    c:buttons({
        button({ }, 1, function (c) client.focus = c; c:raise() end),
        button({ modkey }, 1, awful.mouse.client.move),
        button({ modkey }, 3, awful.mouse.client.resize)
    })
    
    -- New client may not receive focus
    -- if they're not focusable, so set border anyway.
    c.border_width = beautiful.border_width
    c.border_color = beautiful.border_normal

    -- Check if the application should be floating.
    local cls = c.class
    local inst = c.instance
    if floatapps[cls] then
        awful.client.floating.set(cls, floatapps[cls])
    elseif floatapps[inst] then
        awful.client.floating.set(cls, floatapps[inst])
    end

    -- Check application->screen/tag mappings.
    local target
    if apptags[cls] then
        target = apptags[cls]
    elseif apptags[inst] then
        target = apptags[inst]
    end
    if target then
        c.screen = target.screen
        awful.client.movetotag(tags[target.screen][target.tag], c)
    end

    -- Do this after tag mapping, so you don't see it on the wrong tag for a split second.
    client.focus = c

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    awful.client.setslave(c)

    -- Honor size hints: if you want to drop the gaps between windows, set this to false.
    c.honorsizehints = false
end)

-- Hook function to execute when arranging the screen.
-- (tag switch, new client, etc)
awful.hooks.arrange.register(function (screen)
    local layout = awful.layout.getname(awful.layout.get(screen))
    if layout and beautiful["layout_" ..layout] then
        mylayoutbox[screen].image = image(beautiful["layout_" .. layout])
    else
        mylayoutbox[screen].image = nil
    end

    -- Give focus to the latest client in history if no window has focus
    -- or if the current window is a desktop or a dock one.
    if not client.focus then
        local c = awful.client.focus.history.get(screen, 0)
        if c then client.focus = c end
    end
end)

-- Hooks for Naughty Calendar
clockwidget.mouse_enter = function()
    add_calendar(0)
end
clockwidget.mouse_leave = remove_calendar

clockwidget:buttons({
    button({ }, 4, function()
        add_calendar(-1)
    end),
    button({ }, 5, function()
        add_calendar(1)
    end),
})

-- Timed hooks for the widget functions
-- 1 second
awful.hooks.timer.register(1, function ()
    clockInfo("%T")
end)

-- 5 seconds
awful.hooks.timer.register(15, function()
    memInfo()
    wifiInfo("wlan0")
end)

-- 20 seconds
awful.hooks.timer.register(20, function()
    batteryInfo("BAT0")
end)

-- }}}
