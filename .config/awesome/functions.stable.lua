--[[ $HOME/.config/awesome/functions.lua
     Awesome Window Manager configuration functions file by STxza/ST.x        
     - only works with awesome-git newer than 12/01/2009
                                                                    ]]--

---- Functions

-- {{{ Markup functions
function setBg(bgcolor, text)
    if text ~= nil then
        return string.format('<bg color="%s" />%s', bgcolor, text)
    end
end

function setFg(fgcolor, text)
    if text ~= nil then
        return string.format('<span color="%s">%s</span>', fgcolor, text)
    end
end

function setBgFg(bgcolor, fgcolor, text)
    if text ~= nil then
        return string.format('<bg color="%s"/><span color="%s">%s</span>', bgcolor, fgcolor, text)
    end
end

function setFont(font, text)
    if text ~= nil then
        return string.format('<span font_desc="%s">%s</span>', font, text)
    end
end
-- }}}

---- Widget functions
-- {{{ Clock
function clockInfo(timeformat)
    local time = os.date(timeformat)    
    clockwidget.text = spacer..setFg(beautiful.fg_focus, time)..spacer
end
-- }}}

-- {{{ Calendar
local calendar = nil
local offset = 0

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text     = string.format('<span font_desc="%s">%s</span>', "Terminus", 
                   setFg(beautiful.fg_focus, os.date("%a, %d %B %Y")) .. "\n" .. setFg(beautiful.fg_widg, cal)),
        timeout  = 0, hover_timeout = 0.5,
        width    = 145,
        position = "top_right",
        bg       = beautiful.bg_focus
    })
end
-- }}}

-- {{{ Wifi signal strength
function wifiInfo(adapter)
    local f = io.open("/sys/class/net/"..adapter.."/wireless/link")
    local wifiStrength = f:read()
    f:close()
    
    if wifiStrength == "0" then
        -- Naughtify me when wifi link gets really low
        wifiStrength = setFg("#ff6565", wifiStrength)
        naughty.notify({ title      = setFg(beautiful.fg_widg, "Warning"),
                         text       = setFg(beautiful.fg_widg, "Wifi Down! (")..wifiStrength..setFg(beautiful.fg_widg, "% connectivity)"),
                         timeout    = 5,
                         position   = "top_right",
                         bg         = beautiful.bg_focus
                       })
    end
    
    wifiwidget.text = setFg(beautiful.fg_widg, wifiStrength).."%"..spacer
end
-- }}}

-- {{{ Battery (BAT0)
function batteryInfo(adapter)
    local fcur = io.open("/sys/class/power_supply/"..adapter.."/charge_now")    
    local fcap = io.open("/sys/class/power_supply/"..adapter.."/charge_full")
    local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
    local cur = fcur:read()
    fcur:close()
    local cap = fcap:read()
    fcap:close()
    local sta = fsta:read()
    fsta:close()
    
    local battery = math.floor(cur * 100 / cap)
    
    if sta:match("Charging") then
        dir = setFg("#90EE90", "^")
        battery = battery.."%"
    elseif sta:match("Discharging") then
        dir = setFg("#A52A2A", "v")
        if tonumber(battery) > 25 and tonumber(battery) < 50 then
            battery = setFg("#E6E51E", battery).."%"
        elseif tonumber(battery) < 25 then
            if tonumber(battery) <= 10 then
                -- Naughtify me when battery gets really low
                naughty.notify({ title      = setFg(beautiful.fg_widg, "Battery Warning"),
                                 text       = setFg(beautiful.fg_widg, "Battery low!")..spacer..battery..setFg(beautiful.fg_widg, "%")..spacer..setFg(beautiful.fg_widg, "left!"),
                                 timeout    = 5,
                                 position   = "top_right",
                                 bg         = beautiful.bg_focus
                               })
            end
            battery = setFg("#FF6565", battery).."%"
        end
    else
        dir = ""
        battery = "AC"
    end
    
    batterywidget.text = dir..setFg(beautiful.fg_widg, battery)..dir..spacer
end
-- }}}

-- {{{ Memory
function memInfo()
    local f = io.open("/proc/meminfo")
 
    for line in f:lines() do
        if line:match("^MemTotal.*") then
            memTotal = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^MemFree.*") then
            memFree = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^Buffers.*") then
            memBuffers = math.floor(tonumber(line:match("(%d+)")) / 1024)
        elseif line:match("^Cached.*") then
            memCached = math.floor(tonumber(line:match("(%d+)")) / 1024)
        end
    end
    f:close()
 
    memFree = memFree + memBuffers + memCached
    memInUse = memTotal - memFree
    memUsePct = math.floor(memInUse / memTotal * 100)
 
    if tonumber(memUsePct) >= 15 and tonumber(memInUse) >= 306 then
        memUsePct = setFg("#FF6565", memUsePct)
        memInUse = setFg("#FF6565", memInUse)
    else
        memUsePct = setFg(beautiful.fg_widg, memUsePct)
        memInUse = setFg(beautiful.fg_widg, ""..memInUse.."M")
    end

    --memwidget.text = setFg(beautiful.fg_widg, ""..memUsePct.."%").."("..setFg(beautiful.fg_widg,""..memInUse.."M")..")"..spacer
    memwidget.text = memUsePct.."%".."("..memInUse..")"..spacer
end
-- }}}

-- {{{ CPU Usage, CPU & GPU Temps
function sysInfo()
	-- CPU Temps
    local comm0 = 'sensors \'coretemp-isa-*\' | grep \'Core 0\''
	local core0 = io.popen(comm0):read("*all")    
    local comm1 = 'sensors \'coretemp-isa-*\' | grep \'Core 1\''
	local core1 = io.popen(comm1):read("*all")

	if ((core0 == nil) or (core1 == nil)) then
		return ''
	else
        local pos0 = core0:find('+')+1
        core0 = string.sub(core0, pos0, pos0+1)
        local pos1 = core1:find('+')+1
        core1 = string.sub(core1, pos1, pos1+1)
        
        if tonumber(core0) >= 40 then
            core0 = setFg("#B9DCE7", core0)
        end
        if tonumber(core1) >= 40 then
            core1 = setFg("#B9DCE7", core1)
        end
    end
    core0 = setFg(beautiful.fg_focus, "C:")..setFg(beautiful.fg_widg, ""..core0.."°").."/"
    core1 = setFg(beautiful.fg_widg, ""..core1.."°")..spacer
    
    --[[ GPU Temp
    --local comm2 = 'nvidia-settings -q gpucoretemp | grep \'Attribute\' | sed \'s/[^1-9]//g\''
    --local comm2 = io.popen('/home/stxza/bin/nvidTemp.sh')
    --local gpuTemp = comm2:read()
    --comm2:close()
    
    if gpuTemp == nil then
        return ''
    else
        --local gpu = setFg(beautiful.fg_focus, "G:")..setFg(beautiful.fg_widg, gpuTemp)..spacer
        local gpu = gpuTemp..spacer
    end
    ]]--
    
    return core0..core1
end
-- }}}

-- {{{ CPU Usage & Speed
function cpuUsg(widget, args)
    local fcpufr = io.open("/proc/cpuinfo")
    local cpufr = fcpufr:read("*a"):match("cpu MHz%s*:%s*([^%s]*)")
    fcpufr:close()
    cpufr = setFg(beautiful.fg_widg, tonumber(cpufr).."MHz")..spacer
    local core1 = setFg(beautiful.fg_focus, "C1:")..setFg(beautiful.fg_widg, args[2]).."%"
    local core2 = spacer..setFg(beautiful.fg_focus, "C2:")..setFg(beautiful.fg_widg, args[3]).."%"
    local cpuUsg = cpufr..core1..core2..spacer 
    
	return cpuUsg
end
-- }}}

-- {{{ Volume
function getVol()
    local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")	
	local volume = string.match(status, "(%d?%d?%d)%%")
	volume = string.format("% 3d", volume)
	status = string.match(status, "%[(o[^%]]*)%]")
   
	if string.find(status, "on", 1, true) then
        volume = volume.."%"
	else
        volume = volume.."M"
	end
    
    return setFg(beautiful.fg_widg, volume:gsub("^%s*(.-)%s*$", "%1"))..spacer
end
-- }}}

-- {{{ Pacman Upgrade Query
--[[ added sudo
function pacinfo()
    local puSy = io.popen("sudo pacman -Sy")
    local pu = io.popen("sudo pacman -Qu")
	local pu_text = pu:read("*a")
    io.close(pu)
    io.close(puSy)
	
	local pacup = string.match(pu_text, "Targets %((%d+)%)")	
	if pu_text:match("no upgrades found.") then
		pacman = "0"
	else
		pacman = setFg(beautiful.fg_urgent, pacup)
	end
    	
	return spacer..pacman
end
--]]
