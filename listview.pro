TEMPLATE = lib
CONFIG += dll
TARGET = listviewhelpers
DEPENDPATH += .

DllExeDirOverride = $$(VPROOTDIR)/Data Files/setup/Inno/common/bin/
VP_ORIGINAL_DESCRIPTION = $$quote(\"Native ListView helpers for installer\\0\")

########################## >>>Build Path Info #####################################
include($(VPBUILDINFODIR)/BuildPathInfo.pri)
########################## <<<Build Path Info #####################################

INCLUDEPATH += $$(VPROOTDIR)ExtLib/Mssdk/Include

LIBS += user32.lib

DEFINES += UNICODE _UNICODE NDEBUG _WINDLL _VC80_UPGRADE=0x0710
DEFINES += _CRT_SECURE_NO_WARNINGS

SOURCES = listviewhelpers.cpp
