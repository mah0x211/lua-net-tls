local config = require("libtls.config")
local server = require('net.tls.stream.unix').server

local cfg = config.new()
cfg:set_keypair_file('./cert.pem', './cert.key')

local function printf(fmt, ...)
    print(fmt:format(...))
end

local pathname = 'stream-unix.sock'
os.remove(pathname)

printf('create server: %q', pathname)
local s = assert(server.new(pathname, cfg))

print('listen')
assert(s:listen())

print('accept')
local c = assert(s:accept())

local msg = assert(c:recv())
printf('recv: %q', msg)

printf('send: %q', msg)
assert(c:send(msg))

c:close()
s:close()
os.remove(pathname)
