#import "../../EmojiLibrary/Header.h"
#import "../../PSHeader/Misc.h"

extern "C" NSString *UIKeyboardGetCurrentInputMode();

static CGFloat getHeight(NSString *name, CGFloat l, CGFloat p, CGFloat padL, CGFloat padP) {
    CGFloat height = 0.0;
    HBLogDebug(@"%@", name);
    BOOL isLandscape = [name rangeOfString:@"Landscape"].location != NSNotFound || [name rangeOfString:@"3587139855"].location != NSNotFound;
    // 3.5, 4-inches iDevices or iPad
    if (IS_IPAD)
        height = isLandscape ? padL : padP;
    else
        height = isLandscape ? l : p;
    return height;
}

static CGFloat getBarHeight(NSString *name) {
    return getHeight(name, 32.0, 40.0, 56.0, 56.0);
}

static CGFloat getKeyboardHeight(NSString *name) {
    return getHeight(name, 162.0, 253.0, 398.0, 313.0);
}

static CGFloat getScrollViewHeight(NSString *name) {
    return getKeyboardHeight(name) - getBarHeight(name);
}

NSArray *extraIcons() {
    return @[@"emoji_recents.png", @"emoji_people.png", @"emoji_nature.png", @"emoji_food-and-drink.png", @"emoji_activity.png", @"emoji_travel-and-places.png", @"emoji_objects.png", @"emoji_objects-and-symbols.png", @"emoji_flags.png"];
}

#define isTargetKey(name) ([name isEqualToString:@"Delete-Key"] || [name isEqualToString:@"International-Key"] || [name isEqualToString:@"Space-Key"] || [name isEqualToString:@"Dismiss-Key"])


NSString *keyboardName() {
    return [UIKeyboardImpl.activeInstance _layout].keyplane.name;
}

BOOL isEmojiInput() {
    return [UIKeyboardGetCurrentInputMode() isEqualToString:@"emoji@sw=Emoji"];
}

CGFloat defaultKeyboardHeight() {
    NSInteger orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
    return (orientation == 3 || orientation == 4) ? 162 : 216;
}

%hook UIKeyboardImpl

+ (CGSize)sizeForInterfaceOrientation: (NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = getKeyboardHeight(keyboardName());
    return size;
}

+ (CGSize)defaultSizeForInterfaceOrientation:(NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = getKeyboardHeight(keyboardName());
    return size;
}

+ (CGSize)keyboardSizeForInterfaceOrientation:(NSInteger)orientation {
    CGSize size = %orig;
    if (isEmojiInput())
        size.height = getKeyboardHeight(keyboardName());
    return size;
}

%end

%hook UIKeyboardLayoutStar

- (void)resizeForKeyplaneSize: (CGSize)size {
    %orig([UIKeyboardImpl keyboardSizeForInterfaceOrientation:[[UIApplication sharedApplication] _frontMostAppOrientation]]);
}

%end

void modifyScroll(UIKBShape *shape, CGFloat height, BOOL padded) {
    shape.frame = CGRectMake(shape.frame.origin.x, shape.frame.origin.y, shape.frame.size.width, height);
    if (padded)
        shape.paddedFrame = CGRectMake(shape.paddedFrame.origin.x, shape.paddedFrame.origin.y, shape.paddedFrame.size.width, height);
}

void modifyBar(UIKBShape *shape, CGFloat scrollViewHeight, CGFloat barHeight, BOOL padded) {
    shape.frame = CGRectMake(shape.frame.origin.x, scrollViewHeight, shape.frame.size.width, barHeight);
    if (padded)
        shape.paddedFrame = CGRectMake(shape.paddedFrame.origin.x, scrollViewHeight, shape.paddedFrame.size.width, barHeight);
}

%hook TIKeyboardFactory

- (UIKBTree *)keyboardWithName: (NSString *)name {
    UIKBTree *keyboard = %orig(name);
    if ([name rangeOfString:@"Emoji"].location != NSNotFound) {
        CGFloat keyboardHeight = getKeyboardHeight(name);
        CGFloat scrollViewHeight = getScrollViewHeight(name);
        CGFloat barHeight = getBarHeight(name);
        UIKBShape *kbShape = (UIKBShape *)([keyboard.properties objectForKey:@"KBshape"]);
        if (kbShape)
            kbShape.frame = CGRectMake(kbShape.frame.origin.x, kbShape.frame.origin.y, kbShape.frame.size.width, keyboardHeight);
        UIKBTree *subtree = [keyboard.subtrees objectAtIndex:0];
        UIKBTree *Emoji_InputView_Keylayout = [subtree.subtrees objectAtIndex:0];
        UIKBTree *Emoji_InputView_Keys_GeometrySet = [Emoji_InputView_Keylayout.subtrees objectAtIndex:1];
        UIKBTree *Emoji_InputView_Geometry_List = [Emoji_InputView_Keys_GeometrySet.subtrees objectAtIndex:0];
        UIKBShape *Emoji_InputView_Geometry_List_shape = [Emoji_InputView_Geometry_List.subtrees objectAtIndex:0];
        modifyScroll(Emoji_InputView_Geometry_List_shape, scrollViewHeight, YES);
        UIKBTree *Emoji_Category_Control_Keylayout = [subtree.subtrees objectAtIndex:1];
        UIKBTree *Emoji_Category_Control_Keys_GeometrySet = [Emoji_Category_Control_Keylayout.subtrees objectAtIndex:1];
        UIKBTree *Emoji_Category_Control_Geometry_List = [Emoji_Category_Control_Keys_GeometrySet.subtrees objectAtIndex:0];
        UIKBShape *Emoji_Category_Control_Geometry_List_shape = [Emoji_Category_Control_Geometry_List.subtrees objectAtIndex:0];
        modifyBar(Emoji_Category_Control_Geometry_List_shape, scrollViewHeight, barHeight, YES);
        UIKBTree *Emoji_Control_Keylayout = [subtree.subtrees objectAtIndex:2];
        UIKBTree *Emoji_Control_Keys_GeometrySet = [Emoji_Control_Keylayout.subtrees objectAtIndex:1];
        UIKBTree *Emoji_Control_Geometry_List = [Emoji_Control_Keys_GeometrySet.subtrees objectAtIndex:0];
        UIKBShape *Emoji_Control_Geometry_List_shape1 = [Emoji_Control_Geometry_List.subtrees objectAtIndex:0];
        UIKBShape *Emoji_Control_Geometry_List_shape2 = [Emoji_Control_Geometry_List.subtrees objectAtIndex:1];
        modifyBar(Emoji_Control_Geometry_List_shape1, scrollViewHeight, barHeight, YES);
        modifyBar(Emoji_Control_Geometry_List_shape2, scrollViewHeight, barHeight, YES);
    }
    return keyboard;
}

%end

%ctor {
    dlopen(realPath2(@"/System/Library/PrivateFrameworks/TextInput.framework/TextInput"), RTLD_LAZY);
    %init;
}
