#define NO_EXTRA_ICONS
#import "../EmojiLibrary/Header.h"
#import "../Emoji10Legacy/Header.h"
#import "../PSHeader/Misc.h"
#import <substrate.h>

@interface UIKeyboardEmojiScrollView (iOS83UI)
@property(retain, nonatomic) UILabel *_mycategoryLabel;
- (void)updateLabel:(NSString *)categoryKey;
@end

BOOL enabled;

void configureScrollView(UIKeyboardEmojiScrollView *self, CGRect frame) {
    if (enabled && self._mycategoryLabel == nil) {
        NSInteger orientation = MSHookIvar<NSInteger>(UIKeyboardImpl.activeInstance, "m_orientation");
        CGPoint margin = [NSClassFromString(@"UIKeyboardEmojiGraphics") margin:orientation == 1 || orientation == 2];
        self._mycategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin.x, 0, frame.size.width / 2, IS_IPAD ? 44.0 : 21.0)];
        self._mycategoryLabel.alpha = 0.4;
        self._mycategoryLabel.font = [UIFont boldSystemFontOfSize:IS_IPAD ? 17.0 : 11.0];
        self._mycategoryLabel.backgroundColor = UIColor.clearColor;
        [self updateLabel:MSHookIvar < UIKeyboardEmojiCategory *> (self, "_category").name];
        [self addSubview:self._mycategoryLabel];
    }
}

%hook UIKeyboardEmojiScrollView

%property(retain, nonatomic) UILabel *_mycategoryLabel;

%new
- (void)updateLabel: (NSString *)categoryKey {
    UIKeyboardLayoutEmoji *layout = (UIKeyboardLayoutEmoji *)[NSClassFromString(@"UIKeyboardLayoutEmoji") emojiLayout];
    UIKeyboardEmojiCategoryController *controller = (UIKeyboardEmojiCategoryController *)[layout valueForKey:@"_categoryController"];
    self._mycategoryLabel.text = [[[controller categoryForKey:categoryKey] displayName] uppercaseString];
}

- (void)layoutRecents {
    %orig;
    if (enabled)
        MSHookIvar<UILabel *>(self, "_categoryLabel").hidden = YES;
}

- (void)setCategory:(UIKeyboardEmojiCategory *)category {
    %orig;
    if (enabled)
        [self updateLabel:category.name];
}

- (void)doLayout {
    %orig;
    if (enabled)
        [self updateLabel:MSHookIvar < UIKeyboardEmojiCategory *> (self, "_category").name];
}

%end

%hook EmojiPageControl

- (void)setHidden: (BOOL)hidden {
    %orig(enabled ? YES : hidden);
}

%end

%hook UIKeyboardEmojiScrollView

- (id)initWithFrame: (CGRect)frame {
    self = %orig;
    configureScrollView(self, frame);
    return self;
}

%end

%ctor {
    dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLayout.dylib", RTLD_LAZY);
    dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
    id r = [[NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.Emoji10Alpha")] objectForKey:@"enabled"];
    enabled = r ? [r boolValue] : YES;
    %init;
}
