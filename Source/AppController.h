//
//  AppController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OMHClippingController;


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
    IBOutlet NSTextField *statusTextField;
}

// Properties
@property( nonatomic, retain ) NSStatusItem *statusItem;
@property( nonatomic, retain ) NSWindow *mainWindow;

// Actions
- (IBAction) showMainWindow:(id)sender;
- (IBAction) showPreferencesWindow:(id)sender;
- (IBAction) toogleMainWindow:(id)sender;
- (IBAction) toogleQuickPreviewWindow:(id)sender;


// Methods
- (void) createStatusMenu;
- (void) flashStatusMenu;
- (void) statusMenuItemClicked;
- (NSString *) activateKeyComboString;

// Delegation methods
- (void) shortcutDidChange:(NSString *)shortcutId keyCombo:(NSValue *)wrappedKeyCombo;

// Core data
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

@end
