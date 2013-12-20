slotContents = {}

-- traverse a square area, chopping down any trees found
function traverse (x,y)
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
function analyzeInventory ()
  turtle.turnRight()
  turtle.forward()
  turtle.turnLeft()
  -- Default all to rubber
  for i = 2, 16 do
    slotContents[i] = "rubber"
  end
  -- Mark all wood
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
  turtle.goBack()
  turtle.goBack()
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
  while turtle.getFuelLevel() < 1000
    for i = 2, 16 do
      if slotContents[i] == "wood" and turtle.getItemCount(i) > 0
        turtle.select(i)
        turtle.refuel(1000 - turtle.getFuelLevel())
        break
      end
    end
  end
end

traverse(8, 8)