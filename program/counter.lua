function netBootReset()
  print("Net-Boot Restart Cleanup!")
end

-- Identify Display
local display
for _, id in ipairs(component.findComponent(classes.ModulePanel)) do
  local panel = component.proxy(id)
  for _, module in pairs(panel:getModules()) do
    if display == nil and module:getType().name == "MicroDisplayModule" then
      print("Counter Display Identified")
      display = module
      display.setText("Hi!")
    end

    if module:getType().name == "MushroomPushbuttonModuleBig" then
      print("Reset Button Identified")
      module:setColor(0, 255, 0, 0)
      event.listen(module)
    end
  end
end

::continue::
local counter = 0
while true do
  local e, s = event.pull(1)
  if e == "Trigger" then
    print("Reset Button Pushed")
    s:setColor(255, 0, 0, 0)
    if display then
      display:setText("Bye")
    end
    computer.beep(0.2)
    event.pull(1)
    computer.reset()
  end
  counter = counter + 1
  print("Counter:", counter)
  if display then
    display.setText(counter)
  end
  if counter > 10 then
    error("meep")
  end
end
