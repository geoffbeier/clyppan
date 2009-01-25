//
//  OMHClippingsTableView.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/7/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "ImageTextCell.h"

//@class ImageTextCell;


@interface OMHClippingsTableView: NSTableView
{
    ImageTextCell *cell;
}

// Interface actions
- (IBAction) scrollToCurrentItem:(id)sender;


@end
