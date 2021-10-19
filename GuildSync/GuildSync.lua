local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")

function GetGuildFullName()
    local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
    if guildName == nil then
        print("Guild API not available yet.")
        return
    end
    return guildName .. "-" .. GetRealmName()
end

function GetGuildList()
    print("Guilds currently in database:")
    for x, y in pairs(GuildSyncDB["guilds"]) do
        print(x)
    end
end

function DoGuildFullSync()
    local inInstance, instanceType = IsInInstance()
    if inInstance == true then
        print("In Instance, exiting!")
        return
    end
    local guild = GetGuildFullName()
    if guild == nil then
        return
    end
    print("Starting sync for guild: " .. guild)
    GuildSyncDB["guilds"][guild] = {}
    local numTotalMembers, _, _ = GetNumGuildMembers();
    for i=1,numTotalMembers do
        local name, rank, rankIndex, level, class, _, note = GetGuildRosterInfo(i)
        GuildSyncDB["guilds"][guild][name] = {class, level, note}
    end
    print("Finished sync for guild: " .. guild)
end

local function GuildSyncSlashCmd(msg, editbox)
    if strlower(msg) == "sync" then
        DoGuildFullSync()
    elseif strlower(msg) == "list" then
        GetGuildList()
    else
        print("Guild: " .. GetGuildFullName())
        print("Commands: sync, list")
    end
end

SLASH_GUILDSYNC1 = "/gs"
SLASH_GUILDSYNC2 = "/guildsync"
SlashCmdList["GUILDSYNC"] = GuildSyncSlashCmd

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "GuildSync" then
        print("ADDON_LOADED")
        if GuildSyncDB == nil then
            print("First run, initalizing database...")
            GuildSyncDB = {}
            GuildSyncDB["guilds"] = {}
            print(GuildSyncDB)
        else
            print("Database loaded...")
        end
        C_Timer.After (30, DoGuildFullSync);
    elseif event == "GUILD_ROSTER_UPDATE" and arg1 == true then
        print("GUILD_ROSTER_UPDATE")
        DoGuildFullSync()
--    elseif event == "PLAYER_GUILD_UPDATE" then
--        print("PLAYER_GUILD_UPDATE")
--        print(arg1)
--        if GuildSyncGuildUpdateC == nil then
--            print("FIRST RUN: PLAYER_GUILD_UPDATE")
--            GuildDyncGuildUpdateC = 1
--        elseif GuildSyncGuildUpdateC > 1 then
--            DoGuildFullSync()
--        end

    end
end)
