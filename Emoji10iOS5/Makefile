TARGET = iphone:clang:latest:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = Emoji10iOS5
Emoji10iOS5_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/Emoji10Alpha
Emoji10iOS5_FILES = ../EmojiHUD.mm ../EmojiHUDSupport.xm ../LegacyUI.xm ../iOS83UI.xm KBResize5.xm Tweak.xm
Emoji10iOS5_FRAMEWORKS = UIKit Foundation CoreGraphics
Emoji10iOS5_EXTRA_FRAMEWORKS = CydiaSubstrate
Emoji10iOS5_LIBRARIES = EmojiLibrary
Emoji10iOS5_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
