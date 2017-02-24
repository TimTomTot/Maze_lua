@echo off

set TESTS=items\itemsfactory_test.lua items\bottle_test.lua

cls

for  %%i in (%TESTS%) do (
    echo _
    lua testy.lua .\unittests\%%i
)
