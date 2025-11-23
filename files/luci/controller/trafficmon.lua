-- /usr/lib/lua/luci/controller/trafficmon.lua
module("luci.controller.trafficmon", package.seeall)

function index()
    entry({"admin", "status", "trafficmon"}, 
          template("trafficmon/overview"), 
          _("Traffic Monitor"), 10)
    
    entry({"admin", "status", "trafficmon", "data"}, 
          call("action_data")).leaf = true
    
    entry({"admin", "status", "trafficmon", "reset"}, 
          call("action_reset")).leaf = true
end

function action_data()
    local json = require "luci.jsonc"
    local uci = require "luci.model.uci".cursor()
    
    -- 讀取流量數據
    local data = get_traffic_stats()
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(data)
end

function action_reset()
    local json = require "luci.jsonc"
    
    -- 重置統計
    os.execute("/etc/init.d/trafficmon reset")
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({success = true})
end

function get_traffic_stats()
    local stats = {}
    local file = io.open("/tmp/trafficmon/stats.json", "r")
    
    if file then
        local content = file:read("*all")
        file:close()
        
        local json = require "luci.jsonc"
        stats = json.parse(content) or {}
    end
    
    return stats
end
