#import "../../EmojiLibrary/PSEmojiUtilities.h"
#import "../../EmojiLibrary/Header.h"
#import "../EmojiHUD.h"

%hook UIKeyboardEmoji

%property(assign) BOOL supportsSkin;

%end

%hook UIKeyboardEmojiCategory

%new
+ (BOOL)emojiString: (NSString *)emojiString inGroup: (NSArray <NSString *> *)group {
    return [PSEmojiUtilities emojiString:emojiString inGroup:group];
}

%end

%hook UIKeyboardEmojiCategoryController

- (UIKeyboardEmojiCategory *)categoryForKey: (NSString *)categoryKey {
    NSMutableDictionary <NSString *, UIKeyboardEmojiCategory *> *categories = [self valueForKey:@"categories"];
    NSInteger categoryType = [[NSClassFromString(@"UIKeyboardEmojiCategory") categoriesMap] indexOfObject:categoryKey];
    if (categoryType == NSNotFound || categoryType > CATEGORIES_COUNT)
        return nil;
    UIKeyboardEmojiCategory *categoryForKey = [categories objectForKey:categoryKey];
    NSArray <UIKeyboardEmoji *> *emojiForKey = categoryForKey.emoji;
    if (emojiForKey.count)
        return categoryForKey;
    NSArray <NSString *> *emojiArray = [PSEmojiUtilities PrepolulatedEmoji];
    switch (categoryType) {
        case IDXPSEmojiCategoryRecent:
            emojiArray = nil;
            break;
        case IDXPSEmojiCategoryPeople:
            emojiArray = [PSEmojiUtilities PeopleEmoji];
            break;
        case IDXPSEmojiCategoryNature:
            emojiArray = [PSEmojiUtilities NatureEmoji];
            break;
        case IDXPSEmojiCategoryFoodAndDrink:
            emojiArray = [PSEmojiUtilities FoodAndDrinkEmoji];
            break;
        case IDXPSEmojiCategoryActivity:
            emojiArray = [PSEmojiUtilities ActivityEmoji];
            break;
        case IDXPSEmojiCategoryTravelAndPlaces:
            emojiArray = [PSEmojiUtilities TravelAndPlacesEmoji];
            break;
        case IDXPSEmojiCategoryObjects:
            emojiArray = [PSEmojiUtilities ObjectsEmoji];
            break;
        case IDXPSEmojiCategorySymbols:
            emojiArray = [PSEmojiUtilities SymbolsEmoji];
            break;
        case IDXPSEmojiCategoryFlags:
            emojiArray = [PSEmojiUtilities FlagsEmoji];
            break;
    }
    NSMutableArray <UIKeyboardEmoji *> *_emojiArray = emojiArray ? [NSMutableArray arrayWithCapacity:emojiArray.count] : [[(UIKeyboardLayoutEmoji *)[self valueForKey:@"emojiController"] recents] retain];
    for (NSString *emojiString in emojiArray)
        [PSEmojiUtilities addEmoji:_emojiArray emojiString:emojiString];
    if (categoryForKey == nil) {
        categoryForKey = [[[NSClassFromString(@"UIKeyboardEmojiCategory") alloc] init] autorelease];
        [categoryForKey setValue:categoryKey forKey:@"_name"];
        categoryForKey.emoji = _emojiArray;
        [categories setObject:categoryForKey forKey:categoryKey];
    }
    NSDictionary <NSString *, NSDictionary *> *defaultsData = [self valueForKey:@"_defaultsData"];
    NSDictionary <NSString *, NSNumber *> *categoryDefaults = [defaultsData objectForKey:categoryKey];
    if (categoryDefaults)
        categoryForKey.lastViewedPage = [[categoryDefaults objectForKey:@"LastViewedPageKey"] intValue];
    return categoryForKey;
}

%end

%hook UIKeyboardLayoutEmoji

- (void)categoryChangedNoSounds {
    int selectedIndex = ((UIKeyboardEmojiCategoriesControl *)[self valueForKey:@"_categoriesView"]).selectedIndex;
    if (selectedIndex == 0)
        [(UIKeyboardEmojiCategoryController *)[self valueForKey:@"_categoryController"] updateRecents];
    NSString *categoryName = [[NSClassFromString(@"UIKeyboardEmojiCategory") categoriesMap] objectAtIndex:selectedIndex];
    if (categoryName == nil)
        return;
    [(UIKeyboardEmojiScrollView *)[self valueForKey:@"_emojiView"] setCategory:[(UIKeyboardEmojiCategoryController *)[self valueForKey:@"_categoryController"] categoryForKey:categoryName]];
}

%end

%ctor {
    %init;
}
