firstSlot = 2 -- The first slot that can hold variable contents 
slotContents = {}

function main ()
  while true do
    local x, y, z = relativePosition()
    if x == 0 and y == 0 and z == 0 then
      -- We're on the home square. This is where we need to start. Now we need to make
      -- sure we're facing the marker block.
      turtle.select(1)
      while not turtle.compare() do
        turtle.turnRight()
      end
      turtle.turnLeft()
      analyzeInventory()
      -- The turtle is now at 0, 1, 0 and facing negative z (relative coordinate system)
      refuel()
      -- The turtle is still at 0, 1, 0 and facing negative z (rel
      digMoveUp()
      dropOff()
      digMoveDown()
      digMoveDown()
      -- The turtle is at 0, 0, 0 and facing negative z (rel
      turtle.turnLeft()
      traverse(8, 8)
      goHome()
    else
      -- We're starting from somewhere other than the home square. The turtle must have
      -- crashed. We need to go home and start over.
      goHome()
    end
  end
end

function goHome ()
  local x, y, z = relativePosition()
  if x == 0 and y == 0 and z == 0 then
    return
  end
  
  -- Get up above the treetops
  while getY() < 9 do
    digMoveUp()
  end
  
  x, y, z = relativePosition()

  local curDir = facing()
  if x > 0 then
    -- We need to move in the negative x direction (relative coordinate system)
    face(curDir, 3)
    curDir = 3
    while getX() ~= 0 do
      turtle.forward()
    end
  else
    -- We need to move in the positive x direction (relative coordinate system)
    face(curDir, 1)
    curDir = 1
    while getX () ~= 0 do
      turtle.forward()
    end
  end

  if z > 0 then
    -- We need to move in the negative z direction (relative coordinate system)
    face(curDir, 2)
    while getZ() ~= 0 do
      turtle.forward()
    end
  else
    -- We need to move in the positive z direction (relative coordinate system)
    face(curDir, 0)
    while getZ() ~= 0 do
      turtle.forward()
    end
  end
  
  while getY() > 0 do
    digMoveDown()
  end
  -- We can't call facing here, because we're in the corner and can't move. So instead,
  -- we'll orient ourselves by looking for the home square marker, which is in slot 1.
  turtle.select(1)
  while not turtle.compare() do
    turtle.turnRight()
  end
end

function face(currentDir, targetDir)
  local diff = targetDir - currentDir
  if diff == 0 then
    return
  elseif diff > 0 then
    for i = 1, diff do
      turtle.turnRight()
    end
  else
    diff = -1 * diff
    for i = 1, diff do
      turtle.turnLeft()
    end
  end
end

-- Uses GPS and a single move forward to determine current facing.
-- 0: positive z
-- 1: negative x
-- 2: negative z
-- 3: positive x
function facing ()
  local x1, y, z1 = relativePosition()
  turtle.forward()
  local x2, y, z2 = relativePosition()
  if z2 > z1 then
    return 0
  elseif z2 < z1 then
    return 2
  elseif x2 > x1 then
    return 1
  else
    return 3
  end
end

function getX ()
  local x, y, z = relativePosition()
  return x
end

function getY ()
  local x, y, z = relativePosition()
  return y
end

function getZ ()
  local x, y, z = relativePosition()
  return z
end

function relativePosition ()
  local x, y, z = gps.locate(5)
  -- These equations reflect the location of the turtle when it's at the home square.
  -- If you move the farm, you must adjust these equations.
  -- 
  -- Notice that our x axis is opposite the global coordinate system.
  x = -241 - x
  y = y - 67
  z = z - 965
  return x, y, z
end

-- Traverse a square area, chopping down any trees found. Assumes we're already facing
-- the correct way to being moving down a row, i.e. our local x direction.
function traverse (x, y)
  local dir = 0
  local rowIndex = 1
  for rowIndex = 1, y do
    for colIndex = 1, x - 1 do
      forwardHarvest()
    end
    if rowIndex < y then
      if dir == 0 then
        turtle.turnLeft()
        forwardHarvest()
        turtle.turnLeft()
      else
        turtle.turnRight()
        forwardHarvest()
        turtle.turnRight()
      end
      dir = 1 - dir
    end
  end
end

-- move forward, if necessary harvest tree
function forwardHarvest()
  if turtle.detect() then
    turtle.dig()
    turtle.forward()
    turtle.digDown()
    while turtle.detectUp() do
      turtle.digUp()
      turtle.up()
    end
    while getY() > 0 do
      digMoveDown()
    end
  else
    turtle.forward()
  end
  turtle.suckDown()
  local x, y, z = relativePosition()
  if not turtle.detectDown() and not (x == 0 and z == 0) then
    local slot = selectSapling()
    if slot > 0 then
      turtle.placeDown()
      if turtle.getItemCount(slot) == 0 then
        slotContents[slot] = "misc"
      end
    end
  end
end

-- This function assumes we are facing the reference sapling.
function analyzeInventory ()
  -- Default all to misc, which could mean rubber or nothing
  for i = firstSlot, 16 do
    slotContents[i] = "misc"
  end
  
  -- Mark all saplings
  for i = firstSlot, 16 do
    turtle.select(i)
    if turtle.compare() then
      slotContents[i] = "sapling"
    end
  end
  
  -- Mark all wood
  digMoveUp()
  for i = firstSlot, 16 do
    turtle.select(i)
    if turtle.compare() then
      slotContents[i] = "wood"
    end
  end
end

-- Finds the first slot that contains at least one sapling
function selectSapling ()
  for i = firstSlot, 16 do
    if slotContents[i] == "sapling" then
      turtle.select(i)
      return i
    end
  end
  return 0
end

function digMoveUp ()
  if turtle.detectUp() then
    turtle.digUp()
  end
  turtle.up()
end

function digMoveDown ()
  if turtle.detectDown() then
    turtle.digDown()
  end
  turtle.down()
end

-- Assumes the inventory has been analyzed.
function refuel ()
  while turtle.getFuelLevel() < 1000 do
    for i = firstSlot, 16 do
      if slotContents[i] == "wood" and turtle.getItemCount(i) > 0 then
        turtle.select(i)
        turtle.refuel(1000 - turtle.getFuelLevel())
        break
      end
    end
  end
end

-- Assumes the inventory has been analyzed. Also assumes we're at the chest.
function dropOff ()
  -- We need to keep one stack of saplings. Everything else can be dropped off. Once we've
  -- passed over one stack, we set this to true, and we know we can drop the rest.
  local keptSaplings = false
  for i = firstSlot, 16 do
    turtle.select(i)
    if slotContents[i] == "sapling" then
      if keptSaplings then
        -- If we've already kept saplings once, we can drop them off.
        turtle.drop(64)
      elseif turtle.getItemCount(i) > 24 then
        -- We haven't set keptSaplings yet, and this stack contains at least 24 saplings.
        -- Therefore, we know we can drop off any future saplings we encounter.
        keptSaplings = true
      end
    else
      turtle.drop(64)
    end
  end
end

main()