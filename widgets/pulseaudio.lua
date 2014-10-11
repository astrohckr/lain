
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013, Luke Bonham                     
      * (c) 2010, Adrian C. <anrxc@sysphere.org>  
                                                  
--]]

local newtimer        = require("lain.helpers").newtimer

local wibox           = require("wibox")

local io              = { popen  = io.popen }
local string          = { match  = string.match }

local setmetatable    = setmetatable

-- PULSEAUDIO volume
-- lain.widgets.pulseaudio
local pulseaudio = {}

local function worker(args)
    local args     = args or {}
    local timeout  = args.timeout or 5
    local settings = args.settings or function() end

    pulseaudio.widget = wibox.widget.textbox('')

    function pulseaudio.update()
        local f = assert(io.popen('pamixer --get-volume'))
        local mixer = f:read("*a")
        f:close()

        volume_now = {} 

        volume_now.level, volume_now.status = string.match(mixer, "([%d]+)%%.*%[([%l]*)")

        if volume_now.level == nil
        then
            volume_now.level  = "0"
            volume_now.status = "off"
        end

        if volume_now.status == ""
        then
            if volume_now.level == "0"
            then
                volume_now.status = "off"
            else
                volume_now.status = "on"
            end
        end

        widget = pulseaudio.widget
        settings()
    end

    newtimer("pulseaudio", timeout, pulseaudio.update)

    return setmetatable(pulseaudio, { __index = pulseaudio.widget })
end

return setmetatable(pulseaudio, { __call = function(_, ...) return worker(...) end })
