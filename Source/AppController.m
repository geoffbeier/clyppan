//
//  AppController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import "AppController.h"


@implementation AppController


@synthesize statusItem;
@synthesize mainWindow;


#pragma mark -
#pragma mark Initialization and Setup
- (void) awakeFromNib
{
    // Create the status menu item
    [self createStatusMenu];
 
    // Set self as delegate for handling hot keys
    [[OMHShortcutKey sharedShortcutKey] setDelegate:self];

    // Set up the custom preference controller
    [[OMHPreferenceController sharedPrefsWindowController] setDelegate:self];
    [[OMHPreferenceController sharedPrefsWindowController] loadHotKeyFromUserDefaults];

    // Observe certain user default keypaths
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    [defaults addObserver:self forKeyPath:@"clippingPurgeLimit" options:0 context:NULL];

    // Set purge limit
    clippingController.clippingPurgeLimit = [[defaults objectForKey:@"clippingPurgeLimit"] intValue];    

    // Set window collection behaviour
    [mainWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];  
    
    // Set up the clipboard controller
    [[OMHClipboardController sharedController] createTimer];
}

/*!
 * Creates a status menu item visible in the top right of the screen.
 */
- (void) createStatusMenu
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:27];
	[statusItem setImage:[NSImage imageNamed:@"clyppan-small"]];
	[statusItem setHighlightMode:YES];	 
    [statusItem setTarget:self];
    [statusItem setAction:@selector( statusMenuItemClicked )];    
}


#pragma mark -
#pragma mark Interface Actions

/*!
 * Handles the event of the status menu item getting clicked.
 */
- (void) statusMenuItemClicked
{
    [NSApp activateIgnoringOtherApps:YES]; 
    
}

- (IBAction) showPreferencesWindow:(id)sender
{
    [[OMHPreferenceController sharedWindowController] showWindow:nil];
}

- (IBAction) toogleQuickPreviewWindow:(id)sender
{
    [[OMHQuickPreviewWindowController sharedWindowController] toogleQuickPreviewWindow:self];
}


#pragma mark -
#pragma mark Methods

/*
 * Flashes the status icon for a short while
 */
- (void) flashStatusMenu
{
    [self.statusItem setImage:[NSImage imageNamed:@"clyppan-small-inverted"]];
    [self.statusItem performSelector:@selector( setImage: )
     withObject:[NSImage imageNamed:@"clyppan-small"]
     afterDelay:0.40];
}

/*
 * Stores everything in the managed object context to disk
 */
- (void) autoSave
{
    NSError *error = nil;
    if ( ![[self managedObjectContext] save:&error] ) 
    {
        [[NSApplication sharedApplication] presentError:error];
    }
    NSLog( @"MOC is saved" );
}


#pragma mark -
#pragma mark Notifications / Delegation methods

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Start autosaving timer
    //[OMHClippingController createAutoSaveTimer:60 * 15];
	autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:autoSaveInterval
       	  									 target:self
                                           selector:@selector( autoSave )
                                           userInfo:nil 
                                            repeats:YES];
    
}

/*!
 * Displays the main window if it's was previously closed. 
 */
- (void) applicationWillBecomeActive:(NSNotification *)aNotification
{
    if ( ![mainWindow isVisible] )
    {
        [mainWindow orderFrontRegardless];
    }
    [mainWindow makeKeyAndOrderFront:self];
}

- (void) applicationWillResignActive:(NSNotification *)aNotification
{
    [NSApp hide:self];
}

- (void) handleHotKey:(NSString *)identifier;
{
    [self flashStatusMenu];
    if ( [identifier isEqualTo:ShortcutActivateAppId] )
    {
        if ( [mainWindow isKeyWindow] && [mainWindow isVisible] )
        {
            [mainWindow orderOut:self];
            [NSApp hide:self];
        }
        else
        {
            [NSApp activateIgnoringOtherApps:YES];
            [mainWindow makeKeyAndOrderFront:self];
        }            
    }
    else if ( [identifier isEqualTo:ShortcutRapidPasteId] )
    {
        [clippingController rapidPaste];
    }

}

- (void) shortcutDidChange:(NSString *)shortcutId keyCombo:(NSValue *)wrappedKeyCombo;
{
    KeyCombo keyCombo;
    [wrappedKeyCombo getValue:&keyCombo];
    
    OMHShortcutKey *hotKey = [OMHShortcutKey sharedShortcutKey];
    [hotKey unRegisterShortcutKey:shortcutId];  
    [hotKey registerShortcutKey:shortcutId key:keyCombo.code modifier:keyCombo.flags];
}


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    NSLog( @"Key changed %@", keyPath );
    if ( [keyPath isEqualToString:@"clippingPurgeLimit"] )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        clippingController.clippingPurgeLimit = [[defaults objectForKey:@"clippingPurgeLimit"] intValue];
    }
}


#pragma mark -
#pragma mark Core data
/**
 Returns the support folder for the application, used to store the Core Data
 store file.  This code uses a folder named "Clyppan" for
 the content, either in the NSApplicationSupportDirectory location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Clyppan"];
}


/**
 Creates, retains, and returns the managed object model for the application 
 by merging all of the models found in the application bundle.
 */

- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.  This 
 implementation will create and return a coordinator, having added the 
 store for the application to it.  (The folder for the store is created, 
 if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"Clyppan.sql"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
    
    return persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */

- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
 Returns the NSUndoManager for the application.  In this case, the manager
 returned is that of the managed object context for the application.
 */

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


///**
// Performs the save action for the application, which is to send the save:
// message to the application's managed object context.  Any encountered errors
// are presented to the user.
// */
//
//- (IBAction) saveAction:(id)sender {
//    
//    NSError *error = nil;
//    if (![[self managedObjectContext] save:&error]) {
//        [[NSApplication sharedApplication] presentError:error];
//    }
//}


/**
 Implementation of the applicationShouldTerminate: method, used here to
 handle the saving of changes in the application managed object context
 before the application terminates.
 */

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.
                
                // Typically, this process should be altered to include application-specific 
                // recovery steps.  
                
                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 
                
                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


@end
