/**
 * @file OMHStatusItemWindowController.m
 * @author Ole Morten Halvorsen
 *
 * @section LICENSE
 * Copyright (c) 2009, Ole Morten Halvorsen
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list 
 *   of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *   of conditions and the following disclaimer in the documentation and/or other materials 
 *   provided with the distribution.
 * - Neither the name of Clyppan nor the names of its contributors may be used to endorse or 
 *   promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
 * THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "OMHStatusItemWindowController.h"
#import "MAAttachedWindow.h"

// Holds shared singleton instance
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

/**
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
