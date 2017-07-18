#import "../EmojiLibrary/Header.h"
#import "../EmojiLibrary/PSEmojiUtilities.h"
#import "../PSHeader/Misc.h"

extern NSString *UIKBEmojiDivider;
extern NSString *UIKBEmojiDarkDivider;
extern NSString *UIKBEmojiSelectedDivider;

UIImage *egImage(CGRect frame, NSString *imageName, BOOL pressed) {
    return [NSClassFromString(@"UIKeyboardEmojiGraphics") imageWithRect:frame name:imageName pressed:pressed];
}

NSMutableArray *emojiCategoryBarImages(CGRect frame, BOOL pressed) {
    NSMutableArray *array = [NSMutableArray array];
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

// Adjustment for segments and dividers in case categories count > default
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
    NSUInteger numberOfCategories = CATEGORIES_COUNT;
    CGRect barFrame = self.frame;
    CGFloat dividerWidth = 1.0;
    CGFloat barWidth = barFrame.size.width;
    barFrame.size.width = (barWidth - (numberOfCategories + 1) * dividerWidth) / numberOfCategories;
    NSArray <UIImage *> *unselectedImages(MSHookIvar<NSArray *>(self, "_unselectedImages"));
    [unselectedImages release];
    NSArray <UIImage *> *selectedImages(MSHookIvar<NSArray *>(self, "_selectedImages"));
    [selectedImages release];
    MSHookIvar<NSArray *>(self, "_unselectedImages") = [emojiCategoryBarImages(barFrame, NO) retain];
    MSHookIvar<NSArray *>(self, "_selectedImages") = [emojiCategoryBarImages(barFrame, YES) retain];
    CGFloat barHeight = barFrame.size.height;
    CGPoint origin = barFrame.origin;
    MSHookIvar<UIImage *>(self, "_plainDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_darkDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiDarkDivider, NO) retain];
    MSHookIvar<UIImage *>(self, "_selectedDivider") = [egImage(CGRectMake(origin.x, origin.y, dividerWidth, barHeight), UIKBEmojiSelectedDivider, NO) retain];
    NSUInteger unselectedImagesCount = [MSHookIvar<NSArray *>(self, "_unselectedImages")count];
    MSHookIvar<NSInteger>(self, "_total") = unselectedImagesCount;
    MSHookIvar<NSMutableArray *>(self, "_segmentViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_total")];
    MSHookIvar<NSMutableArray *>(self, "_dividerViews") = [[NSMutableArray alloc] initWithCapacity:MSHookIvar<NSInteger>(self, "_total") + 1];
    if (MSHookIvar<NSInteger>(self, "_total") > 0) {
        NSUInteger i = 0;
        do {
            UIImageView *unselectedImageView = [[UIImageView alloc] initWithImage:[MSHookIvar<NSArray *>(self, "_unselectedImages") objectAtIndex:i]];
            [self addSubview:unselectedImageView];
            [MSHookIvar<NSMutableArray *>(self, "_segmentViews") insertObject:unselectedImageView atIndex:i];
            [unselectedImageView release];
            ++i;
        } while (i < MSHookIvar<NSInteger>(self, "_total"));
    }
    if (MSHookIvar<NSInteger>(self, "_total") > 0) {
        NSUInteger j = 0;
        do {
            UIImage *dividerImage = (j > 0 && j < MSHookIvar<NSInteger>(self, "_total")) ? MSHookIvar<UIImage *>(self, "_plainDivider") : MSHookIvar<UIImage *>(self, "_darkDivider");
            UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:dividerImage];
            [self addSubview:dividerImageView];
            [MSHookIvar<NSMutableArray *>(self, "_dividerViews") insertObject:dividerImageView atIndex:j];
            [dividerImageView release];
            ++j;
        } while (j - 1 < MSHookIvar<NSInteger>(self, "_total"));
    }
    [self updateSegmentAndDividers:MSHookIvar < int > (self, "_selected")];
}

%end

%hook UIKeyboardEmojiGraphics

- (UIImage *)categoryRecentsGenerator: (id)pressed {
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

%new
- (UIImage *)categoryActivityGenerator: (id)pressed {
    return [self categoryWithSymbol:@"⚽️" pressed:pressed];
}

%new
- (UIImage *)categoryFoodAndDrinkGenerator: (id)pressed {
    return [self categoryWithSymbol:@"🍔" pressed:pressed];
}

%new
- (UIImage *)categoryFlagsGenerator: (id)pressed {
    return [self categoryWithSymbol:@"🏳" pressed:pressed];
}

%end

%ctor {
    %init;
}
