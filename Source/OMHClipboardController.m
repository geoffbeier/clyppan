/**
 * @file OMHClipboardController.m
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

#import "OMHClipboardController.h"

const float PasteboardPullInterval = 0.45;
static OMHClipboardController *_OMHClipboardController = nil;

@implementation OMHClipboardController


@synthesize delegate;


#pragma mark -
#pragma mark Class Methods

+ (OMHClipboardController *)sharedController
{
	if ( !_OMHClipboardController ) 
    {
		_OMHClipboardController = [[self alloc] init];
	}
	return _OMHClipboardController;
}


#pragma mark -
#pragma mark Instance Methods

- (id) init
{
    if ( ![super init] )
        return nil;
    
    previousChangeCount = 0;        

    return self;
}

- (void) createTimer;
{
	if ( timer )
		[timer invalidate];
    
	timer = [NSTimer scheduledTimerWithTimeInterval:PasteboardPullInterval
											 target:self 
										   selector:@selector( timerFired: )
										   userInfo:nil 
											repeats:YES];
}

@end


#pragma mark -
#pragma mark Private implementation
#pragma mark -


@interface OMHClipboardController (private)

- (void) timerFired:(NSTimer *)timer;
- (BOOL) pasteboardHasChanged:(NSPasteboard *)pboard;

@end


@implementation OMHClipboardController (private)

- (void) timerFired:(NSTimer *)timer;
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    if ( ![self pasteboardHasChanged:pboard] )
        return;
    
    id string = nil;

    NSArray *supportedTypes = [NSArray arrayWithObjects: NSRTFPboardType, NSStringPboardType, nil];
    NSString *bestType = [[NSPasteboard generalPasteboard] availableTypeFromArray:supportedTypes];    
    
    if ( [bestType isEqualToString:NSRTFPboardType] )
    {
        NSData *data = [pboard dataForType:NSRTFPboardType];
        string = [[NSAttributedString alloc] initWithRTF:data documentAttributes:NULL];
    }    
    else if ( [bestType isEqualToString:NSStringPboardType] )
    {
        string = [pboard stringForType:NSStringPboardType];
    }
    
    if ( string != nil && [delegate respondsToSelector:@selector( pasteboardUpdated: )] )
    {
        [delegate performSelector:@selector( pasteboardUpdated: ) withObject:string];
    }
}

- (BOOL) pasteboardHasChanged:(NSPasteboard *)pboard
{
    int changeCount = [pboard changeCount];
    if ( changeCount <= previousChangeCount )
        return NO;
    
    previousChangeCount = changeCount;    
    return YES;
}

@end
