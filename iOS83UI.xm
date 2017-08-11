#import "../EmojiLibrary/Header.h"
#import <substrate.h>

@interface UIKeyboardEmojiScrollView (iOS83UI)
- (void)updateLabel:(NSString *)categoryKey;
@end

#define LABEL_HEIGHT (IS_IPAD ? 44.0 : 21.0)
#define FONT_SIZE (IS_IPAD ? 17.0 : 11.0)

void setLabelFrame(UILabel *categoryLabel, CGRect frame) {
    CGPoint margin = [NSClassFromString(@"UIKeyboardEmojiGraphics") margin:![NSClassFromString(@"UIKeyboardLayoutEmoji") isLandscape]];
    categoryLabel.frame = CGRectMake(margin.x, 0.0, frame.size.width / 2, LABEL_HEIGHT);
}

void configureScrollView(UIKeyboardEmojiScrollView *self, CGRect frame) {
    MSHookIvar<UILabel *>(self, "_categoryLabel").alpha = 0.4;
    MSHookIvar<UILabel *>(self, "_categoryLabel").font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    MSHookIvar<UILabel *>(self, "_categoryLabel").backgroundColor = UIColor.clearColor;
    MSHookIvar<UILabel *>(self, "_categoryLabel").textAlignment = NSTextAlignmentLeft;
    [self updateLabel:MSHookIvar < UIKeyboardEmojiCategory *> (self, "_category").name];
    setLabelFrame(MSHookIvar<UILabel *>(self, "_categoryLabel"), frame);
}

%hook PSEmojiLayout

+ (CGFloat)dotHeight {
    return LABEL_HEIGHT;
}

%end

%hook UIKeyboardEmojiCategory

- (NSString *)displayName {
    return stringEqual(self.name, @"UIKeyboardEmojiCategoryRecents") ? [NSClassFromString(@"UIKeyboardLayoutEmoji") localizedStringForKey:@"RECENTS_TITLE"] : %orig;
}

%end

%hook UIKeyboardEmojiScrollView

%new
- (void)updateLabel: (NSString *)categoryKey {
    UIKeyboardLayoutEmoji *layout = (UIKeyboardLayoutEmoji *)[NSClassFromString(@"UIKeyboardLayoutEmoji") emojiLayout];
    UIKeyboardEmojiCategoryController *controller = (UIKeyboardEmojiCategoryController *)[layout valueForKey:@"_categoryController"];
    MSHookIvar<UILabel *>(self, "_categoryLabel").text = [[[controller categoryForKey:categoryKey] displayName] uppercaseString];
}

- (void)layoutPages {
    %orig;
    MSHookIvar<UILabel *>(self, "_categoryLabel").hidden = NO;
    setLabelFrame(MSHookIvar<UILabel *>(self, "_categoryLabel"), self.frame);
}

- (void)setCategory:(UIKeyboardEmojiCategory *)category {
    %orig;
    [self updateLabel:category.name];
}

- (void)doLayout {
    %orig;
    [self updateLabel:MSHookIvar < UIKeyboardEmojiCategory *> (self, "_category").name];
}

- (id)initWithFrame:(CGRect)frame {
    self = %orig;
    configureScrollView(self, frame);
    return self;
}

%end

%hook EmojiPageControl

- (void)setHidden: (BOOL)hidden {
    %orig(YES);
}

%end

%ctor {
    id r = [[NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.Emoji10Alpha")] objectForKey:@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLayout.dylib", RTLD_LAZY);
        dlopen("/Library/MobileSubstrate/DynamicLibraries/EmojiLocalization.dylib", RTLD_LAZY);
        %init;
    }
}
