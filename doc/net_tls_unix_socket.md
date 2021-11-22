# net.tls.unix.Socket

defined in [net.tls.unix](../lib/unix.lua) module and inherits from the [net.unix.Socket](https://github.com/mah0x211/lua-net/blob/master/doc/net_unix_socket.md) and [net.tls.Socket](net_tls_socket.md) class.


## Methods that cannot be used in net.tls.unix.Socket

the following methods always return an error.

- `sock:sendfd()`
- `sock:sendfdsync()`
- `sock:recvfd()`
- `sock:recvfdsync()
`
