#!/bin/sh

# Lua has no knowledge of any OS-level stuff like relative paths,
# so to get the tests in a harness from a different directory I had
# to do some weird hacking
export LUA_PATH='?;?.lua;test/?.lua;test/?;love/?.lua;love/?'
lua test/test_data.lua
