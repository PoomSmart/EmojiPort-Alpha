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
    if (categoryType == NSNotFound)
        return nil;
    UIKeyboardEmojiCategory *categoryForKey = [categories objectForKey:categoryKey];
    if (categoryForKey == nil) {
        categoryForKey = [[[NSClassFromString(@"UIKeyboardEmojiCategory") alloc] init] autorelease];
        [categoryForKey setValue:categoryKey forKey:@"_name"];
        [categories setObject:categoryForKey forKey:categoryKey];
    }
    NSArray <UIKeyboardEmoji *> *emojiForKey = categoryForKey.emoji;
    if (emojiForKey.count)
        return categoryForKey;
    if (categoryType > CATEGORIES_COUNT)
        return nil;
    NSArray <NSString *> *emojiArray = [PSEmojiUtilities PrepolulatedEmoji];
    switch (categoryType) {
        case 0: {
            NSMutableArray <UIKeyboardEmoji *> *recents = [(UIKeyboardLayoutEmoji *)[self valueForKey:@"emojiController"] recents]; // ?
            if (recents) {
                categoryForKey.emoji = recents;
                return categoryForKey;
            }
            break;
        }
        case 1:
            emojiArray = [PSEmojiUtilities PeopleEmoji];
            break;
        case 2:
            emojiArray = [PSEmojiUtilities NatureEmoji];
            break;
        case 3:
            emojiArray = [PSEmojiUtilities FoodAndDrinkEmoji];
            break;
        case 4:
            emojiArray = [PSEmojiUtilities ActivityEmoji];
            break;
        case 5:
            emojiArray = [PSEmojiUtilities TravelAndPlacesEmoji];
            break;
        case 6:
            emojiArray = [PSEmojiUtilities ObjectsEmoji];
            break;
        case 7:
            emojiArray = [PSEmojiUtilities SymbolsEmoji];
            break;
        case 8:
            emojiArray = [PSEmojiUtilities FlagsEmoji];
            break;
    }
    NSMutableArray <UIKeyboardEmoji *> *_emojiArray = [NSMutableArray arrayWithCapacity:emojiArray.count];
    for (NSString *emojiString in emojiArray)
        [PSEmojiUtilities addEmoji:_emojiArray emojiString:emojiString];
    categoryForKey.emoji = _emojiArray;
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
