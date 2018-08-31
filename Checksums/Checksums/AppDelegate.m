//
//  AppDelegate.m
//  CheckSums
//
//  Created by Mahesh B Vattigunta on 8/14/18.
//  Copyright © 2018 Mahesh B Vattigunta. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void) awakeFromNib {
    // obtain a new statusItem from the global NSStatusBar
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *image = [NSImage imageNamed:@"CheckSums_16"];
    [statusItem setImage:image];
    
    // create a new NSMenu for the status bar item
    NSMenu *menu = [[NSMenu alloc] init];
    
    // create some top level menu items
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApplication) keyEquivalent:@""];
    [menu addItem:quit];
    
    [statusItem setMenu:menu];
    
    // If your application is background (LSBackgroundOnly) then you need this call
    // otherwise the window manager will draw other windows on top of your menu
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - Menu Actions
- (void) quitApplication {
    NSLog(@"CheckSum is exiting");
    exit(0);
}
@end
