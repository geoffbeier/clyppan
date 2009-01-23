//
//  OMHStatusItemWindowController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/17/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MAAttachedWindow.h"

@interface OMHStatusItemWindowController: NSWindowController 
{
    MAAttachedWindow *statusItemHelperWindow;
    IBOutlet NSView *statusItemHelperView;
}

+ (NSString *) nibName;
+ (OMHStatusItemWindowController *) sharedWindowController;

@end
