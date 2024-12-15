#import <PSHeader/Misc.h>
#import <EmojiLibrary/Header.h>
#import "../../EmojiLayout/PSEmojiLayout.h"

extern "C" NSString *UIKeyboardGetCurrentInputMode();

static CGFloat getKeyboardHeight(NSInteger orientation) {
    return [SoftPSEmojiLayout keyboardHeight:(orientation == 3 || orientation == 4) ? @"Landscape" : @""];
}

static CGFloat getBarHeight() {
    return [SoftPSEmojiLayout barHeight:[NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape] ? @"Landscape" : @""];
}

BOOL isEmojiInput() {
    return [UIKeyboardGetCurrentInputMode() isEqualToString:@"emoji@sw=Emoji"];
}

%hook UIKeyboardImpl

+ (CGSize)sizeForInterfaceOrientation: (NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = getKeyboardHeight(orientation);
    return size;
}

%end

%hook UIKeyboardLayoutEmoji_iPhone

- (CGSize)leftControlSize {
    CGSize size = %orig;
    size.height = getBarHeight();
    return size;
}

- (CGSize)rightControlSize {
    CGSize size = %orig;
    size.height = getBarHeight();
    return size;
}

%end

%hook UIKeyboardLayoutEmoji_iPad

- (CGSize)rightControlSize {
    CGSize size = %orig;
    size.height = getBarHeight();
    return size;
}

%end
