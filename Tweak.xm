#define CHECK_TARGET
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLayout.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiAttributes/EmojiAttributes.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPortAlpha/EmojiPortiOS5.dylib", RTLD_NOW);
    }
}
