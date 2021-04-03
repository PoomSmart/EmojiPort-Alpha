TARGET = iphone:clang:latest:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = EmojiPortiOS5
EmojiPortiOS5_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/EmojiPort
EmojiPortiOS5_FILES = ../../EmojiPort-Legacy/EmojiHUD.mm ../EmojiHUDSupport.xm ../LegacyUI.xm ../iOS83UI.xm KBResize5.xm Tweak.xm
EmojiPortiOS5_FRAMEWORKS = UIKit Foundation CoreGraphics
EmojiPortiOS5_EXTRA_FRAMEWORKS = CydiaSubstrate
EmojiPortiOS5_LIBRARIES = EmojiLibrary
EmojiPortiOS5_USE_SUBSTRATE = 1

include $(THEOS_MAKE_PATH)/library.mk
