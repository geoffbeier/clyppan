//
//  OMHPreferenceController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/9/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import "OMHPreferenceController.h"

NSString *ShortcutActivateAppId = @"OMHActivateApp";
NSString *ShortcutRapidPasteId = @"OHMRapidPaste";

static OMHPreferenceController *_sharedPrefsWindowController = nil;

@implementation OMHPreferenceController

@synthesize delegate;

+ (void) initialize;
{
	// Set default values for preferences
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Register Ctrl+Command+C as the default short cut
    [defaultValues setObject:[NSNumber numberWithShort:8] forKey:@"activateKey"];
    [defaultValues setObject:[NSNumber numberWithUnsignedInt:768] forKey:@"activateModifier"];

    // Register Shift+Command+V as the default short cut
    [defaultValues setObject:[NSNumber numberWithShort:9] forKey:@"rapidPasteKey"];
    [defaultValues setObject:[NSNumber numberWithUnsignedInt:768] forKey:@"rapidPasteModifier"];

    // Set default limit for when to purge old clippings
    [defaultValues setObject:[NSNumber numberWithInt:500] forKey:@"clippingPurgeLimit"];
        
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

+ (OMHPreferenceController *) sharedPrefsWindowController
{
	if (!_sharedPrefsWindowController) {
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
    
    signed short activateKey = [[defaults objectForKey:@"activateKey"] shortValue];
    unsigned int activateModifier = [[defaults objectForKey:@"activateModifier"] unsignedIntValue];
    KeyCombo keyCombo = SRMakeKeyCombo( activateKey, SRCarbonToCocoaFlags( activateModifier ) );
    [activateControl setKeyCombo:keyCombo];
    
    signed short rapidPasteKey = [[defaults objectForKey:@"rapidPasteKey"] shortValue];
    unsigned int rapidPasteModifier = [[defaults objectForKey:@"rapidPasteModifier"] unsignedIntValue];    
    keyCombo = SRMakeKeyCombo( rapidPasteKey, SRCarbonToCocoaFlags( rapidPasteModifier ) );
    [rapidPasteControl setKeyCombo:keyCombo]; 
    
    [self tellDelegateShortcutDidChange:ShortcutActivateAppId keyCombo:SRMakeKeyCombo( activateKey, activateModifier )];
    [self tellDelegateShortcutDidChange:ShortcutRapidPasteId keyCombo:SRMakeKeyCombo( rapidPasteKey, rapidPasteModifier )];
}

- (void) shortcutRecorder:(SRRecorderControl *)recorder keyComboDidChange:(KeyCombo)keyCombo
{
    keyCombo.flags = SRCocoaToCarbonFlags( keyCombo.flags );
    
    if ( recorder == activateControl )
    {        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithShort:keyCombo.code] forKey:@"activateKey"];
        [defaults setObject:[NSNumber numberWithUnsignedInt:keyCombo.flags] forKey:@"activateModifier"];        

        [self tellDelegateShortcutDidChange:ShortcutActivateAppId keyCombo:keyCombo];
    }
    else if ( recorder == rapidPasteControl )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithShort:keyCombo.code] forKey:@"rapidPasteKey"];
        [defaults setObject:[NSNumber numberWithUnsignedInt:keyCombo.flags] forKey:@"rapidPasteModifier"];                
        
        [self tellDelegateShortcutDidChange:ShortcutRapidPasteId keyCombo:keyCombo];
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
