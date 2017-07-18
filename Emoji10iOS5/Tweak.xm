#import "../../EmojiLibrary/PSEmojiUtilities.h"
#import "../../EmojiLibrary/Header.h"
#import <CoreFoundation/CoreFoundation.h>
#import <CoreText/CoreText.h>
#import "../../Emoji10Legacy/EmojiHUD.h"
#import "../../Emoji10Legacy/KBResize.x"
#import "../../Emoji10Legacy/Header.h"

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

+ (UIKeyboardEmojiCategory *)categoryForKey: (NSString *)categoryKey {
    NSMutableDictionary <NSString *, UIKeyboardEmojiCategory *> *categories = [self valueForKey:@"categories"];
    NSInteger categoryType = [[NSClassFromString(@"UIKeyboardEmojiCategory") categoriesMap] indexOfObject:categoryKey];
    if (categoryType == NSNotFound)
        return nil;
    UIKeyboardEmojiCategory *categoryForType = [categories objectForKey:categoryKey];
    if (categoryForType == nil) {
        categoryForType = [[[NSClassFromString(@"UIKeyboardEmojiCategory") alloc] init] autorelease];
        [categoryForType setValue:categoryKey forKey:@"_name"];
        [categories setObject:categoryForType forKey:categoryKey];
    }
    NSArray <UIKeyboardEmoji *> *emojiForType = categoryForType.emoji;
    if (emojiForType.count)
        return categoryForType;
    if (categoryType > CATEGORIES_COUNT)
        return nil;
    NSArray <NSString *> *emojiArray = [PSEmojiUtilities PrepolulatedEmoji];
    switch (categoryType) {
        case 0: {
            NSMutableArray <UIKeyboardEmoji *> *recents = [(UIKeyboardLayoutEmoji *)[self valueForKey:@"emojiController"] recents]; // ?
            if (recents) {
                categoryForType.emoji = recents;
                return categoryForType;
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
    categoryForType.emoji = _emojiArray;
    return categoryForType;
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
