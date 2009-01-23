//
//  OMHStatusItemWindowController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/17/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import "OMHStatusItemWindowController.h"


static OMHStatusItemWindowController *_OMHStatusItemWindowController = nil;


@implementation OMHStatusItemWindowController

#pragma mark -
#pragma mark Class Methods

+ (OMHStatusItemWindowController *) sharedWindowController
{
	if ( !_OMHStatusItemWindowController ) 
    {
		_OMHStatusItemWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _OMHStatusItemWindowController;
}

+ (NSString *) nibName
{
    return @"StatusItemHelperWindow";
}


#pragma mark -
#pragma mark Instance Methods

/*
 * Create helper window
 *
 * What we're doing here is to create a status bar item, give it
 * an empty view, grab the cordinates and destorying it again. This is 
 * the quickest way I've found to actually figure out the position of 
 * a status bar item without using hacks.
 *
 * This method should be called right before the actual status item is created.
 */ 
- (void) windowDidLoad
{
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:13];
    NSRect viewFrame = NSMakeRect(0.0, 2.0, [statusItem length], [[statusItem statusBar] thickness]);
    [statusItem setView:[[NSView alloc] initWithFrame:viewFrame]];        
    NSPoint point = NSMakePoint( statusItem.view.window.frame.origin.x, statusItem.view.window.frame.origin.y ); 
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    
    statusItemHelperWindow = [[MAAttachedWindow alloc] initWithView:statusItemHelperView
                                                    attachedToPoint:point
                                                           inWindow:nil 
                                                             onSide:MAPositionBottom 
                                                         atDistance:[[statusItem statusBar] thickness] + 3];
    
    [statusItemHelperWindow makeKeyAndOrderFront:self];
    
    [self setWindow:statusItemHelperWindow];
}

@end
