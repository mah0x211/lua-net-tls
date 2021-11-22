# net.tls.stream.inet.Server

defined in [net.tls.stream.inet.Server](../lib/stream/inet.lua) module and inherits from the [net.tls.stream.Server](net_tls_stream_server.md) class.


## sock, err, ai = inet.server.new( host, port, opts )

create an instance of `net.stream.inet.Server`.

**Parameters**

- `host:string`: hostname.
- `port:string|integer`: either a decimal port number or a service name listed in `services(5)`.
- `opts:table`
    - `tlscfg:libtls.config`: [libtls.config](https://github.com/mah0x211/lua-libtls/blob/master/doc/config.md) object. (**required**)
    - `reuseaddr:boolean`: enable the `SO_REUSEADDR` flag.
    - `reuseport:boolean`: enable the `SO_REUSEPORT` flag.

**Returns**

- `sock:net.tls.stream.inet.Server`: instance of `net.tls.stream.inet.Server`.
- `err:string`: error string.
- `ai:llsocket.addrinfo`: instance of [llsocket.addrinfo](https://github.com/mah0x211/lua-llsocket#llsocketaddrinfo-instance-methods).

**e.g.**

```lua
local inet = require('net.tls.stream.inet')
local config = require('net.tls.config')
local cfg = config.new()
cfg:set_keypair_file('./cert.pem', './cert.key')
local sock, err = inet.server.new('127.0.0.1', 8080. {
    tlscfg = cfg,
})
```

