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
--- assign to loc
local clock = os.clock
local find = string.find
local format = string.format
local tostring = tostring
local type = type
local pairs = pairs
local poll = require('net.poll')
local waitrecv = poll.waitrecv
local waitsend = poll.waitsend
local unwait = poll.unwait
local libtls = require('libtls')
local is_unsigned = require('isa').unsigned
--- constants
local WANT_POLLIN = libtls.WANT_POLLIN
local WANT_POLLOUT = libtls.WANT_POLLOUT
local DEFAULT_CLOCK_LIMIT = 0.01

--- @class net.tls.Socket : net.Socket
local Socket = {}

--- init
--- @param sock llsocket.socket
--- @param nonblock boolean
--- @param tls libtls.tls
--- @return net.tls.Socket? self
--- @return string? err
function Socket:init(sock, nonblock, tls)
    self.sock = sock
    self.nonblock = nonblock
    self.tls = tls
    self.clocklimit = DEFAULT_CLOCK_LIMIT
    return self
end

--- closer
--- @return boolean ok
--- @return string? err
function Socket:closer()
    -- the tls socket cannot be partially shut down
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

--- closew
--- @return boolean ok
--- @return string? err
function Socket:closew()
    -- the tls socket cannot be partially shut down
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

--- close
--- @return boolean ok
--- @return string? err
--- @return boolean? timeout
function Socket:close()
    if self.nonblock then
        unwait(self:fd())
    end

    local ok, err, timeout = self:tls_close()

    if not ok then
        self.sock:close()
        return ok, err, timeout
    end

    return self.sock:close()
end

--- poll_wait
--- @param want integer
--- @return boolean ok
--- @return string? err
--- @return boolean? timeout
function Socket:poll_wait(want)
    local ok, err, timeout

    -- wait by poll function
    if want == WANT_POLLIN then
        ok, err, timeout = waitrecv(self:fd(), self.rcvdeadl)
    elseif want == WANT_POLLOUT then
        ok, err, timeout = waitsend(self:fd(), self.snddeadl)
    else
        return false, format('unsupported want type %q', tostring(want))
    end

    return ok, err, timeout
end

--- setclocklimit
--- @return number sec
--- @return string? err
function Socket:setclocklimit(sec)
    assert(sec == nil or is_unsigned(sec), 'sec must be unsigned number')
    self.clocklimit = sec or DEFAULT_CLOCK_LIMIT
end

--- handshake
--- @return boolean ok
--- @return string? err
--- @return boolean? timeout
function Socket:handshake()
    if self.handshaked then
        return true
    end

    local tls, handshake = self.tls, self.tls.handshake
    local clocklimit = self.clocklimit
    local cost = clock()

    while true do
        local ok, err, want = handshake(tls)

        if not want then
            self.handshaked = ok
            return ok, err
        elseif self.nonblock then
            local timeout
            ok, err, timeout = self:poll_wait(want)
            if not ok then
                return false, err, timeout
            end
        elseif clock() - cost >= clocklimit then
            return false, nil, true
        end
        -- do handshake again
    end
end

--- tls_close
--- @return boolean ok
--- @return string? err
--- @return boolean? timeout
function Socket:tls_close()
    local tls, close = self.tls, self.tls.close
    local clocklimit = self.clocklimit
    local cost = clock()

    while true do
        local ok, err, want = close(tls)

        if not want then
            return ok, err
        elseif self.nonblock then
            local timeout

            ok, err, timeout = self:poll_wait(want)
            if not ok then
                return false, err, timeout
            end
        elseif clock() - cost >= clocklimit then
            return false, nil, true
        end
        -- do close again
    end
end

--- recv
--- @param bufsize integer
--- @return string? msg
--- @return string? err
--- @return boolean? timeout
function Socket:recv(bufsize)
    if not self.handshaked then
        local ok, err, timeout = self:handshake()
        if not ok then
            return nil, err, timeout
        end
    end

    local sock, read = self.tls, self.tls.read
    local clocklimit = self.clocklimit
    local cost = os.clock()

    while true do
        local str, err, _, want = read(sock, bufsize)

        if not want then
            return str, err
        elseif self.nonblock then
            local ok, perr, timeout = self:poll_wait(want)
            if not ok then
                return nil, perr, timeout
            end
        elseif clock() - cost >= clocklimit then
            return nil, nil, true
        end
        -- do read again
    end
end

--- recvmsg
--- @return integer? len
--- @return string err
function Socket:recvmsg()
    -- currently, does not support recvmsg on tls connection
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

--- readv
--- @return integer? len
--- @return string err
function Socket:readv()
    -- currently, does not support readv on tls connection
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

--- send
--- @param str string
--- @return integer? len
--- @return string? err
--- @return boolean? timeout
function Socket:send(str)
    if not self.handshaked then
        local ok, err, timeout = self:handshake()
        if not ok then
            return 0, err, timeout
        end
    end

    local sock, write = self.tls, self.tls.write
    local clocklimit = self.clocklimit
    local sent = 0
    local cost = os.clock()

    while true do
        local len, err, _, want = write(sock, str)

        if not want then
            return len, err
        elseif not len then
            return nil, err
        end

        -- update a bytes sent
        sent = sent + len
        if self.nonblock then
            local ok, perr, timeout = self:poll_wait(want)
            if not ok then
                return sent, perr, timeout
            end
        elseif clock() - cost >= clocklimit then
            return sent, nil, true
        end

        str = str:sub(len + 1)
        -- do write again
    end
end

--- sendmsg
--- @return integer? len
--- @return string? err
function Socket:sendmsg()
    -- currently, does not support sendmsg on tls connection
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

--- writev
--- @return integer? len
--- @return string? err
function Socket:writev()
    -- currently, does not support sendmsg on tls connection
    -- EOPNOTSUPP: Operation not supported on socket
    return nil, 'Operation not supported on socket'
end

require('metamodule').new.Socket(Socket, 'net.Socket')

-- exports libtls constants
local _M = {}
for k, v in pairs(libtls) do
    if find(k, '^%u+') and type(v) == 'number' then
        _M[k] = v
    end
end

return _M
