//
//  OMHQuickPreviewWindowController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/12/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import "OMHQuickPreviewWindowController.h"


static OMHQuickPreviewWindowController *_sharedOMHQuickPreviewWindowController = nil;


@implementation OMHQuickPreviewWindowController


#pragma mark -
#pragma mark Class Methods

+ (OMHQuickPreviewWindowController *) sharedWindowController
{
	if ( !_sharedOMHQuickPreviewWindowController ) 
    {
		_sharedOMHQuickPreviewWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedOMHQuickPreviewWindowController;
}

+ (NSString *) nibName
{
    return @"QuickPreview";
}


#pragma mark -
#pragma mark Instance Methods

- (void) setWindow:(NSWindow *)aWindow
{
    if ( [aWindow isKindOfClass:[NSPanel class]] )
        // The cast to NSPanel is to avoid compile warning
        [(NSPanel *)aWindow setBecomesKeyOnlyIfNeeded:YES]; 

    [super setWindow:aWindow];
}


/*
 * Toogles the quick preview window
 */
- (IBAction) toogleQuickPreviewWindow:(id)sender;
{
    if ( self.window.isVisible )
    {
        [self.window performClose:self];
    }
    else
    {
        [self showWindow:sender];
    }
}
@end
