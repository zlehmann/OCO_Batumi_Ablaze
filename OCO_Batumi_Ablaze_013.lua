
groupCounter = 100
unitCounter = 100

function DropoffGroupDirect(typeList, groupName, coalition, radius, xCenter, yCenter, xDest, yDest)
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
        if(coalition == "Blue") then
            group.units[i] = NewBlueSoldierUnit(xCenter + xofs, yCenter + yofs, angle, unitType)  
        else      
            group.units[i] = NewRedSoldierUnit(xCenter + xofs, yCenter + yofs, angle, unitType)
        end
    end
    
    return group
end

function NewBlueSoldierUnit(x, y, heading, unitType)
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

function NewRedSoldierUnit(x, y, heading, unitType)
    local unit = {
        ["y"] = y,
        ["type"] = unitType,
        ["name"] = "Unitname" .. unitCounter,
        ["unitId"] = unitCounter,
        ["heading"] = heading,
        ["playerCanDrive"] = true,
        ["skill"] = "Average",
        ["x"] = x,
    }
    
    unitCounter = unitCounter + 1
    
    return unit    
end

-- ZONE INITIALIZIATIONS ---------------------------------------------------------------------

Objectives = {
    [1] = {
        Name = "Batumi Airbase",
        ZoneName = "Obj_BatumiAirBase",
        BlueUnits = 0,
        RedUnits = 0,
        Owner = "Blue"
    },
    [2] = {
        Name = "Batumi Power Plant",
        ZoneName = "Obj_BatumiPowerPlant",
        BlueUnits = 0,
        RedUnits = 0,
        Owner = "Uncontrolled"
    },
    [3] = {
        Name = "Batumi Dock",
        ZoneName = "Obj_BatumiDock",
        BlueUnits = 0,
        RedUnits = 0,
        Owner = "Uncontrolled"
    },
    [4] = {
        Name = "Mahindzhauri",
        ZoneName = "Obj_Mahind",
        BlueUnits = 0,
        RedUnits = 0,
        Owner = "Red"
    }
}

PickupZones = {
    [1] = {
        Name = "Batumi Ramp",
        ZoneName = "PickupZone_BatumiRamp"
    }
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
        Name = "Batumi Air Base",
        ZoneName = "DropoffZone_BatumiAirBase",
        DropFunction = DropoffGroupDirect
    }
}

-- misc table INITIALIZIATIONS ---------------------------------------------------------------------
coalitionResources = {
    [1] = {
        team = "Blue",
        supply = 1000
    },
    [2] = {
        team = "Red",
        supply = 1000
    }
}

UnitStateTable = {}
RadioCommandTable = {}
zoneTable = {}
zoneFriendly = {}
discharged_transport = {}


function FillBlueUnitComposition(unitType)
    local retval = {}
    if(unitType == "heli") then
        for i=1,1 do
            retval[i] = "Soldier M249"
        end
        for i=2,12 do
            retval[i] = "Soldier M4"
        end
    elseif(unitType == "truck") then
        for i=1,2 do
            retval[i] = "Soldier M249"
        end
        for i=3,12 do
            retval[i] = "Soldier M4"
        end
    elseif(unitType == "cargo") then
        for i=1,5 do
            retval[i] = "2B11 mortar"
        end
    end
    
    return retval
end

function FillRedUnitComposition(unitType)
    local retval = {}
    if(unitType == "truck") then
        for i=1,2 do
            retval[i] = "Soldier RPG"
        end
        for i=3,20 do
            retval[i] = "Infantry AK Ins"
        end
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
    end
    
    local pickupZone = UnitInAnyPickupZone(unit)
    local dropoffZone = UnitInAnyDropoffZone(unit)
    local nearestObj = FindNearestObjective(unit, 10000, "Blue")
    
    if #UnitStateTable[unitName] > 0 then
        -- if in pickupZone (fob) then drop troops and credit score
        -- if in dropoff zone, then drop the troops in place
        -- if neither
        
        if dropoffZone ~= nil then
            local unitpos = unit:getPoint()
            local destinationZone = trigger.misc.getZone(nearestObj.ZoneName)
            SpawnBlueInfantry(unitName, "heli")
            trigger.action.setUnitInternalCargo(unitName, 0)
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
            trigger.action.setUnitInternalCargo(unitName, 1360) -- assuming roughly 250 lbs per infantry unit
            trigger.action.outText(playerName .. " (" .. groupName .. ") loaded a squad at " .. pickupZone.Name .. ".", 10)
        else
            trigger.action.outText(playerName .. " (" .. groupName .. ") isn't in a pickup or dropoff zone. (" .. #UnitStateTable[unitName] .. " soldiers aboard)", 10)
        end
        


    end
           
end



function AddRadioCommand(unitName)
    trigger.action.outText("Inside AddradioCommand, unitName is: " .. unitName, 10)
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
    trigger.action.outText("Inside AddRadioCommands", 5)
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


-- finds the nearest neutral or enemy objective to set spawn destinations to
function FindNearestObjective(unit, maxDistance, team)
    local minDist = maxDistance
    local minZone = nil
    local unitpos = unit:getPoint()
     -- only look for neutral or enemy objectives
    if team == "Blue" then
        for i=1,#Objectives do
            if Objectives[i].Owner ~= "Blue" then
                local zone = trigger.misc.getZone(Objectives[i].ZoneName)
                local dist = GetDistance(unitpos.x, unitpos.z, zone.point.x, zone.point.z)
                if dist < minDist then
                    minDist = dist
                    minZone = Objectives[i]
                end
            end
        end
    else 
        for i=1,#Objectives do
            if Objectives[i].Owner ~= "Red" then
                local zone = trigger.misc.getZone(Objectives[i].ZoneName)
                local dist = GetDistance(unitpos.x, unitpos.z, zone.point.x, zone.point.z)
                if dist < minDist then
                    minDist = dist
                    minZone = Objectives[i]
                end
            end
        end
    end
    
    return minZone    
end



function StatusUpdate(args, time)
    -- track blue conquest
    local blue_objs = 0

    for i=1,#Objectives do
        local blueUnits = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), {Objectives[i].ZoneName})
        local redUnits = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), {Objectives[i].ZoneName})
        if (#blueUnits > 0 and #redUnits == 0) then
            -- check if it just changed to trigger sound bit
            if (Objectives[i].Owner ~= "Blue") then
                local sound_bit = mist.random(2)
                if (sound_bit == 1) then
                    trigger.action.outSound("Sounds/cap_obj_1.wav")
                else 
                    trigger.action.outSound("Sounds/cap_obj_2.wav")
                end
                trigger.action.outText("We've captured the " .. Objectives[i].Name .. " objective!", 10)
            end
            Objectives[i].Owner = "Blue"
            blue_objs = blue_objs + 1
        elseif (#blueUnits == 0 and #redUnits > 0) then 
            -- check if it just changed to trigger sound bit
            if (Objectives[i].Owner == "Blue") then
                local sound_bit = mist.random(2)
                if (sound_bit == 1) then
                    trigger.action.outSound("Sounds/overrun1.wav")
                else
                    trigger.action.outSound("Sounds/overrun2.wav")
                end
                trigger.action.outText("The enemy has captured the " .. Objectives[i].Name .. " objective!", 10)
            end
            Objectives[i].Owner = "Red"
        else 
            Objectives[i].Owner = "Uncontrolled"
        end
        -- update obj unit counts
        Objectives[i].BlueUnits = #blueUnits
        Objectives[i].RedUnits = #redUnits
    end

    -- check win conditions
    if blue_objs == #Objectives then
        trigger.setUserFlag(99, true)
    end
    if blue_objs == 0 then
        trigger.setUserFlag(100, true)
    end

    return time + 10
end

function StatusReport(args, time)
    -- status report message output:
    local text = "MISSION STATUS  -  See mission briefing for details\n\n"

    for i=1,#Objectives do
        text = text .. Objectives[i].Name .. ": " .. tostring(Objectives[i].BlueUnits) .. " blue | red " .. tostring(Objectives[i].RedUnits) .."\n"
    end
    
    trigger.action.outText(text, 10)
    return time + 120
end
   
function SpawnSmoke(smokeX, smokeY, smokeColor)
    local pos2 = { x = smokeX, y = smokeY }
    local alt = land.getHeight(pos2)
    local pos3 = {x=pos2.x, y=alt, z=pos2.y}
    if(smokeColor == "Uncontrolled") then
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
       if zone.ZoneName ~= "Obj_BatumiAirBase" then
            SpawnSmoke(zone.point.x, zone.point.z, Objectives[i].Owner)
       end
    end

    return time + 300
end

function SpawnBlueMortar(tUnit)
    if(coalitionResources[1].supply > 8) then
        local unit = StaticObject.getByName(tUnit)

        if unit == nil then
            UnitStateTable[unit] = {}
            return
        else
            UnitStateTable[unit] = FillBlueUnitComposition("cargo")
        end

        local dropoffZone = SOInAnyDropoffZone(unit)
        local nearestObj = FindNearestObjective(unit, 10000, "Blue")

        if #UnitStateTable[unit] > 0 then
                
            if dropoffZone ~= nil then
                local unitpos = unit:getPoint()
                local destinationZone = trigger.misc.getZone(nearestObj.ZoneName)
                local newGroup = dropoffZone.DropFunction(UnitStateTable[unit], "dynBlueMortar", "Blue", 15, unitpos.x, unitpos.z, destinationZone.point.x, destinationZone.point.z)
                coalition.addGroup(country.id.USA, Group.Category.GROUND, newGroup)
                --adjust resources table
                coalitionResources[1].supply = coalitionResources[1].supply - 20

                UnitStateTable[unit] = {}
            end
        end
    else 
        trigger.setUserFlag('97', true)
        trigger.action.outText("Blue forces are out of supply!!!", 30)
    end
end

function SpawnBlueInfantry(tUnit, transportType)
    if(coalitionResources[1].supply > 20) then
        local unit = Unit.getByName(tUnit)
        
        if unit == nil then
            UnitStateTable[unit] = {}
            return
        else
            UnitStateTable[unit] = FillBlueUnitComposition(transportType)
        end

        local dropoffZone = UnitInAnyDropoffZone(unit)
        local nearestObj = FindNearestObjective(unit, 10000, "Blue")

        if #UnitStateTable[unit] > 0 then
                
            if dropoffZone ~= nil then
                local unitpos = unit:getPoint()
                --local triggerZone = trigger.misc.getZone(dropoffZone.ZoneName)
                local destinationZone = trigger.misc.getZone(nearestObj.ZoneName)
                local newGroup = dropoffZone.DropFunction(UnitStateTable[unit], "dynBlue", "Blue", 15, unitpos.x, unitpos.z, destinationZone.point.x, destinationZone.point.z)
                coalition.addGroup(country.id.USA, Group.Category.GROUND, newGroup)
                --adjust resources table
                if(transportType == "heli") then
                    coalitionResources[1].supply = coalitionResources[1].supply - 15
                else 
                    coalitionResources[1].supply = coalitionResources[1].supply - 20
                end

                UnitStateTable[unit] = {}
            end
        end
    else 
        trigger.setUserFlag('97', true)
        trigger.action.outText("Blue forces are out of supply!!!", 30)
    end
end

function SpawnRedInfantry(tUnit)
    if(coalitionResources[2].supply > 10) then
        local unit = Unit.getByName(tUnit)
        
        if unit == nil then
            UnitStateTable[unit] = {}
            return
        else
            UnitStateTable[unit] = FillRedUnitComposition("truck")
        end

        local dropoffZone = UnitInAnyDropoffZone(unit)
        local nearestObj = FindNearestObjective(unit, 10000, "Red")

        if #UnitStateTable[unit] > 0 then
                
            if dropoffZone ~= nil then
                local unitpos = unit:getPoint()
                local destinationZone = trigger.misc.getZone(nearestObj.ZoneName)
                local newGroup = dropoffZone.DropFunction(UnitStateTable[unit], "dynRed", "Red", 15, unitpos.x, unitpos.z, destinationZone.point.x, destinationZone.point.z)
                coalition.addGroup(country.id.INSURGENTS, Group.Category.GROUND, newGroup)
                --adjust resources table
                coalitionResources[2].supply = coalitionResources[2].supply - 20

                UnitStateTable[unit] = {}
            end
        end
    else 
        trigger.setUserFlag('98', true)
        trigger.action.outText("Red forces are out of supply!!!", 30)
    end
end


blue_truck_dropzones = {'DropoffZone_BD1', 'DropoffZone_BD2', 'DropoffZone_BD3', 'DropoffZone_BD4', 'DropoffZone_BPP1', 'DropoffZone_BPP2', 'DropoffZone_BPP3', 'DropoffZone_BPP4'}
red_truck_dropzones = {'DropoffZone_BD1', 'DropoffZone_BD2', 'DropoffZone_BD3', 'DropoffZone_BD4', 'DropoffZone_BPP1', 'DropoffZone_BPP2', 'DropoffZone_BPP3', 'DropoffZone_BPP4', 'redSpawn3'}
red_boat_dropzones = {'Naval_Landing1', 'Naval_Landing2', 'Naval_Landing3'}

-- FLAG Initialization-----------------------------------------------------------------
-- flag 1 = blue trucks in blue truck drop off zones
mist.flagFunc.units_in_zones{
    units = {'[blue][vehicle]'},
    zones = blue_truck_dropzones,
    flag = 1
}

-- flag 2 = red trucks in red truck drop off zones
mist.flagFunc.units_in_zones{
    units = {'[red][vehicle]'},
    zones = red_truck_dropzones,
    flag = 2
}

-- flag 3 = red boats in red boat drop off zones
mist.flagFunc.units_in_zones{
    units = {'[red][ship]'},
    zones = red_boat_dropzones,
    flag = 3
}

-- flag 97 = blue out of supply
trigger.action.setUserFlag('97', false)

-- flag 98 = red out of supply
trigger.action.setUserFlag('98', false)

-- flag 99 = blue victory conditions met
trigger.action.setUserFlag('99', false)

-- flag 100 = red victory conditions met
trigger.action.setUserFlag('100', false)


-- Checks if trucks are in drop zones to spawn infantry
function SpawnController(args, time)
    -- check blue truck spawns
    local blueSpawn1 = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), blue_truck_dropzones)
    if(#blueSpawn1 > 0) then
        for i=1,#blueSpawn1 do
            local unit = blueSpawn1[i]
            local typename = unit:getTypeName()
            if((typename == 'KAMAZ Truck') and (has_value(discharged_transport, unit:getName()) == false)) then
                SpawnBlueInfantry(unit:getName(), "truck")
                table.insert(discharged_transport, unit:getName())
            end
        end
    end

    -- check red truck spawns
    local redSpawn1 = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), red_truck_dropzones)
    if(#redSpawn1 > 0) then
        for i=1,#redSpawn1 do
            local unit = redSpawn1[i]
            local typename = unit:getTypeName()
            local group = unit:getGroup()
            if((typename == 'GAZ-3308') and (has_value(discharged_transport, unit:getName()) == false)) then
                trigger.action.groupStopMoving(group)
                SpawnRedInfantry(unit:getName())
                table.insert(discharged_transport, unit:getName())
                trigger.action.groupContinueMoving(group)
            end
        end
    end

    -- check red boats spawns
    local redSpawn2 = mist.getUnitsInZones(mist.makeUnitTable({'[red][ship]'}), red_boat_dropzones)
    if(#redSpawn2 > 0) then
        for i=1,#redSpawn2 do
            local unit = redSpawn2[i]
            local typename = unit:getTypeName()
            local group = unit:getGroup()
            if((typename == 'speedboat') and (has_value(discharged_transport, unit:getName()) == false)) then
                trigger.action.groupStopMoving(group)
                SpawnRedInfantry(unit:getName())
                table.insert(discharged_transport, unit:getName())
                trigger.action.groupContinueMoving(group)
            end
        end
    end

    return time + 1
end


function SpawnNewTrucks(args, time)
    -- control truck cloning
    destZones = {'DropoffZone_BD1', 'DropoffZone_BD2', 'DropoffZone_BD3', 'DropoffZone_BD4', 'DropoffZone_BPP1', 'DropoffZone_BPP2', 'DropoffZone_BPP3', 'DropoffZone_BPP4'}
    navalZones = {'Naval_Landing1', 'Naval_Landing2'}
    if(trigger.misc.getUserFlag(97) ~= 1) then
        local bc_no = mist.random(2)
        local blue_clone = nil
        if bc_no == 1 then
            blue_clone = mist.cloneGroup("Blue_Truck_1")
        else
            blue_clone = mist.cloneGroup("Blue_Truck_2")
        end
        coalitionResources[1].supply = coalitionResources[1].supply - 50

        mist.scheduleFunction(mist.groupToRandomZone, {blue_clone["name"], destZones, 'cone', nil, 40, false}, timer.getTime() + 10)
    end

    if(trigger.misc.getUserFlag(98) ~= 1) then
        local red_clone = nil

        -- scale truck respawn based on number of players
        local difficulty_modifier = 1
        local no_players = net.get_player_list()
        if #no_players > 1 then
            difficulty_modifier = #no_players 
        end

        for i=1,difficulty_modifier do
            local rc_no = mist.random(4)
            if(rc_no == 1) then
                red_clone = mist.cloneGroup("RedTransport_1-1")
                LC_AA = mist.cloneGroup("LC_AA_1")
            elseif(rc_no == 2) then
                red_clone = mist.cloneGroup("RedTransport_1-2")
                LC_AA = mist.cloneGroup("LC_AA_2")
            elseif(rc_no == 3) then
                red_clone = mist.cloneGroup("RedTransport_1-3")
                LC_AA = mist.cloneGroup("LC_AA_3")
            else
                red_clone = mist.cloneGroup("RedTransport_1-4")
                LC_AA = mist.cloneGroup("LC_AA_4")
            end
            naval = mist.cloneGroup("Naval-1")
            coalitionResources[2].supply = coalitionResources[2].supply - 120    
            
            mist.scheduleFunction(mist.groupToRandomZone, {red_clone["name"], destZones, 'cone', nil, 40, false}, timer.getTime() + 10)
            mist.scheduleFunction(mist.groupToRandomZone, {LC_AA["name"], destZones, 'cone', nil, 40, false}, timer.getTime() + 10)
            mist.scheduleFunction(mist.groupToRandomZone, {naval["name"], navalZones, 'cone', nil, 40, false}, timer.getTime() + 10)
        end
    end

    --randomize respawn time
    local xtime = mist.random(300, 600)
    return time + xtime
end

function MortarAttack(args, time)
    local no_mortars = mist.random(8)
    local attack_zone = nil
    if(Objectives[3].Owner == "Blue" or Objectives[3].Owner == "Uncontrolled") then
        attack_zone = 3
    elseif(Objectives[2].Owner == "Blue" or Objectives[2].Owner == "Uncontrolled") then
        attack_zone = 2
    else
        attack_zone = 1
    end

    local round_delay = 0
    for i=1,no_mortars do
        local p2 = mist.getRandomPointInZone(Objectives[attack_zone].ZoneName)
        local p3 = mist.utils.makeVec3(p2)
        mist.scheduleFunction(trigger.action.explosion, {p3, 5}, timer.getTime() + (round_delay + mist.random(4)))
    end

    return time + (300 + mist.random(60))
end

function log(args, time)
    local cargo = StaticObject.getByName("Heavy Weapons-1-1")
    trigger.action.outText("Cargo is in the air: " .. tostring(mist.vec.mag(cargo:getVelocity())) .. ".", 5)
    return time + 1
end

function CheckBlueTruckHp(args, time)
    -- check blue trucks
    local blueTrucks = mist.getUnitsInZones(mist.makeUnitTable({'[blue][vehicle]'}), DropoffZones)
    for i=1,#blueTrucks do
        trigger.action.outText(tostring(unit), 1)
        if(blueTrucks[i].getLive() < 100) then
            local typename = unit:getTypeName()
            if((typename == 'KAMAZ Truck') and (has_value(discharged_transport, unit:getName()) == false)) then
                SpawnBlueInfantry(unit:getName(), "truck")
                table.insert(discharged_transport, unit:getName())
            end
        end
    end

    return time + 1
end

function CheckRedTruckHp(args, time)
    -- check red trucks
    local redTrucks = mist.getUnitsInZones(mist.makeUnitTable({'[red][vehicle]'}), DropoffZones)
    for i=1,#redTrucks do
        trigger.action.outText(tostring(unit), 1)
        if(redTrucks[i].getLive() < 100) then
            local typename = unit:getTypeName()
            if((typename == 'GAZ-3308') and (has_value(discharged_transport, unit:getName()) == false)) then
                SpawnRedInfantry(unit:getName(), "truck")
                table.insert(discharged_transport, unit:getName())
            end
        end
    end

    return time + 1
end

do
    --timer.scheduleFunction(log, nil, timer.getTime() + 1)
    timer.scheduleFunction(CheckBlueTruckHp, nil, timer.getTime() + 1)
    timer.scheduleFunction(AddRadioCommands, nil, timer.getTime() + 5)
    timer.schedulefunction(CheckRedTruckHp, nil, timer.getTime() + 1)
    timer.scheduleFunction(MortarAttack, nil, timer.getTime() + 300)
    timer.scheduleFunction(SpawnController, nil, timer.getTime() + 1)
    timer.scheduleFunction(SpawnNewTrucks, nil, timer.getTime() + 600)
    timer.scheduleFunction(StatusUpdate, nil, timer.getTime() + 10)
    timer.scheduleFunction(SmokeTimer, nil, timer.getTime() + 120)    
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