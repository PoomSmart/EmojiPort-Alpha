#import <EmojiLibrary/Header.h>
#import <EmojiLibrary/PSEmojiUtilities.h>
#import <PSHeader/Misc.h>
#import "../EmojiPort-Legacy/LegacyUI.h"

extern NSString *UIKBEmojiDivider;
extern NSString *UIKBEmojiDarkDivider;
extern NSString *UIKBEmojiSelectedDivider;

void (*UIKBThemeSetFontSize)(UIKBThemeRef, CGFloat);
void (*UIKBThemeSetSymbolColor)(UIKBThemeRef, CGColorRef);
void (*UIKBThemeSetForegroundGradient)(UIKBThemeRef, CGGradientRef);
void (*UIKBThemeSetEtchColor)(UIKBThemeRef, CGColorRef);
void (*UIKBThemeSetEtchDY)(UIKBThemeRef, CGFloat);
void (*UIKBThemeRelease)(UIKBThemeRef);

void (*UIKBDrawEtchedSymbolString)(CGContextRef, NSString *, UIKBThemeRef, CGRect);
void (*UIKBDrawRoundRectKeyBackground)(CGContextRef, UIKBTree *, UIKBTree *, int, UIKBThemeRef, UIKBRectsRef);

CGContextRef (*UIKBCreateBitmapContextWithScale)(CGSize size, CGFloat scale);

NSArray <NSString *> *displaySymbolsAsGlyphs() {
    return @[@"🕘", @"😀", @"🐻", @"🌇", @"💡", @"🔣", @"⚽️", @"🍔", @"🏳"];
}

UIImage *egImage(CGRect frame, NSString *imageName, BOOL pressed) {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") imageWithRect:frame name:imageName pressed:pressed];
}

NSMutableArray <UIImage *> *emojiCategoryBarImages(CGRect frame, BOOL pressed) {
    NSMutableArray <UIImage *> *array = [NSMutableArray array];
    [array addObject:egImage(frame, @"categoryRecents", pressed)];
    [array addObject:egImage(frame, @"categoryPeople", pressed)];
    [array addObject:egImage(frame, @"categoryNature", pressed)];
    [array addObject:egImage(frame, @"categoryFoodAndDrink", pressed)];
    [array addObject:egImage(frame, @"categoryActivity", pressed)];
    [array addObject:egImage(frame, @"categoryPlaces", pressed)];
    [array addObject:egImage(frame, @"categoryObjects", pressed)];
    [array addObject:egImage(frame, @"categorySymbols", pressed)];
    [array addObject:egImage(frame, @"categoryFlags", pressed)];
    return array;
}

%hook UIKeyboardEmojiCategoriesControl_iPhone

- (void)layoutSubviews {
    %orig;
    for (UIImageView *divider in MSHookIvar<NSMutableArray *>(self, "_dividerViews"))
        divider.frame = CGRectMake(divider.frame.origin.x - 1.15, divider.frame.origin.y, divider.frame.size.width, divider.frame.size.height);
    for (UIImageView *segment in MSHookIvar<NSMutableArray *>(self, "_segmentViews"))
        segment.frame = CGRectMake(segment.frame.origin.x - 1.15, segment.frame.origin.y, segment.frame.size.width, segment.frame.size.height);
}

- (void)updateSegmentImages {
    NSMutableArray <UIView *> *segmentViews(MSHookIvar<NSMutableArray *>(self, "_segmentViews"));
    for (UIView *segment in segmentViews)
        [segment removeFromSuperview];
    NSMutableArray <UIView *> *dividerViews(MSHookIvar<NSMutableArray *>(self, "_dividerViews"));
    for (UIView *divider in dividerViews)
        [divider removeFromSuperview];
    [self releaseImagesAndViews];
    CGRect barFrame = self.frame;
    CGRect categoryFrame = [[NSClassFromString(@"UIKeyboardLayoutEmoji") emojiLayout] categoryFrame];
    CGFloat dividerWidth = 1.0;
    CGFloat barWidth = barFrame.size.width;
    categoryFrame.size.width = barFrame.size.width = (barWidth - (CATEGORIES_COUNT + 1) * dividerWidth) / CATEGORIES_COUNT;
    NSArray <UIImage *> *unselectedImages(MSHookIvar<NSArray *>(self, "_unselectedImages"));
    [unselectedImages release];
    NSArray <UIImage *> *selectedImages(MSHookIvar<NSArray *>(self, "_selectedImages"));
    [selectedImages release];
    MSHookIvar<NSArray *>(self, "_unselectedImages") = [emojiCategoryBarImages(categoryFrame, NO) retain];
    MSHookIvar<NSArray *>(self, "_selectedImages") = [emojiCategoryBarImages(categoryFrame, YES) retain];
    CGFloat barHeight = barFrame.size.height;
    CGPoint origin = barFrame.origin;
    MSHookIvar<UIImage *>(self, "_plainDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_darkDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDarkDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_selectedDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiSelectedDivider, NO) retain];
    NSUInteger unselectedImagesCount = [MSHookIvar<NSArray *>(self, "_unselectedImages") count];
    MSHookIvar<NSInteger>(self, "_total") = unselectedImagesCount;
    MSHookIvar<NSMutableArray *>(self, "_segmentViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_total")];
    MSHookIvar<NSMutableArray *>(self, "_dividerViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_total") + 1];
    if (MSHookIvar<NSInteger>(self, "_total")) {
        NSUInteger i = 0;
        do {
            UIImageView *unselectedImageView = [[UIImageView alloc] initWithImage:[MSHookIvar<NSArray *>(self, "_unselectedImages") objectAtIndex:i]];
            [self addSubview:unselectedImageView];
            [MSHookIvar < NSMutableArray *> (self, "_segmentViews") insertObject:unselectedImageView atIndex:i];
            [unselectedImageView release];
        } while (++i < MSHookIvar<NSInteger>(self, "_total"));
    }
    if (MSHookIvar<NSInteger>(self, "_total")) {
        NSUInteger j = 0;
        do {
            UIImage *dividerImage = (j && j < MSHookIvar<NSInteger>(self, "_total")) ? MSHookIvar<UIImage *>(self, "_plainDivider") : MSHookIvar<UIImage *>(self, "_darkDivider");
            UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:dividerImage];
            [self addSubview:dividerImageView];
            [MSHookIvar<NSMutableArray *>(self, "_dividerViews") insertObject:dividerImageView atIndex:j];
            [dividerImageView release];
        } while (++j - 1 < MSHookIvar<NSInteger>(self, "_total"));
    }
    [self updateSegmentAndDividers:MSHookIvar<int>(self, "_selected")];
}

%end

%hook UIKeyboardEmojiGraphics

- (UIImage *)categoryKeyGenerator:(bool)pressed rect:(CGRect)rect {
    UIKBTree *protoKey = [self protoKeyWithDisplayString:@"!"];
    UIKBShape *shape = [[[%c(UIKBShape) alloc] initWithGeometry:nil frame:rect paddedFrame:rect] autorelease];
    protoKey.shape = shape;
    UIKBTree *protoKeyboard = [self protoKeyboard];
    int state = pressed ? 8 : 4;
    UIKBThemeRef theme = [self createProtoThemeForKey:protoKey keyboard:protoKeyboard state:state];
    CGFloat fontSize = [%c(UIKeyboardEmojiGraphics) isLandscape] ? 38.0 : 32.0;
    UIKBThemeSetFontSize(theme, fontSize);
    CGColorRef color = NULL;
    CGGradientRef gradient = NULL;
    if (pressed) {
        UIKBThemeSetSymbolColor(theme, UIKBGetNamedColor(CFSTR("UIKBColorWhite")));
        UIKBThemeSetEtchColor(theme, UIKBGetNamedColor(CFSTR("UIKBColorBlack_Alpha50")));
        UIKBThemeSetEtchDY(theme, -1.0);
        CGColorRef end = UIKBGetNamedColor(CFSTR("UIKBColorKeyBlueRow1GradientEnd"));
        CGColorRef start = UIKBGetNamedColor(CFSTR("UIKBColorKeyBlueRow1GradientStart"));
        gradient = UIKBCreateTwoColorLinearGradient(end, start);
        UIKBThemeSetForegroundGradient(theme, gradient);
    } else {
        color = UIKBColorCreate(69, 69, 85, 1.0);
        UIKBThemeSetSymbolColor(theme, color);
    }
    UIKBRectsRef rects = UIKBRectsCreate(protoKeyboard, protoKey);
    CGFloat scale = UIKBScale();
    CGContextRef ctx = UIKBCreateBitmapContextWithScale(rect.size, scale);
    CGContextSaveGState(ctx);
    CGContextResetCTM(ctx);
    CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
    CGContextConcatCTM(ctx, t);
    t.a = 1.0;
    t.b = 0.0;
    t.c = 0.0;
    t.d = -1.0;
    t.tx = 0.0;
    t.ty = rect.size.height;
    CGContextConcatCTM(ctx, t);
    CGRect frame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetFrame(rects, frame);
    CGRect displayFrame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetDisplayFrame(rects, displayFrame);
    CGRect paddedFrame = CGRectInset(protoKey.frame, 4.0, 4.0);
    UIKBRectsSetPaddedFrame(rects, paddedFrame);
    UIKBDrawRoundRectKeyBackground(ctx, protoKeyboard, protoKey, state, theme, rects);
    CGRect symbolRect = CGRectInset(rect, 4.0, 4.0);
    CGFloat d = symbolRect.size.width / CATEGORIES_COUNT;
    symbolRect.origin.x -= 4 * d; // FIXME: We should not need this line
    for (NSString *symbol in displaySymbolsAsGlyphs()) {
        CGContextSaveGState(ctx);
        UIKBDrawEtchedSymbolString(ctx, symbol, theme, symbolRect);
        CGContextRestoreGState(ctx);
        symbolRect.origin.x += d;
    }
    CGImageRef cgImage = CGBitmapContextCreateImage(ctx);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:0];
    CGContextRelease(ctx);
    CGImageRelease(cgImage);
    UIKBRectsRelease(rects);
    if (color)
        CGColorRelease(color);
    if (gradient)
        CGGradientRelease(gradient);
    UIKBThemeRelease(theme);
    return image;
}

- (UIImage *)categoryRecentsGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🕘" pressed:pressed];
}

- (UIImage *)categoryPeopleGenerator:(id)pressed {
    return [self categoryWithSymbol:@"😀" pressed:pressed];
}

- (UIImage *)categoryNatureGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🐻" pressed:pressed];
}

- (UIImage *)categoryPlacesGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🌇" pressed:pressed];
}

- (UIImage *)categoryObjectsGenerator:(id)pressed {
    return [self categoryWithSymbol:@"💡" pressed:pressed];
}

- (UIImage *)categorySymbolsGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🔣" pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryActivityGenerator:(id)pressed {
    return [self categoryWithSymbol:@"⚽️" pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryFoodAndDrinkGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🍔" pressed:pressed];
}

%new(@@:@)
- (UIImage *)categoryFlagsGenerator:(id)pressed {
    return [self categoryWithSymbol:@"🏳" pressed:pressed];
}

%end

%ctor {
    MSImageRef ref = MSGetImageByName(realPath2(@"/System/Library/Frameworks/UIKit.framework/UIKit"));
    UIKBThemeSetFontSize = (void (*)(UIKBThemeRef, CGFloat))MSFindSymbol(ref, "_UIKBThemeSetFontSize");
    UIKBThemeSetSymbolColor = (void (*)(UIKBThemeRef, CGColorRef))MSFindSymbol(ref, "_UIKBThemeSetSymbolColor");
    UIKBThemeSetForegroundGradient = (void (*)(UIKBThemeRef, CGGradientRef))MSFindSymbol(ref, "_UIKBThemeSetForegroundGradient");
    UIKBThemeSetEtchColor = (void (*)(UIKBThemeRef, CGColorRef))MSFindSymbol(ref, "_UIKBThemeSetEtchColor");
    UIKBThemeSetEtchDY = (void (*)(UIKBThemeRef, CGFloat))MSFindSymbol(ref, "_UIKBThemeSetEtchDY");
    UIKBThemeRelease = (void (*)(UIKBThemeRef))MSFindSymbol(ref, "_UIKBThemeRelease");
    UIKBDrawEtchedSymbolString = (void (*)(CGContextRef, NSString *, UIKBThemeRef, CGRect))MSFindSymbol(ref, "_UIKBDrawEtchedSymbolString");
    UIKBDrawRoundRectKeyBackground = (void (*)(CGContextRef, UIKBTree *, UIKBTree *, int, UIKBThemeRef, UIKBRectsRef))MSFindSymbol(ref, "_UIKBDrawRoundRectKeyBackground");
    UIKBCreateBitmapContextWithScale = (CGContextRef (*)(CGSize, CGFloat))MSFindSymbol(ref, "_UIKBCreateBitmapContextWithScale");
    %init;
}
