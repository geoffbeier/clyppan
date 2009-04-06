//
//  AppController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <ShortcutRecorder/ShortcutRecorder.h>

#import "AppController.h"
#import "OMHShortcutKey.h"
#import "OMHClippingController.h"
#import "OMHClipboardController.h"
#import "OMHPreferenceController.h"
#import "OMHQuickPreviewWindowController.h"
#import "OMHStatusItemWindowController.h"


@implementation AppController

@synthesize statusItem;
@synthesize mainWindow;

#pragma mark -
#pragma mark Initialization and Setup

+ (void) initialize;
{
	// Set default values for preferences
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Register Ctrl+Command+C as the default short cut
    [defaultValues setObject:[NSNumber numberWithShort:8] forKey:OMHActivateAppKey];
    [defaultValues setObject:[NSNumber numberWithUnsignedInt:768] forKey:OMHActivateAppModifierKey];
    
    // Register Shift+Command+V as the default short cut
    [defaultValues setObject:[NSNumber numberWithShort:9] forKey:OMHRapidPasteKey];
    [defaultValues setObject:[NSNumber numberWithUnsignedInt:768] forKey:OMHRapidPasteModifierKey];
    
    // Set default limit for when to purge old clippings
    [defaultValues setObject:[NSNumber numberWithInt:50] forKey:OMHClippingPurgeLimitKey];
    
    // Set a flag to know if we've ever started before
    [defaultValues setObject:[NSNumber numberWithBool:NO] forKey:OMHAppHasLaunchedBeforeKey];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (void) awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    

    // Show floating helper window
    if ( ![defaults boolForKey:OMHAppHasLaunchedBeforeKey] )
    {
        [[OMHStatusItemWindowController sharedWindowController] showWindow:self];
    }
    
    // Create the status menu item
    [self createStatusMenu];
 
    // Set self as delegate for handling hot keys
    [[OMHShortcutKey sharedShortcutKey] setDelegate:self];

    // Set up the custom preference controller
    [[OMHPreferenceController sharedWindowController] setDelegate:self];
    [[OMHPreferenceController sharedWindowController] loadHotKeyFromUserDefaults];

    // Observe certain user default keypaths
    [defaults addObserver:self forKeyPath:OMHClippingPurgeLimitKey options:0 context:NULL];

    // Set purge limit
    clippingController.clippingPurgeLimit = [[defaults objectForKey:OMHClippingPurgeLimitKey] intValue];    

    // Set window collection behaviour
    [mainWindow setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];  
    
    // Set up the clipboard controller
    [[OMHClipboardController sharedController] createTimer];
    
    // Apply an embossed look to the status text
    [statusTextField.cell setBackgroundStyle:NSBackgroundStyleRaised];
}

/*!
 * Creates a status menu item visible in the top right of the screen.
 */
- (void) createStatusMenu
{        
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:27];
    [statusItem setHighlightMode:YES];	 
    [statusItem setTarget:self];
    [statusItem setAction:@selector( statusMenuItemClicked )];       
    [statusItem setImage:[NSImage imageNamed:@"clyppan-small"]];
}


#pragma mark -
#pragma mark Interface Actions

- (IBAction) showMainWindow:(id)sender;
{
    [NSApp activateIgnoringOtherApps:YES]; 
    [mainWindow makeKeyAndOrderFront:self];
}

/*!
 * Handles the event of the status menu item getting clicked.
 */
- (void) statusMenuItemClicked
{
    [self toogleMainWindow:self];
}

- (IBAction) showPreferencesWindow:(id)sender
{
    [[OMHPreferenceController sharedWindowController] showWindow:nil];
}

- (IBAction) toogleMainWindow:(id)sender
{
    if ( [mainWindow isKeyWindow] && [mainWindow isVisible] )
    {
        [mainWindow orderOut:self];
        [NSApp hide:self];
    }
    else
    {
        [self showMainWindow:self];
    }    
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
}

/* 
 * Returns the string representation the activate keyboard shortcut 
 */
- (NSString *) activateKeyComboString
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    signed short activateKey = [[defaults objectForKey:OMHActivateAppKey] shortValue];
    unsigned int activateModifier = [[defaults objectForKey:OMHActivateAppModifierKey] unsignedIntValue];
    
	return [NSString stringWithFormat: @"%@%@",
            SRStringForCocoaModifierFlags( SRCarbonToCocoaFlags( activateModifier ) ),
            SRStringForKeyCode( activateKey )];
}


#pragma mark -
#pragma mark Notifications / Delegation methods

- (void) windowDidBecomeKey:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ( [defaults boolForKey:OMHAppHasLaunchedBeforeKey] )
    {
        [[OMHStatusItemWindowController sharedWindowController] close];
        [defaults setBool:YES forKey:OMHAppHasLaunchedBeforeKey];        
    }
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Start autosaving timer
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
    // Don't show the main window if we're starting up for the first time.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    
    if ( [defaults boolForKey:OMHAppHasLaunchedBeforeKey] )
    {
        [self showMainWindow:self];        
    }
    
    [defaults setBool:YES forKey:OMHAppHasLaunchedBeforeKey];
}

- (void) applicationWillResignActive:(NSNotification *)aNotification
{
    [[OMHStatusItemWindowController sharedWindowController] close];
    [NSApp hide:self];
}

- (void) handleHotKey:(NSString *)identifier;
{
    [self flashStatusMenu];
    if ( [identifier isEqualTo:OMHShortcutActivateAppId] )
    {
        [self toogleMainWindow:self];
        return;
    }
    
    if ( [identifier isEqualTo:OMHShortcutRapidPasteId] )
    {
        [clippingController rapidPaste];
        return;
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
    if ( [keyPath isEqualToString:OMHClippingPurgeLimitKey  ] )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        clippingController.clippingPurgeLimit = [[defaults objectForKey:OMHClippingPurgeLimitKey] intValue];
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
