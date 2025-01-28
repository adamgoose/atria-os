-- Configuration
local netBootPort = 69
local programs = {"counter"}

-- Setup Storage
local fs = filesystem
if fs.initFileSystem("/dev") == false then
  error("Unable to init filesystem")
end
local drive = fs.children("/dev")[1]
if not drive then
  error("No hard drive detected")
end
if fs.mount("/dev/"..drive, "/mnt") == false then
  error("Unable to mount storage")
end
fs.createDir("/mnt/program")

-- Setup Internet
local internet = computer.getPCIDevices(classes.FINInternetCard)[1]
if not internet then
  error("No internet card found!")
  return
end

-- Install Programs
for _, program in pairs(programs) do
  code, data = internet:request("https://raw.githubusercontent.com/adamgoose/atria-os/master/program/"..program..".lua", "GET", ""):await()
  if code ~= 200 then
    error("Unable to download program "..program)
  end

  local file = fs.open("/mnt/program/"..program..".lua", "w")
  file:write(data)
  file:close()

  print("Program '"..program.."' installed")
end

-- Setup Network
local net = computer.getPCIDevices(classes.NetworkCard)[1]
if not net then
  error("No network card found")
end
net:open(netBootPort)
event.listen(net)

-- Reset all programs
for _, program in pairs(programs) do
  net:broadcast(netBootPort, "reset", program)
end

-- Start Net-Boot
while true do
  local e, _, s, p, cmd, arg1 = event.pull()
  if e == "NetworkMessage" and p == netBootPort then
    if cmd == "getEEPROM" then
      print("Program request for '"..arg1.."' from '"..s.."'")
      local file = fs.open("/mnt/program/"..arg1..".lua", "r")
      net:send(s, netBootPort, "setEEPROM", arg1, file:read(99999))
      file:close()
    end
  end
end
