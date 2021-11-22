# net.tls.stream.unix.Client

defined in [net.tls.stream.unix](../lib/stream/unix.lua) module and inherits from the [net.tls.stream.unix.Socket](net_tls_stream_unix_socket.md) class.


## sock, err, timeoutm ai = unix.client.new( pathname, opts )

initiates a new connection and returns an instance of `net.tls.stream.unix.Client`.

**Parameters**

- `pathname:string`: pathname of unix domain socket.
- `opts:table`
    - `tlscfg:libtls.config`: [libtls.config](https://github.com/mah0x211/lua-libtls/blob/master/doc/config.md) object. (**required**)
    - `deadline:uint`: specify a timeout milliseconds as unsigned integer.

**Returns**

- `sock:net.tls.stream.unix.Client`: instance of `net.tls.stream.unix.Client`.
- `err:string`: error string.
- `timeout:boolean`: `true` if operation has timed out.
- `ai:llsocket.addrinfo`: instance of [llsocket.addrinfo](https://github.com/mah0x211/lua-llsocket#llsocketaddrinfo-instance-methods).

**e.g.**

```lua
local unix = require('net.stream.unix')
local sock, err, timeout, ai = unix.client.new('/tmp/example.sock', 100)
```
**e.g.**

```lua
local unix = require('net.tls.stream.unix')
local config = require('net.tls.config')
local cfg = config.new()
cfg:insecure_noverifycert()
cfg:insecure_noverifyname()
local sock, err, timeout, ai = unix.client.new('/tmp/example.sock', {
    tlscfg = cfg,
})
```
