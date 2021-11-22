local config = require("net.tls.config")
local client = require('net.tls.stream.inet').client

local function printf(fmt, ...)
    print(fmt:format(...))
end

local host, port = '127.0.0.1', 5000
local cfg = config.new()
cfg:insecure_noverifycert()
cfg:insecure_noverifyname()

printf('create client: %s:%s', host, port)
local c = assert(client.new(host, port, {
    tlscfg = cfg,
}))

local req = 'hello' .. os.time()

printf('send: %q', req)
assert(c:send(req))

local rsp = assert(c:recv())
printf('recv: %q', rsp)
assert(req == rsp, 'invalid response')

c:close()

