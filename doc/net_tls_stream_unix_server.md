# net.tls.stream.unix.Server

defined in [net.tls.stream.unix](../lib/stream/unix.lua) module and inherits from the [net.tls.stream.Server](net_tls_stream_server.md) class.


## sock, err, ai = unix.server.new( pathname, tlscfg )

create an instance of `net.tls.stream.unix.Server`.

**Parameters**

- `pathname:string`: pathname of unix domain socket.
- `tlscfg:libtls.config`: [libtls.config](https://github.com/mah0x211/lua-libtls/blob/master/doc/config.md) object.
    
**Returns**

- `sock:net.tls.stream.unix.Server`: instance of `net.tls.stream.unix.Server`.
- `err:string`: error string.
- `ai:llsocket.addrinfo`: instance of [llsocket.addrinfo](https://github.com/mah0x211/lua-llsocket#llsocketaddrinfo-instance-methods).


**e.g.**

```lua
local unix = require('net.tls.stream.unix')
local config = require('net.tls.config')
local cfg = config.new()
cfg:set_keypair_file('./cert.pem', './cert.key')
local sock, err, ai = unix.server.new('/tmp/example.sock')
```
