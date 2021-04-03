#define CHECK_TARGET
#import <dlfcn.h>
#import "../PS.h"

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLayout.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLocalization.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS5.dylib", RTLD_NOW);
    }
}
