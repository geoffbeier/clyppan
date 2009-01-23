//
//  OMHPreferenceController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/9/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import <ShortcutRecorder/ShortcutRecorder.h>


// Preference constants
extern NSString *OMHActivateAppKey;
extern NSString *OMHActivateAppModifierKey;
extern NSString *OMHRapidPasteKey;
extern NSString *OMHRapidPasteModifierKey;
extern NSString *OMHClippingPurgeLimitKey;
extern NSString *OMHAppHasLaunchedBeforeKey;

// Shortcut identifier constants.
extern NSString *OMHShortcutActivateAppId;
extern NSString *OMHShortcutRapidPasteId;


@interface OMHPreferenceController : DBPrefsWindowController
{
    IBOutlet NSView *generalPrefsView;
    IBOutlet NSView *shortcutsPrefView;
    IBOutlet NSView *updatePrefView;
    
    IBOutlet SRRecorderControl *activateControl;
    IBOutlet SRRecorderControl *rapidPasteControl;
    
    id delegate;
}

// Properties
@property( nonatomic, assign ) id delegate;

// Class methods
+ (OMHPreferenceController *) sharedWindowController;

// Methods
- (void) loadHotKeyFromUserDefaults;
- (void) tellDelegateShortcutDidChange:(NSString *)shortcutId keyCombo:(KeyCombo)keyCombo;

@end
