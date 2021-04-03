PACKAGE_VERSION = 1.0.9
TARGET = iphone:clang:latest:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = EmojiPortAlpha
EmojiPortAlpha_FILES = Tweak.xm
EmojiPortAlpha_FRAMEWORKS = UIKit
EmojiPortAlpha_USE_SUBSTRATE = 1

SUBPROJECTS = EmojiPortiOS5

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R EmojiPortAlpha $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/EmojiPortAlpha$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
