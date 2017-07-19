#import "../../EmojiLibrary/Header.h"
#import "../../PSHeader/Misc.h"

extern "C" NSString *UIKeyboardGetCurrentInputMode();

static CGFloat getHeight(NSInteger orientation, CGFloat l, CGFloat p, CGFloat padL, CGFloat padP) {
    BOOL isLandscape = orientation == 3 || orientation == 4;
    if (IS_IPAD)
        return isLandscape ? padL : padP;
    return isLandscape ? l : p;
}

static CGFloat getBarHeight(NSInteger orientation) {
    return getHeight(orientation, 32.0, 40.0, 56.0, 56.0);
}

static CGFloat getKeyboardHeight(NSInteger orientation) {
    return getHeight(orientation, 162.0, 253.0, 398.0, 313.0);
}

/*static CGFloat getScrollViewHeight(NSInteger orientation) {
    return getKeyboardHeight(orientation) - getBarHeight(orientation);
   }*/

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
    size.height = getBarHeight([NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape] ? 3 : 1);
    return size;
}

- (CGSize)rightControlSize {
    CGSize size = %orig;
    size.height = getBarHeight([NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape] ? 3 : 1);
    return size;
}

%end

%hook UIKeyboardLayoutEmoji_iPad

- (CGSize)rightControlSize {
    CGSize size = %orig;
    size.height = getBarHeight([NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape] ? 3 : 1);
    return size;
}

%end

%ctor {
    %init;
}
