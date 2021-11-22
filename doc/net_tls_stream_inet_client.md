# net.tls.stream.inet.Client

defined in [net.tls.stream.inet](../lib/stream/inet.lua) module and inherits from the [net.tls.stream.inet.Socket](net_tls_stream_inet_socket.md) class.


## sock, err, timeout, ai = inet.client.new( host, port, opts )

initiates a new connection and returns an instance of `net.tls.stream.inet.Client`.

**Parameters**

- `host:string`: hostname.
- `port:string|integer`: either a decimal port number or a service name listed in `services(5)`.
- `opts:table`
    - `tlscfg:libtls.config`: [libtls.config](https://github.com/mah0x211/lua-libtls/blob/master/doc/config.md) object. (**required**)
    - `deadline:uint`: specify a timeout milliseconds as unsigned integer.

**Returns**

- `sock:net.tls.stream.inet.Client`: instance of `net.tls.stream.inet.Client`.
- `err:string`: error string.
- `timeout:boolean`: `true` if operation has timed out.
- `ai:llsocket.addrinfo`: instance of [llsocket.addrinfo](https://github.com/mah0x211/lua-llsocket#llsocketaddrinfo-instance-methods).

**e.g.**

```lua
local inet = require('net.tls.stream.inet')
local config = require('net.tls.config')
local cfg = config.new()
cfg:insecure_noverifycert()
cfg:insecure_noverifyname()
local sock, err, timeout, ai = inet.client.new('127.0.0.1','8080', {
    tlscfg = cfg,
})
```
