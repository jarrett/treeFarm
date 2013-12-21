slotContents = {}

function main ()
  while true do
    local x, y, z = relativePosition()
    if x == 0 and y == 0 and z == 0 then
      -- We're on the home square. This is where we need to start.
    else
      -- We're starting from somewhere other than the home square. The turtle must have
      -- crashed. We need to go home and start over.
      goHome()
    end
  end
end

function goHome ()
  -- Get up to height 16
  while getHeight() < 16 do
    if turtle.detectUp() then
      turtle.digUp()
    end
    turtle.up()
  end
  local curDir = facing()
  local x, y, z = relativePosition()
  if x > 0
    -- We need to move in the negative x direction
    face(curDir, 1)
    for i = 1, x do
      turtle.forward()
    end
  else
    -- We need to move in the positive x direction
    face(curDir, 3)
    for i = 1, (x * -1) do
      turtle.forward()
    end
  end
  if z > 0
    -- We need to move in the negative z direction
    face(curDir, 2)
    for i = 1, z do
      turtle.forward()
    end
  else
    -- We need to move in the positive z direction
    face(curDir, 0)
    for i = 1, z * -1 do
      turtle.forward()
    end
  end
  while getHeight() > 0 do
    turtle.down()
  end
  face(2)
end

function face(currentDir, targetDir)
  local diff = targetDir - currentDir
  if diff == 0 then
    return
  else if diff > 0
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
  else if z2 < z1 then
    return 2
  else if x2 > x2
    return 3
  else
    return 1
  end
end

function getHeight ()
  local x, y, z = relativePosition()
  return y
end

function relativePosition ()
  local x, y, z = gps.locate(5)
  -- These equations reflect the location of the turtle when it's at the home square.
  -- If you move the farm, you must adjust these equations.
  x = -242 - x
  y = y - 67
  z = z - 965
  return x, y, z
end

-- Traverse a square area, chopping down any trees found
function traverse (x, y)
  local dir = 0
  turtle.turnRight()
  local rowIndex = 1
  for rowIndex = 1, y - 1 do
    for colIndex = 1, x - 1 do
      forwardHarvest()
    end
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

-- move forward, if necessary harvest tree
function forwardHarvest()
  if turtle.detect() then
    turtle.dig()
    turtle.forward()
    turtle.digDown()
    local height = 0
    while turtle.detectUp() do
      turtle.digUp()
      turtle.up()
      height = height + 1
    end
    for i = 1, height do
      turtle.down()
    end
  else
    turtle.forward()
  end
  turtle.suck()
end

-- This function assumes we are facing the home square, i.e. the quarried stone.
-- We end up in the exact same position and heading.
function analyzeInventory ()
  -- Default all to rubber
  for i = 1, 16 do
    slotContents[i] = "rubber"
  end
  -- Mark all wood
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
  for i = 1, 16 do
    turtle.select(i)
    if turtle.compare() then
      slotContents[i] = "wood"
    end
  end
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
  -- Mark all saplings
  for i = 1, 16 do
    turtle.select(i)
    if turtle.compare() then
      slotContents[i] = "sapling"
    end
  end
  -- Go back to home square
  turtle.turnRight()
  turtle.back()
  turtle.back()
  turtle.turnLeft()
end

-- Finds the first slot that contains at least one sapling
function selectSapling ()
  for i = 2, 16 do
    if slotContents[i] == "sapling" then
      turtle.select(i)
      return true
    end
  end
end

-- Only call this right after analyzeInventory.
function refuel ()
  while turtle.getFuelLevel() < 1000 do
    for i = 2, 16 do
      if slotContents[i] == "wood" and turtle.getItemCount(i) > 0 then
        turtle.select(i)
        turtle.refuel(1000 - turtle.getFuelLevel())
        break
      end
    end
  end
end

goHome()