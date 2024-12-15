export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/
PACKAGE_VERSION = 1.0.11
TARGET = iphone:clang:14.5:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EmojiPortAlpha
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_USE_SUBSTRATE = 1

SUBPROJECTS = EmojiPortiOS5

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
