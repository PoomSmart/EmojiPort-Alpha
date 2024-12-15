#import <EmojiLibrary/Header.h>
#import <PSHeader/Misc.h>
#import <theos/IOSMacros.h>
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
    UILabel *label = MSHookIvar<UILabel *>(self, "_categoryLabel");
    label.alpha = 0.4;
    label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    label.backgroundColor = UIColor.clearColor;
    label.textAlignment = NSTextAlignmentLeft;
    [self updateLabel:MSHookIvar<UIKeyboardEmojiCategory *>(self, "_category").name];
    setLabelFrame(label, frame);
}

%hook PSEmojiLayout

+ (CGFloat)dotHeight {
    return LABEL_HEIGHT;
}

%end

%hook UIKeyboardEmojiCategory

- (NSString *)displayName {
    return NSStringEqual(self.name, @"UIKeyboardEmojiCategoryRecents") ? [NSClassFromString(@"UIKeyboardLayoutEmoji") localizedStringForKey:@"RECENTS_TITLE"] : %orig;
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
    id r = [[NSDictionary dictionaryWithContentsOfFile:realPrefPath(@"com.PS.EmojiPortAlpha")] objectForKey:@"enabled"];
    BOOL enabled = r ? [r boolValue] : YES;
    if (enabled) {
        %init;
    }
}
