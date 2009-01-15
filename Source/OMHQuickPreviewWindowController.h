//
//  OMHQuickPreviewWindowController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 1/12/09.
//  Copyright 2009 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OMHQuickPreviewWindowController: NSWindowController 
{
}


// Class methods
+ (OMHQuickPreviewWindowController *)sharedWindowController;
+ (NSString *) nibName;

// Actions
- (IBAction) toogleQuickPreviewWindow:(id)sender;


@end
