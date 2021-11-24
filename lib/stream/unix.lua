--
-- Copyright (C) 2021 Masatoshi Fukunaga
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- assign to local
local error = error
local libtls = require('libtls')
local tls_client = libtls.client
local tls_server = libtls.server
local unix = require('net.stream.unix')
local unix_new_server = unix.server.new
local unix_new_client = unix.client.new

--- @class net.tls.stream.unix.Socket : net.tls.stream.Socket, net.tls.unix.Socket
local Socket = require('metamodule').new.Socket({}, 'net.tls.stream.Socket',
                                                'net.tls.unix.Socket')

--- @class net.tls.stream.unix.Client : net.tls.stream.unix.Socket
local Client = require('metamodule').new
                   .Client({}, 'net.tls.stream.unix.Socket')

--- @class net.tls.stream.unix.Server : net.tls.stream.Server
local Server = {}

--- new_connection
--- @param sock llsocket.socket
--- @param nonblock boolean
--- @return net.tls.stream.Socket sock
--- @return string? err
function Server:new_connection(sock, nonblock)
    local tls, err = self.tls:accept_socket(sock:fd())

    if err then
        sock:close()
        return nil, err
    end

    return Socket(sock, nonblock, tls)
end

Server = require('metamodule').new.Server(Server, 'net.tls.stream.Server')

--- new_client
--- @param pathname string
--- @param opts? table<string, any>
--- @return net.tls.stream.inet.Client? sock
--- @return string? err
--- @return boolean? timeout
--- @return llsocket.addrinfo? ai
local function new_client(pathname, opts)
    if opts == nil then
        opts = {}
    end
    if opts.tlscfg == nil then
        error('opts.tlscfg must not be nil', 2)
    end

    -- create tls client context
    local tls, err = tls_client(opts.tlscfg)
    if err then
        return nil, err
    end

    local c, nerr, timeout, ai = unix_new_client(pathname, opts)
    if not c then
        return nil, nerr, timeout
    end

    local ok, cerr = tls:connect_socket(c:fd(), opts.servername)
    if not ok then
        c:close()
        return nil, cerr
    end

    return Client(c.sock, c.nonblock, tls), nil, nil, ai
end

--- new_server
--- @param pathname string
--- @param tlscfg libtls.config
--- @return net.tls.stream.unix.Server? server
--- @return string? err
--- @return llsocket.addrinfo? ai
local function new_server(pathname, tlscfg)
    if tlscfg == nil then
        error('tlscfg must not be nil', 2)
    end

    -- create tls server context
    local tls, err = tls_server(tlscfg)
    if err then
        return nil, err
    end

    local s, nerr, ai = unix_new_server(pathname)
    if nerr then
        return nil, nerr
    end

    return Server(s.sock, s.nonblock, tls), nil, ai
end

return {
    client = {
        new = new_client,
    },
    server = {
        new = new_server,
    },
}

