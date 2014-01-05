firstSlot = 3 -- The first slot that can hold variable contents 
slotContents = {}

function main ()
  while true do
    goHome()    
    -- We're on the home square. This is where we need to start. Now we need to make
    -- sure we're facing the marker block.
    turtle.select(1)
    while not turtle.compare() do
      turtle.turnRight()
    end
    turtle.turnLeft()
    analyzeInventory()
    -- The turtle is now at 0, 1, 0 and facing in the direction of the chests.
    digMoveUp()
    dropOff()
    digMoveUp()
    refuel()
    digMoveDown()
    digMoveDown()
    digMoveDown()
    -- The turtle is at 0, 0, 0 and facing the direction of the chests.
    turtle.turnLeft()
    traverse(8, 8)
    goHome()
    os.sleep(20)
  end
end

function goHome ()
  print("Going home")
  
  -- Select the glass block for comparison. Move up until we hit the glass ceiling.
  turtle.select(2)
  while not turtle.compareUp() do
    digMoveUp()
  end
  
  -- Follow the wall around clockwise until we detect the marker block.
  turtle.select(1)
  while not turtle.compare() do
    while not turtle.detect() do
      turtle.forward()
    end
    if not turtle.compare() then
      turtle.turnRight()
    end
  end  
  
  -- Select the stone block for comparison. Move down until we hit the stone floor.
  while not turtle.compareDown() do
    digMoveDown()
  end
  
  while not turtle.compare() do
    turtle.turnRight()
  end
end

-- Traverse a square area, chopping down any trees found. Assumes we're already facing
-- the correct way to being moving down a row, i.e. our local x direction.
function traverse (width, length)
  print("Traversing")
  local dir = 0
  for z = 1, length do
    for x = 1, width - 1 do
      forwardHarvest(x, z)
    end
    if z < length then
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

-- Move forward, if necessary harvest tree. Place a sapling if appropriate. Suck up
-- any items on the ground.
function forwardHarvest (x, z)
  if turtle.detect() then
    turtle.dig()
    turtle.forward()
    turtle.digDown()
    local height = 0
    turtle.select(2)
    while turtle.detectUp() and not turtle.compareUp() do
      turtle.digUp()
      turtle.up()
      height = height + 1
    end
    for i = 1 , height do
      digMoveDown()
    end
  else
    turtle.forward()
  end
  local slot = selectSapling()
  turtle.suckDown()
  if not turtle.detectDown() then
    turtle.placeDown()
    if turtle.getItemCount(slot) == 0 then
      slotContents[slot] = "misc"
    end
  end
end

-- This function assumes we are facing the reference sapling.
function analyzeInventory ()
  print("Analyzing inventory")
  
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

-- Is this square plantable? Pass in relative coords.
function plantable (x, z)
  return x > 0 and x < 7 and z > 0 and z < 7 and x % 2 == z % 2
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

-- Assumes the inventory has been analyzed. Also assumes we're at the chest.
function dropOff ()
  print("Dropping off")
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
        -- Therefore, we know we can drop off some of these and any future stacks.
        turtle.drop(turtle.getItemCount(i) - 24)
        keptSaplings = true
      end
    else
      turtle.drop(64)
    end
  end
end

function refuel()
  print("Refueling")
  for i = firstSlot, 16 do
    if turtle.getItemCount(i) == 0 then
      turtle.select(i)
      break
    end
  end
  turtle.suck()
  turtle.refuel()
end

main()