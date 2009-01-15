//
//  OMHClipboardController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import "OMHClipboardController.h"


const float PasteboardPullInterval = 0.5;
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
    [super init];
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

@end


@implementation OMHClipboardController (private)

- (void) timerFired:(NSTimer *)timer;
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    int changeCount = [pboard changeCount];
    if ( changeCount <= previousChangeCount )
        return;
    
    previousChangeCount = changeCount;
    
    NSData *data = nil;
    NSAttributedString *string = nil;
    
    if ( [[pboard types] containsObject:NSRTFPboardType] ) 
    {
        data = [pboard dataForType:NSRTFPboardType];
        string = [[NSAttributedString alloc] initWithRTF:data documentAttributes:NULL];
    }    
    else if ( [[pboard types] containsObject:NSStringPboardType] ) 
    {
        NSString *stringFromPboard = [pboard stringForType:NSStringPboardType];
        string = [[NSAttributedString alloc] initWithString:stringFromPboard];
    }
    
    if ( string != nil && [delegate respondsToSelector:@selector( pasteboardUpdated: )] )
    {
        [delegate performSelector:@selector( pasteboardUpdated: ) withObject:string];
    }
}

@end

