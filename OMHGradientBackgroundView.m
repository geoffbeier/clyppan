/*
 *  OMHGradientBackgroundView.m
 *  Clyppan
 *
 *  Created by Ole Morten Halvorsen on 4/10/09.
 *  Copyright 2009 omh.cc. All rights reserved.
*/

#import "OMHGradientBackgroundView.h"


@implementation OMHGradientBackgroundView

- (void)drawRect:(NSRect)rect {
    rect = [self bounds];
    NSColor *color = [NSColor colorWithCalibratedRed:144 / 255.00 
                                               green:148 / 255.00 
                                                blue:154 / 255.00 
                                               alpha:1];

    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[color shadowWithLevel:0.4]
                                                         endingColor:[color shadowWithLevel:0.2]];
    
    [gradient drawInRect:rect angle:90];
    
    [[color shadowWithLevel:0.6] set];
    rect.size.height = 1;
    [[NSBezierPath bezierPathWithRect:rect] fill];    
}

@end
