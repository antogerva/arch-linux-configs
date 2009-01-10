--[[    $HOME/.config/awesome/functions.lua
        Awesome Window Manager configuration functions file by STxza        
        - only works with awesome-git newer than 07/01/2009 
        - last update: 07/01/2009                                                ]]--
        
---- Functions

-- {{{ Markup functions
function setBg(bgcolor, text)
    if text then
        return string.format('<bg color="%s" />%s', bgcolor, text)
    end
end

function setFg(fgcolor, text)
    if text then
        return string.format('<span color="%s">%s</span>', fgcolor, text)
    end
end

function setBgFg(bgcolor, fgcolor, text)
    if text then
        return string.format('<bg color="%s"/><span color="%s">%s</span>', bgcolor, fgcolor, text)
    end
end

function setFont(font, text)
    if text then
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
        text     = string.format('<span font_desc="%s">%s</span>', "monospace", 
                   setFg(beautiful.fg_focus, os.date("%a, %d %B %Y")) .. "\n" .. setFg(beautiful.fg_widg, cal)),
        timeout  = 0, hover_timeout = 0.5,
        width    = 125,
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
        wifiStrength = setFg("#ff6565", wifiStrength)
        naughty.notify({ title      = setFg(beautiful.fg_widg, "Warning"),
                         text       = setFg(beautiful.fg_widg, "Wifi Down! (")..wifiStrength..setFg(beautiful.fg_widg, "% connectivity)"),
                         timeout    = 3,
                         position   = "top_right",
                         fg         = beautiful.fg_focus,
                         bg         = beautiful.bg_focus
                       })
    end
    
    wifiwidget.text = setFg(beautiful.fg_widg, ""..wifiStrength.."%")..spacer
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
        dir = "^"
        battery = "AC"..spacer.."("..battery..")"
    elseif sta:match("Discharging") then
        dir = "v"
        if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
            battery = setFg("#e6d51d", battery)
        elseif tonumber(battery) < 25 then
            if tonumber(battery) <= 10 then
                naughty.notify({ title      = setFg(beautiful.fg_widg, "Battery Warning"),
                                 text       = setFg(beautiful.fg_widg, "Battery low!")..spacer..battery..setFg(beautiful.fg_widg, "%")..spacer..setFg(beautiful.fg_widg, "left!"),
                                 timeout    = 5,
                                 position   = "top_right",
                                 fg         = beautiful.fg_focus,
                                 bg         = beautiful.bg_focus
                               })
            end
            battery = setFg("#ff6565", battery)
        end
    else
        dir = "="
        battery = "A/C"
    end
    
    batterywidget.text = spacer..setFg(beautiful.fg_widg, ""..dir..""..battery..""..dir.."")..spacer
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

    memwidget.text = spacer..setFg(beautiful.fg_widg, ""..memUsePct.."%")..spacer.."("..setFg(beautiful.fg_widg,""..memInUse.."M")..")"..spacer
end
-- }}}

-- {{{ CPU Usage, CPU & GPU Temps
function cputemp(core)
	local command = "sensors coretemp-isa-* | grep 'Core "..tostring(core).."'"
	local cpu = io.popen(command):read("*all")

	if (cpu == nil) then
		return ''
	end

	local pos = cpu:find('+')+1
	cpu = string.sub(cpu, pos, pos+3)
    
    if tonumber(cpu) >= 45 then
        cpu = setFg("#B9DCE7", cpu)
    end
    
	return cpu
end

function gputemp()
    local gT = io.popen("nvidia-settings -q gpucoretemp | grep '):' | awk '{print $4}' | cut -d'.' -f1")
    local gpuTemp = gT:read()
    gT:close() 
    
    -- pL is the nvidia performance setting thats currently being employed by the driver
    -- local pL = io.popen("nvidia-settings -q GPUCurrentPerfLevel | grep -m1 PerfLevel | cut -d' ' -f6 | cut -d'.' -f1")
    -- local perfL = pL:read()
    -- pL:close()
    
    if (gpuTemp == nil) then
        return ''
	end
    
    if tonumber(gpuTemp) >= 65 then
        gpuTemp = setFg("#B9DCE7", gpuTemp)
    end
    
    return gpuTemp
end

function sysInfo(widget, args)
    local core1 = spacer..setFg(beautiful.fg_focus, "C1:")..setFg(beautiful.fg_widg, ""..args[2].."%")..spacer..setFg(beautiful.fg_widg, ""..cputemp(0).."°")
    local core2 = spacer..setFg(beautiful.fg_focus, "C2:")..setFg(beautiful.fg_widg, ""..args[3].."%")..spacer..setFg(beautiful.fg_widg, ""..cputemp(1).."°")
    local gpu = spacer..setFg(beautiful.fg_focus, "G:")..setFg(beautiful.fg_widg, ""..gputemp().."°")..spacer
    local sysinfo = core1..core2..gpu 
    
	return sysinfo
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
    
    return setFg(beautiful.fg_widg, volume)..spacer
end
-- }}}
