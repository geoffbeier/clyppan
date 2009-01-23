//
//  OMHPreferenceController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/9/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import "OMHPreferenceController.h"


// Preference constants
NSString *OMHActivateAppKey = @"activateKey";
NSString *OMHActivateAppModifierKey = @"activateModifier";
NSString *OMHRapidPasteKey = @"rapidPasteKey";
NSString *OMHRapidPasteModifierKey = @"rapidPasteModifier";
NSString *OMHClippingPurgeLimitKey = @"clippingPurgeLimit";
NSString *OMHAppHasLaunchedBeforeKey = @"hasLaunchedBefore";

// Shortcut identifier constants.
NSString *OMHShortcutActivateAppId = @"OMHActivateApp";
NSString *OMHShortcutRapidPasteId = @"OHMRapidPaste";

static OMHPreferenceController *_sharedPrefsWindowController = nil;


@implementation OMHPreferenceController


@synthesize delegate;


+ (OMHPreferenceController *) sharedWindowController
{
	if ( !_sharedPrefsWindowController ) 
    {
		_sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}

	return _sharedPrefsWindowController;
}


#pragma mark -
#pragma mark Overriding Methods

- (id) initWithWindow:(NSWindow *)window
{
    id obj = [super initWithWindow:window];
    [obj setAnimationDuration:0.15];
    
    return obj;
}

- (void) setupToolbar
{
    [self addView:generalPrefsView label:@"General" image:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
    [self addView:shortcutsPrefView label:@"Shortcuts" image:[NSImage imageNamed:@"Shortcuts"]];
    [self addView:updatePrefView label:@"Update" image:[NSImage imageNamed:@"Update"]];
}

- (IBAction) showWindow:(id)sender 
{
    [super showWindow:sender];
    
    [activateControl setDelegate:self];
    [rapidPasteControl setDelegate:self];
    
    [self loadHotKeyFromUserDefaults];
}


#pragma mark -
#pragma mark Keyboard Shortcut Preference Methods

/*!
 * Loads global activation hot key from user defaults.
 *
 * The global activation hot key will be loaded from user defaults,
 * registered using the OMHHotKey class and the hot key recorder controller
 * in the preference pane will be updated with the hot key.
 */
- (void) loadHotKeyFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    signed short activateKey = [[defaults objectForKey:OMHActivateAppKey] shortValue];
    unsigned int activateModifier = [[defaults objectForKey:OMHActivateAppModifierKey] unsignedIntValue];
    KeyCombo keyCombo = SRMakeKeyCombo( activateKey, SRCarbonToCocoaFlags( activateModifier ) );
    [activateControl setKeyCombo:keyCombo];

    signed short rapidPasteKey = [[defaults objectForKey:OMHRapidPasteKey] shortValue];
    unsigned int rapidPasteModifier = [[defaults objectForKey:OMHRapidPasteModifierKey] unsignedIntValue];    
    keyCombo = SRMakeKeyCombo( rapidPasteKey, SRCarbonToCocoaFlags( rapidPasteModifier ) );
    [rapidPasteControl setKeyCombo:keyCombo]; 
    
    [self tellDelegateShortcutDidChange:OMHShortcutActivateAppId keyCombo:SRMakeKeyCombo( activateKey, activateModifier )];
    [self tellDelegateShortcutDidChange:OMHShortcutRapidPasteId keyCombo:SRMakeKeyCombo( rapidPasteKey, rapidPasteModifier )];
}

- (void) shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)keyCombo
{
    keyCombo.flags = SRCocoaToCarbonFlags( keyCombo.flags );
    
    if ( recorder == activateControl )
    {        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithShort:keyCombo.code] forKey:OMHActivateAppKey];
        [defaults setObject:[NSNumber numberWithUnsignedInt:keyCombo.flags] forKey:OMHActivateAppModifierKey];        

        [self tellDelegateShortcutDidChange:OMHShortcutRapidPasteId keyCombo:keyCombo];
    }
    else if ( recorder == rapidPasteControl )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithShort:keyCombo.code] forKey:OMHRapidPasteKey];
        [defaults setObject:[NSNumber numberWithUnsignedInt:keyCombo.flags] forKey:OMHRapidPasteModifierKey];                

        [self tellDelegateShortcutDidChange:OMHShortcutRapidPasteId keyCombo:keyCombo];
    }
}

/*
 * Notifies the delegate that a shortcut has been changed
 */
- (void) tellDelegateShortcutDidChange:(NSString *)shortcutId keyCombo:(KeyCombo)keyCombo;
{
    if ( [self.delegate respondsToSelector:@selector( shortcutDidChange:keyCombo: )] )
    {
        NSValue *value = [NSValue value:&keyCombo withObjCType:@encode( KeyCombo )];
        [self.delegate performSelector:@selector( shortcutDidChange:keyCombo: ) 
                            withObject:shortcutId 
                            withObject:value];
    }
}

@end
