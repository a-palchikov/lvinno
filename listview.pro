TEMPLATE = lib
CONFIG += dll
TARGET = listviewhelpers
DEPENDPATH += .

DllExeDirOverride = bin
#_ORIGINAL_DESCRIPTION = $$quote(\"Native ListView helpers for Inno\\0\")

LIBS += user32.lib

DEFINES += UNICODE _UNICODE NDEBUG _WINDLL _VC80_UPGRADE=0x0710
DEFINES += _CRT_SECURE_NO_WARNINGS

SOURCES = listviewhelpers.cpp
