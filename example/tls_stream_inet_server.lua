local config = require("net.tls.config")
local server = require('net.tls.stream.inet').server

local function printf(fmt, ...)
    print(fmt:format(...))
end

local host, port = '127.0.0.1', 5000
local cfg = config.new()
printf('create cfg from cert.pem and cert.key')
cfg:set_keypair_file('./cert.pem', './cert.key')

printf('create server:', host, port)
local s = assert(server.new(host, port, {
    reuseaddr = true,
    tlscfg = cfg,
}))

printf('listen')
assert(s:listen())

printf('accept')
local c = assert(s:accept())

local msg = assert(c:recv())
printf('recv: %q', msg)

printf('send: %q', msg)
assert(c:send(msg))

c:close()
s:close()
