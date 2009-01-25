//
//  OMHClipping.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OMHClipping: NSManagedObject 
{
}

@property( nonatomic, retain ) NSString *title;
@property( nonatomic, retain ) NSString *plainContent;
@property( nonatomic, retain ) NSString *contentType;
@property( nonatomic, retain ) NSString *createdFromApp;
@property( nonatomic, retain ) NSAttributedString *content;
@property( nonatomic, assign ) NSDate *lastUsed;
@property( nonatomic, assign ) NSDate *created;
@property( nonatomic, assign ) NSNumber *isCurrent;
@property( nonatomic, readonly ) NSImage *image;
@property( nonatomic, readonly ) NSString *meta;

@end