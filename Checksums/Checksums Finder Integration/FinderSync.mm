//
//  FinderSync.mm
//  CheckSums Finder Integration
//
//  Created by Mahesh B Vattigunta on 8/14/18.
//  Copyright © 2018 Mahesh B Vattigunta. All rights reserved.
//

#include <pwd.h>
#include <assert.h>

#include "FinderSync.hpp"
#include "Hash.hpp"

@interface FinderSync ()

@property NSURL *myFolderURL;

@end

@implementation FinderSync

- (instancetype)init {
    self = [super init];
    
    NSLog(@"%s launched from %@ ; compiled at %s", __PRETTY_FUNCTION__, [[NSBundle mainBundle] bundlePath], __TIME__);
    
    struct passwd *pw = getpwuid(getuid());
    if (NULL != pw)
    {
        // Set up the directory we would like to calculate hashes when right clicked.
        self.myFolderURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:pw->pw_dir]];
        [FIFinderSyncController defaultController].directoryURLs = [NSSet setWithObject:self.myFolderURL];
    }
    
    return self;
}

#pragma mark - Primary Finder Sync protocol methods

- (void)requestBadgeIdentifierForURL:(NSURL *)url {
    NSLog(@"requestBadgeIdentifierForURL:%@", url.filePathURL);
    
    // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
    NSInteger whichBadge = [url.filePathURL hash] % 3;
    NSString* badgeIdentifier = @[@"", @"One", @"Two"][whichBadge];
    [[FIFinderSyncController defaultController] setBadgeIdentifier:badgeIdentifier forURL:url];
}

- (NSMenu *)menuForMenuKind:(FIMenuKind)whichMenu {
    NSArray *items = [[FIFinderSyncController defaultController] selectedItemURLs];
    
    // Keep things simple. Selection of multiple items not allowed.
    if (1 < [items count])
    {
        return NULL;
    }
    
    NSURL *item = items.firstObject;
    BOOL bDir = false;
    [[NSFileManager defaultManager] fileExistsAtPath:[item path] isDirectory:&bDir];
    
    // Again, keep things simple. Selection of a directory is not allowed.
    if (bDir)
    {
        return NULL;
    }
    
    // Compute checksums for the file selected and performed right-click action.
    const char* fileName = [item fileSystemRepresentation];
    CheckSumMap checkSums;
    if (!HashFile(fileName, checkSums))
    {
        return NULL;
    }
    
    // Produce a menu for the extension.
    NSMenu *contextMenu = [[NSMenu alloc] initWithTitle:@"Contextmenu"];
    NSMenuItem *subMenuItem = [[NSMenuItem alloc] init];
    [subMenuItem setAction:@selector(copyAllCheckSums:)];
    
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:@"Checksums"];
    [subMenuItem setTitle:[subMenu title]];
    
    // Creates the menu entries.
    for (std::pair<CheckSumType, std::string> element : checkSums)
    {
        std::string checkSum = GetCheckSumTypeStr(element.first) + "\t : " + element.second;
        NSString *menuTitle = [NSString stringWithUTF8String:checkSum.c_str()];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuTitle action:@selector(copyCheckSum:) keyEquivalent:@""];
        [subMenu addItem:menuItem];
    }
    
    [subMenuItem setSubmenu:subMenu];
    [contextMenu addItem:subMenuItem];
    
    return contextMenu;
}

- (IBAction)copyCheckSum:(NSMenuItem* )sender {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:[sender title] forType:NSStringPboardType];
}

- (IBAction)copyAllCheckSums:(NSMenuItem* )sender {
    if ([sender hasSubmenu])
    {
        // BUGBUG : Does not come here even if the contextual menu item has submenu
        //          For now, click on each individual
        NSArray *menu_items = [[sender submenu] itemArray];
        for (NSMenuItem* item in menu_items)
        {
            NSLog(@"\n %@", [item title]);
        }
    }
}
@end
