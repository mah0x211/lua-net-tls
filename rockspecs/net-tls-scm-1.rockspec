package = 'net-tls'
version = 'scm-1'
source = {
    url = 'git+https://github.com/mah0x211/lua-net-tls.git'
}
description = {
    summary = 'net-tls module',
    homepage = 'https://github.com/mah0x211/lua-net-tls',
    license = 'MIT/X11',
    maintainer = 'Masatoshi Fukunaga'
}
dependencies = {
    'lua >= 5.1',
    'io-isfile >= 0.1.0',
    'io-tofile >= 0.1.0',
    'isa >= 0.1.0',
    'metamodule >= 0.2',
    'net >= 0.28.0',
    'libtls >= 3.4.1',
}
build = {
    type = 'builtin',
    modules = {
        ['net.tls'] = 'tls.lua',
        ['net.tls.config'] = 'lib/config.lua',
        ['net.tls.unix'] = 'lib/unix.lua',
        ['net.tls.stream'] = 'lib/stream.lua',
        ['net.tls.stream.inet'] = 'lib/stream/inet.lua',
        ['net.tls.stream.unix'] = 'lib/stream/unix.lua',
    }
}
