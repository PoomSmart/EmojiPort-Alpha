export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
TARGET = iphone:clang:14.5:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS5
$(LIBRARY_NAME)_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
$(LIBRARY_NAME)_FILES = ../../EmojiPort-Legacy/EmojiHUD.mm ../EmojiHUDSupport.xm ../LegacyUI.xm ../iOS83UI.xm KBResize5.xm Tweak.xm
$(LIBRARY_NAME)_FRAMEWORKS = UIKit Foundation CoreGraphics
$(LIBRARY_NAME)_EXTRA_FRAMEWORKS = CydiaSubstrate
$(LIBRARY_NAME)_LIBRARIES = EmojiLibrary
$(LIBRARY_NAME)_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
