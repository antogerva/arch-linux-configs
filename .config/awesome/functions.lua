---- Functions

-- {{{ Markup functions
function setBg(bgcolor, text)
    return '<bg color="'..bgcolor..'" />'..text
end

function setFg(fgcolor, text)
    return '<span color="'..fgcolor..'">'..text..'</span>'
end

function setBgFg(bgcolor, fgcolor, text)
    return '<bg color="'..bgcolor..'" /><span color="'..fgcolor..'">'..text..'</span>'
end

function setFont(font, text)
    return '<span font_desc="'..font..'">'..text..'</span>'
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
        text     = string.format('<span font_desc="%s">%s</span>', "monospace", setFg(beautiful.fg_focus, os.date("%a, %d %B %Y")) .. "\n" .. cal),
        timeout  = 0, hover_timeout = 0.5,
        width    = 125,
        position = "bottom_right",
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
        naughty.notify({ title      = "Wifi Warning",
                         text       = "Wifi Down! ("..wifiStrength.."% connectivity)",
                         timeout    = 3,
                         position   = "bottom_right",
                         fg         = beautiful.fg_focus,
                         bg         = beautiful.bg_focus
                       })
    end
    
    wifiwidget.text = spacer..setFg(beautiful.fg_focus, "WFi:")..spacer..wifiStrength.."%"..spacer
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
        battery = "A/C"..spacer.."("..battery..")"
    elseif sta:match("Discharging") then
        dir = "v"
        if tonumber(battery) >= 25 and tonumber(battery) <= 50 then
            battery = setFg("#e6d51d", battery)
        elseif tonumber(battery) < 25 then
            if tonumber(battery) <= 10 then
                naughty.notify({ title      = "Battery Warning",
                                 text       = "Battery low!"..spacer..battery.."%"..spacer.."left!",
                                 timeout    = 5,
                                 position   = "bottom_right",
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
    
    batterywidget.text = spacer..setFg(beautiful.fg_focus, "Bat:")..spacer..dir..battery..dir..spacer
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

    memwidget.text = spacer..setFg(beautiful.fg_focus, "Mem:")..memUsePct.."%"..spacer.."("..memInUse.."M)"..spacer
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
        cpu = setFg("#994044", cpu)
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
        gpuTemp = setFg("#994044", gpuTemp)
    end
    
    return gpuTemp
end

function sysInfo(widget, args)
    local core1 = spacer..setFg(beautiful.fg_focus, "C1:")..args[2].."%"..spacer..cputemp(0).."°"
    local core2 = spacer..setFg(beautiful.fg_focus, "C2:")..args[3].."%"..spacer..cputemp(1).."°"
    local gpu = spacer..setFg(beautiful.fg_focus, "G:")..gputemp().."°"..spacer
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
    
    return spacer..setFg(beautiful.fg_focus, "Vol:")..volume..spacer
end
-- }}}
