slotContents = {}

-- 0: south, 1: west, 2: north, 3: east
-- Our script assumes that the home square is in the northeast corner.
function getFacing ()
  local compass = peripheral.wrap("right")
  return compass.getFacing()
end

-- dir uses same integers as getFacing
function face (dir)
  while dir != getFacing() do
    turtle.turnRight()
  end
end

function relativePosition ()
  local x, y, z = gps.locate(5)
  -- These equations reflect the location of the turtle when it's at the home square.
  -- If you move the farm, you must adjust these equations.
  x = -242 - x
  y = y - 965
  z = z - 67
  return x, y, z
end

function decideWhatToDo ()
  local x, y, z = relativePosition()
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
  for i = 2, 16 do
    slotContents[i] = "rubber"
  end
  -- Mark all wood
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
  for i = 2, 16 do
    turtle.select(i)
    if turtle.compare() then
      slotContents[i] = "wood"
    end
  end
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
  -- Mark all saplings
  for i = 2, 16 do
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

function readPosition ()
  local rowFile = fs.open("row.txt", "r")
  local row = tonumber(rowFile.readAll())
  rowFile.close()
  local colFile = fs.open("col.txt", "r")
  local col = tonumber(colFile.readAll())
  colFile.close()
  return row, col
end

function writePosition (row, col)
  local rowFile = fs.open("row.txt", "w")
  rowFile.write(row)
  rowFile.close()
  local colFile = fs.open("col.txt", "w")
  colFile.write(col)
  colFile.close()
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

-- This function assumes we are facing the home square, and analyzeInventory was just called
function dropOff ()
  turtle.turnLeft()
  
end