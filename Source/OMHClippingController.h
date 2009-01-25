//
//  OMHClippingController.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class OMHClipping;


@interface OMHClippingController: NSArrayController 
{
    OMHClipping *currentActiveItem;    
    int clippingPurgeLimit;
}

// Properties
@property( nonatomic, assign ) OMHClipping *currentActiveItem;
@property( nonatomic, assign ) int clippingPurgeLimit;

// Interface Actions
- (IBAction) removeObject:(id)sender;
- (IBAction) removeAllObjects:(id)sender;
- (IBAction) markAsCurrent:(id)sender;

// Instance methods
- (id) createObject:(NSAttributedString *)content;
- (id) objectWithContent:(NSAttributedString *)content;
- (void) addObjectWithContent:(id)newContent;
- (void) purgeUntilCountIs:(int)limit;
- (void) removeAllObjects;

- (void) setSorting;
- (void) markObjectAsSelectedOnRow:(NSNumber *)row;
- (void) markObjectAsCurrent:(OMHClipping *)object;
- (void) markObjectAsCurrentWithoutClipboard:(OMHClipping *)object;
- (void) rapidPaste;


@end
