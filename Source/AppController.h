//
//  AppController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ShortcutRecorder/ShortcutRecorder.h>

#import "OMHShortcutKey.h"
#import "OMHClippingController.h"
#import "OMHClipboardController.h"
#import "OMHPreferenceController.h"
#import "OMHQuickPreviewWindowController.h"


#define autoSaveInterval 60*10 // How often should we save the clippings


@interface AppController: NSObject 
{   
    // Main Window 
    IBOutlet NSWindow *mainWindow;
    
    // Controllers
    IBOutlet OMHClippingController *clippingController;
    
    // Core data
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;    
 
    // Other
    NSStatusItem *statusItem;
    NSTimer *autoSaveTimer;
}

// Properties
@property( nonatomic, retain ) NSStatusItem *statusItem;
@property( nonatomic, retain ) NSWindow *mainWindow;

// Actions
- (IBAction) showPreferencesWindow:(id)sender;
- (IBAction) toogleQuickPreviewWindow:(id)sender;

// Methods
- (void) createStatusMenu;
- (void) flashStatusMenu;
- (void) statusMenuItemClicked;

// Delegation methods
- (void) shortcutDidChange:(NSString *)shortcutId keyCombo:(NSValue *)wrappedKeyCombo;

// Core data
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;


@end
