local role = "server" -- change to "client" for clients
local script = "https://raw.githubusercontent.com/adamgoose/atria-os/master/"..role..".lua"
local install = false

print("Load internet...")
local internet = computer.getPCIDevices(classes.FINInternetCard)[1]
if not internet then
  print("ERROR! No internet card found!")
  computer.beep(0.2)
  return
end

print("Download Installation script...")
code, data = internet:request(script, "GET", ""):await()
if code ~= 200 then
  print("ERROR! Failed to request installation script from '"..script.."'")
  computer.beep(0.2)
  return
end

if install then
  computer.setEEPROM(data)
  computer.reset()
end

print("Run installation...")
func = load(data)
func()
