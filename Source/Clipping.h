//
//  Clipping.h
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Clipping: NSManagedObject 
{
}

@property( nonatomic, retain ) NSString *title;
@property( nonatomic, retain ) NSAttributedString *content;
@property( nonatomic, retain ) NSString *plainContent;
@property( nonatomic, readonly ) NSString *meta;
@property( nonatomic, retain ) NSString *createdFromApp;
@property( nonatomic, assign ) NSDate *lastUsed;
@property( nonatomic, assign ) NSDate *created;
@property( nonatomic, readonly ) NSImage *image;
@property( nonatomic, assign ) NSNumber *isCurrent;

- (NSString *) titleFromContent:(NSAttributedString *)newContent;

@end