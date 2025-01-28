-- Configuration
local netBootPort = 69
local netBootProgram = "counter"

-- Setup Network
local net = computer.getPCIDevices(classes.NetworkCard)[1]
if not net then
  error("No network card found")
end
net:open(netBootPort)
event.listen(net)

-- Filter NetBoot Messages
local og_event_pull = event.pull
function event.pull(timeout)
  local args = {og_event_pull(timeout)}
  local e, _, s, p, cmd, arg1 = table.unpack(args)
  if e == "NetworkMessage" and p == netBootPort then
    if cmd == "reset" and netBootProgram == arg1 then
      computer.log(2, "Net-Boot: Received reset command from server '"..s.."'")
      if netBootReset then
        pcall(netBootReset)
      end
      computer.reset()
    end
  end
  return table.unpack(args)
end

-- Request code from Net-Boot Server
local program = nil
while program == nil do
  print("Net-Boot: Request Program '"..netBootProgram.."'")
  net:broadcast(netBootPort, "getEEPROM", netBootProgram)
  while program == nil do
    local e, _, s, p, cmd, arg1, arg2 = event.pull(30)
    if e == "NetworkMessage" and p == netBootPort and cmd == "setEEPROM" and arg1 == netBootProgram then
      print("Net-Boot: Got Code for Program '"..netBootProgram.."' from '"..s.."'")
      program = load(arg2)
    elseif e == nil then
      computer.log(3, "Net-Boot: Request Timeout reached!")
      break
    end
  end
end

-- Execute code from Net-Boot server
netBootReset = nil
local success, error = pcall(program)
if not success then
  computer.log(4, error)
  computer.reset()
end
