
groupCounter = 100
unitCounter = 100

function DropoffGroupDirect(typeList, groupName, radius, xCenter, yCenter, xDest, yDest)
    local group = {
        ["visible"] = false,
        ["taskSelected"] = true,
        ["groupId"] = groupCounter,
        ["hidden"] = false,
        ["units"] = {},
        ["y"] = yCenter,
        ["x"] = xCenter,
        ["name"] = groupName .. groupCounter,
        ["start_time"] = 0,
        ["task"] = "Ground Nothing",
        ["route"] = {
            ["points"] = 
            {
                [1] = 
                {
                    ["alt"] = 41,
                    ["type"] = "Turning Point",
                    ["ETA"] = 0,
                    ["alt_type"] = "BARO",
                    ["formation_template"] = "",
                    ["y"] = yCenter,
                    ["x"] = xCenter,
                    ["ETA_locked"] = true,
                    ["speed"] = 5.5555555555556,
                    ["action"] = "Diamond",
                    ["task"] = 
                    {
                        ["id"] = "ComboTask",
                        ["params"] = 
                        {
                            ["tasks"] = 
                            {
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["speed_locked"] = false,
                }, -- end of [1]
                [2] = 
                {
                    ["alt"] = 54,
                    ["type"] = "Turning Point",
                    ["ETA"] = 52.09716824195,
                    ["alt_type"] = "BARO",
                    ["formation_template"] = "",
                    ["y"] = yDest,
                    ["x"] = xDest,
                    ["ETA_locked"] = false,
                    ["speed"] = 5.5555555555556,
                    ["action"] = "Diamond",
                    ["task"] = 
                    {
                        ["id"] = "ComboTask",
                        ["params"] = 
                        {
                            ["tasks"] = 
                            {
                            }, -- end of ["tasks"]
                        }, -- end of ["params"]
                    }, -- end of ["task"]
                    ["speed_locked"] = false,
                }, -- end of [2]
            }, -- end of ["points"]
        }, -- end of ["route"]
    }

    groupCounter = groupCounter + 1
    
    for i = 1,#typeList do  
        local angle = math.pi * 2 * (i-1) / #typeList
        local xofs = math.cos(angle) * radius
        local yofs = math.sin(angle) * radius
        local unitType = typeList[i]
        group.units[i] = NewSoldierUnit(xCenter + xofs, yCenter + yofs, angle, unitType)        
    end
    
    return group
end

function NewSoldierUnit(x, y, heading, unitType)
    local unit = {
        ["y"] = y,
        ["type"] = unitType,
        ["name"] = "Unitname" .. unitCounter,
        ["unitId"] = unitCounter,
        ["heading"] = heading,
        ["playerCanDrive"] = true,
        ["skill"] = "Excellent",
        ["x"] = x,
    }
    
    unitCounter = unitCounter + 1
    
    return unit    
end

-- ZONE INITIALIZIATIONS ---------------------------------------------------------------------

Objectives = {
    [1] = {
        Name = "Batumi Power Plant",
        ZoneName = "Obj_BatumiPowerPlant",
        Owner = "Neutral"
    },
    [2] = {
        Name = "Batumi Dock",
        ZoneName = "Obj_BatumiDock",
        Owner = "Neutral"
    },
    [3] = {
        Name = "Mahindzhauri",
        ZoneName = "Obj_Mahind",
        Owner = "Neutral"
    }
}

PickupZones = {
    [1] = {
        Name = "Batumi Ramp",
        ZoneName = "PickupZone_BatumiRamp"
    },
}

DropoffZones = {
    [1] = {
        Name = "Batumi Power Plant",
        ZoneName = "DropoffZone_BatumiPowerPlant",
        DropFunction = DropoffGroupDirect
    },
    [2] = {
        Name = "Mahind",
        ZoneName = "DropoffZone_Mahind",
        DropFunction = DropoffGroupDirect
    },
    [3] = {
        Name = "Helvachauri",
        ZoneName = "DropoffZone_Helvachauri",
        DropFunction = DropoffGroupDirect
    },
    [4] = {
        Name = "Test",
        ZoneName = "TestTrigger",
        DropFunction = DropoffGroupDirect
    }
}

-- ZONE INITIALIZIATIONS ---------------------------------------------------------------------


function FillBlueUnitComposition(unitType)
    local retval = {}
    if(unitType == "heli") then
        for i=1,1 do
            retval[i] = "Soldier M249"
        end
        for i=2,7 do
            retval[i] = "Soldier M4"
        end
    elseif(unitType == "truck") then
        for i=1,2 do
            retval[i] = "Soldier M249"
        end
        for i=3,12 do
            retval[i] = "Soldier M4"
        end
    end
    
    return retval
end

function FillRedUnitComposition()
    local retval = {}
    for i=1,2 do
        retval[i] = "Soldier RPG"
    end
    for i=3,20 do
        retval[i] = "Infantry AK Ins"
    end

    return retval
end

function FindNearestPickupGroup(playerUnit, maxDistance)
    local retval = {
        Group = nil,
        Composition = {}
    }
    
    local playerpos = playerUnit:getPoint()
    
    local minDist = maxDistance
    
    local groups = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND)
    for i=1,#groups do
        local group = groups[i]
        if group ~= nil then
            local units = group:getUnits()
            local comp = {}
            local groupMin = maxDistance
            
            for j=1,#units do
                local unit = units[j]
                if unit ~= nil then
                    local unitpos = unit:getPoint()
                    local typename = unit:getTypeName()
                    if typename == "Soldier M249" or typename == "Soldier M4" then                        
                        table.insert(comp, typename)
                        
                        local dist = GetDistance(unitpos.x, unitpos.z, playerpos.x, playerpos.z)
                        if dist < groupMin then
                            groupMin = dist
                        end
                        
                    end
                end
                
            end
            
            if groupMin < minDist then
                minDist = groupMin
                retval.Composition = {}
                for i=1,#comp do
                    retval.Composition[i] = comp[i]
                end
                retval.Group = group            
            end
            
        end
    end
    
    return retval
end

UnitStateTable = {}


function UnitRadioCommand(unitName)
    local unit = Unit.getByName(unitName)
    
    if unit == nil then
        UnitStateTable[unitName] = {}
        return
    end
    
    local unitId = unit:getID()
    local group = unit:getGroup()
    local groupName = group:getName()
    local playerName = unit:getPlayerName()
    
    if UnitStateTable[unitName] == nil then
        UnitStateTable[unitName] = {}
        
        if unitName == "HueyPilot9" then
            UnitStateTable[unitName] = FillBlueUnitComposition("heli")
        end
    end
    
    local pickupZone = UnitInAnyPickupZone(unit)
    local dropoffZone = UnitInAnyDropoffZone(unit)
    
    if #UnitStateTable[unitName] > 0 then
        
        -- if in pickupZone (fob) then drop troops and credit score
        -- if in dropoff zone, then drop the troops in place
        -- if neither
        
        if dropoffZone ~= nil then
            local unitpos = unit:getPoint()
            local triggerZone = trigger.misc.getZone(dropoffZone.ZoneName)
            local newGroup = dropoffZone.DropFunction(UnitStateTable[unitName], "dynBlue", 15, unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
            coalition.addGroup(country.id.USA, Group.Category.GROUND, newGroup)
            
            trigger.action.outText(playerName .. " (" .. groupName .. ") dropped " .. #UnitStateTable[unitName] .. " soldiers at " .. dropoffZone.Name, 10)
            
            UnitStateTable[unitName] = {}
        else
            if pickupZone ~= nil then
                trigger.action.outText(playerName .. " (" .. groupName .. ") returned " .. #UnitStateTable[unitName] .. " soldiers to " .. pickupZone.Name, 10)
                UnitStateTable[unitName] = {}
            else
                trigger.action.outText(playerName .. " (" .. groupName .. ") isn't in a pickup or dropoff zone. (" .. #UnitStateTable[unitName] .. " soldiers aboard)", 10)
            end
        end
    else
        -- we're empty
        
        -- if we're in pickup zone, load troops
        if pickupZone ~= nil then
            UnitStateTable[unitName] = FillBlueUnitComposition("heli")
            trigger.action.outText(playerName .. " (" .. groupName .. ") loaded a squad at " .. pickupZone.Name .. ".", 10)
        else
            if dropoffZone ~= nil then
                -- check for troops to load
                local pickupResult = FindNearestPickupGroup(unit, 30)
                if pickupResult.Group ~= nil then
                    pickupResult.Group:destroy()
                    UnitStateTable[unitName] = pickupResult.Composition
                    trigger.action.outText(playerName .. " (" .. groupName .. ")  evacuated a squad of " .. #pickupResult.Composition .. " from " .. dropoffZone.Name , 10)
                else
                    trigger.action.outText(playerName .. " (" .. groupName .. ") must land within 30m of a squad for evac pickup.", 10)
                end
            else
                trigger.action.outText(playerName .. " (" .. groupName .. ") isn't in a pickup or dropoff zone. (" .. #UnitStateTable[unitName] .. " soldiers aboard)", 10)
            end
        end
        


    end
           
end

RadioCommandTable = {}

function AddRadioCommand(unitName)
    if RadioCommandTable[unitName] == nil then
        local unit = Unit.getByName(unitName)
        if unit == nil then
            return
        end
        
        local group = unit:getGroup()
        if group == nil then
            return
        end
        
        local gid = group:getID()
        
        missionCommands.addCommandForGroup(gid, "Load/unload Troops", nil, UnitRadioCommand, unitName)
        RadioCommandTable[unitName] = true
    end
end


function AddRadioCommands(arg, time)
    AddRadioCommand("Slick1")
    AddRadioCommand("Slick2")
    AddRadioCommand("Slick3")
    AddRadioCommand("Slick4")
    return time + 5
end

function GetDistance(xUnit, yUnit, xZone, yZone)
    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone
    return math.sqrt(xDiff * xDiff + yDiff * yDiff)    
end


function FindNearestObjective(unit, maxDistance)
    local minDist = maxDistance
    local minZone = nil
    local unitpos = unit:getPoint()
    
    for i=1,#Objectives do
        local zone = Objectives[i]
        local triggerZone = trigger.misc.getZone(zone.ZoneName)
        local dist = GetDistance(unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
        if dist < minDist then
            minDist = dist
            minZone = zone
        end
    end
    
    return minZone    
end

--GAME STATE TRACKING TABLES-----------------------------------
zoneTable = {}
zoneFriendly = {}
blueTransports = {'TEST_TRUCK'}
--GAME STATE TRACKING TABLES-----------------------------------


function StatusUpdate(args, time)
    for i=1,#Objectives do
        zoneTable[Objectives[i].Name] = 0
        zoneFriendly[Objectives[i].Name] = 0
    end

    local groups = coalition.getGroups(coalition.side.RED, Group.Category.GROUND)
    for i=1,#groups do
        local group = groups[i]
        if group ~= nil then
            local units = group:getUnits()
            for j=1,#units do
                local unit = units[j]
                if unit ~= nil then
                    local zone = FindNearestObjective(unit, 5000)
                    if zone ~= nil then
                        zoneTable[zone.Name] = zoneTable[zone.Name] + 1
                    end
                end
            end
        end
    end
    
    local groups = coalition.getGroups(coalition.side.BLUE, Group.Category.GROUND)
    for i=1,#groups do
        local group = groups[i]
        if group ~= nil then
            local units = group:getUnits()
            for j=1,#units do
                local unit = units[j]
                if unit ~= nil then
                    local typename = unit:getTypeName()
                    if typename == "Soldier M249" or typename == "Soldier M4" then
                        local zone = FindNearestObjective(unit, 2000)
                        if zone ~= nil then
                            zoneFriendly[zone.Name] = zoneFriendly[zone.Name] + 1
                        end
                    end
                end
            end
        end
    end

    for i=1,#Objectives do
        if (zoneFriendly[Objectives[i].Name] == 0 and zoneTable[Objectives[i].Name] == 0) then
            Objectives[i].Owner = "Neutral"
        elseif (zoneFriendly[Objectives[i].Name] > zoneTable[Objectives[i].Name]) then 
            Objectives[i].Owner = "Blue"
        else 
            Objectives[i].Owner = "Red"
        end
    end

    return time + 10
end

function StatusReport(args, time)
    local text = "MISSION STATUS  -  See mission briefing for details\n\n"

    for k,v in pairs(zoneTable) do
        if v > 0 then
            text = text .. tostring(k) .. ": " .. tostring(v) .. " insurgent units remain.\n"
        else
            if zoneFriendly[k] > 0 then
                text = text .. tostring(k) .. ": Friendly units holding objective: " .. zoneFriendly[k] .. ".\n"
            else
                text = text .. tostring(k) .. ": Area cleared!\n"
            end
        end
    end
    
    trigger.action.outText(text, 10)
    return time + 120
end
   
function SpawnSmoke(smokeX, smokeY, smokeColor)
    local pos2 = { x = smokeX, y = smokeY }
    local alt = land.getHeight(pos2)
    local pos3 = {x=pos2.x, y=alt, z=pos2.y}
    if(smokeColor == "Neutral") then
        trigger.action.smoke(pos3, trigger.smokeColor.White)
    elseif(smokeColor == "Blue") then 
        trigger.action.smoke(pos3, trigger.smokeColor.Blue)
    else
        trigger.action.smoke(pos3, trigger.smokeColor.Red)
    end
end

function SmokeTimer(args, time)    
    for i=1,#Objectives do
       local zone = trigger.misc.getZone(Objectives[i].ZoneName)
       SpawnSmoke(zone.point.x, zone.point.z, Objectives[i].Owner)
    end

    return time + 1
end

function SpawnBlueInfantry(tUnit)
    local unit = Unit.getByName(tUnit)
    
    if unit == nil then
        UnitStateTable[unit] = {}
        return
    else
        UnitStateTable[unit] = FillBlueUnitComposition("truck")
    end

    local dropoffZone = UnitInAnyDropoffZone(unit)

    if #UnitStateTable[unit] > 0 then
            
        if dropoffZone ~= nil then
            local unitpos = unit:getPoint()
            local triggerZone = trigger.misc.getZone(dropoffZone.ZoneName)
            local newGroup = dropoffZone.DropFunction(UnitStateTable[unit], "dynBlue", 15, unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
            coalition.addGroup(country.id.USA, Group.Category.GROUND, newGroup)
            
            UnitStateTable[unit] = {}
        end
    end
end

function SpawnRedInfantry(tUnit)
    local unit = Unit.getByName(tUnit)
    
    if unit == nil then
        UnitStateTable[unit] = {}
        return
    else
        UnitStateTable[unit] = FillRedUnitComposition("truck")
    end

    local dropoffZone = UnitInAnyDropoffZone(unit)

    if #UnitStateTable[unit] > 0 then
            
        if dropoffZone ~= nil then
            local unitpos = unit:getPoint()
            local triggerZone = trigger.misc.getZone(dropoffZone.ZoneName)
            --need to find nearest objective to move them to, not nearest trigger
            local newGroup = dropoffZone.DropFunction(UnitStateTable[unit], "dynRed", 15, unitpos.x, unitpos.z, triggerZone.point.x, triggerZone.point.z)
            coalition.addGroup(country.id.INSURGENTS, Group.Category.GROUND, newGroup)
            
            UnitStateTable[unit] = {}
        end
    end
end

-- flag 1 = blue trucks in blue truck drop off zones
mist.flagFunc.units_in_zones{
    units = {'[blue][vehicle]'},
    zones = {'blueSpawn1', 'blueSpawn2'},
    flag = 1
}

-- flag 2 = red trucks in red truck drop off zones
mist.flagFunc.units_in_zones{
    units = {'[red][vehicle]'},
    zones = {'redSpawn1', 'redSpawn2', 'redspawn3'},
    flag = 2
}

discharged_transport = {}

function SpawnController(args, time)
    -- check blue truck spawns
    if(trigger.misc.getUserFlag(1) == 1) then
        -- check spawn1
        local blueSpawn1 = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), {'blueSpawn1'})
        if(#blueSpawn1 > 0) then
            for i=1,#blueSpawn1 do
                local unit = blueSpawn1[i]
                local typename = unit:getTypeName()
                if((typename == 'KAMAZ Truck') and (has_value(discharged_transport, unit:getName()) == false)) then
                    SpawnBlueInfantry(unit:getName())
                    table.insert(discharged_transport, unit:getName())
                end
            end
        end -- end spawn1
        -- check spawn2
        local blueSpawn2 = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), {'blueSpawn2'})
        if(#blueSpawn2 > 0) then
            for i=1,#blueSpawn2 do
                local unit = blueSpawn2[i]
                local typename = unit:getTypeName()
                if((typename == 'KAMAZ Truck') and (has_value(discharged_transport, unit:getName()) == false)) then
                    SpawnBlueInfantry(unit:getName())
                    table.insert(discharged_transport, unit:getName())
                end
            end
        end -- end spawn2
    end

    -- check red truck spawns
    if(trigger.misc.getUserFlag(2) == 1) then
        -- check spawn1
        local redSpawn1 = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), {'redSpawn1'})
        if(#redSpawn1 > 0) then
            for i=1,#redSpawn1 do
                local unit = redSpawn1[i]
                local typename = unit:getTypeName()
                if((typename == 'GAZ-3308') and (has_value(discharged_transport, unit:getName()) == false)) then
                    SpawnRedInfantry(unit:getName())
                    table.insert(discharged_transport, unit:getName())
                end
            end
        end -- end spawn1
        -- check spawn2
        local redSpawn2 = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), {'redSpawn2'})
        if(#redSpawn2 > 0) then
            for i=1,#redSpawn2 do
                local unit = redSpawn2[i]
                local typename = unit:getTypeName()
                if((typename == 'GAZ-3308') and (has_value(discharged_transport, unit:getName()) == false)) then
                    SpawnRedInfantry(unit:getName())
                    table.insert(discharged_transport, unit:getName())
                end
            end
        end -- end spawn2
    end

    return time + 1
end

do
    timer.scheduleFunction(SpawnController, nil, timer.getTime() + 1)
    timer.scheduleFunction(StatusUpdate, nil, timer.getTime() + 10)
    timer.scheduleFunction(SmokeTimer, nil, timer.getTime() + 1)
    timer.scheduleFunction(AddRadioCommands, nil, timer.getTime() + 5)
    timer.scheduleFunction(StatusReport, nil, timer.getTime() + 120)
end


function UnitInAnyPickupZone(unit)
    for i=1,#PickupZones do
        if UnitInZone(unit, PickupZones[i]) then
            return PickupZones[i]
        end
    end
    
    return nil
end

function UnitInAnyDropoffZone(unit)
    for i=1,#DropoffZones do
        if UnitInZone(unit, DropoffZones[i]) then
            return DropoffZones[i]
        end
    end
    
    return nil
end


function UnitInZone(unit, zone)
    if unit:inAir() then
        return false
    end
    
    local triggerZone = trigger.misc.getZone(zone.ZoneName)
    local group = unit:getGroup()
    local groupid = group:getID()
    local unitpos = unit:getPoint()
    local xDiff = unitpos.x - triggerZone.point.x
    local yDiff = unitpos.z - triggerZone.point.z
    local dist = math.sqrt(xDiff * xDiff + yDiff * yDiff)
    
    if dist > triggerZone.radius then
        return false
    end
    
    return true
end


-- FIND TABLE LENGTH-----
function FindTableLength(table)
    size = 0
    for _ in pairs(table) do size = size + 1 end
    return size
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end