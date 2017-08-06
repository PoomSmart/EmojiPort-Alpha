PACKAGE_VERSION = 1.0.5
TARGET = iphone:clang:latest:5.0
ARCHS = armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Emoji10Alpha
Emoji10Alpha_FILES = Tweak.xm
Emoji10Alpha_FRAMEWORKS = UIKit
Emoji10Alpha_USE_SUBSTRATE = 1

SUBPROJECTS = Emoji10iOS5

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R Emoji10Alpha $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Emoji10Alpha$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
