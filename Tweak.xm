#define CHECK_TARGET
#define CHECK_TARGET_LEGACY
#import <dlfcn.h>
#import <PSHeader/PS.h>

%ctor {
    if (isTarget(TargetTypeApps)) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLayout.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiLocalization.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiAttributes.dylib", RTLD_NOW);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiPort/EmojiPortiOS5.dylib", RTLD_NOW);
    }
}
