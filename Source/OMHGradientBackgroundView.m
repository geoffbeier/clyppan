/**
 * @file OMHGradientBackgroundView.m
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


#import "OMHGradientBackgroundView.h"

@implementation OMHGradientBackgroundView

- (void)drawRect:(NSRect)rect 
{
    rect = [self bounds];
    
    NSColor *color;
    NSGradient *gradient;
    if ( [self.window isKeyWindow] )
    {
        color = [NSColor colorWithCalibratedRed:88 / 255.00
                                          green:90 / 255.00
                                           blue:90 / 255.00
                                          alpha:1];
        gradient = [[NSGradient alloc] initWithStartingColor:[color shadowWithLevel:0.2]
                                                 endingColor:[color highlightWithLevel:0.1]];

    }
    else
    {
        color = [NSColor colorWithCalibratedRed:160 / 255.00
                                          green:160 / 255.00
                                           blue:160 / 255.00
                                          alpha:1];
        gradient = [[NSGradient alloc] initWithStartingColor:[color shadowWithLevel:0.215]
                                                 endingColor:[color highlightWithLevel:0.1]];
    }

    [gradient drawInRect:rect angle:90];

    // Draw the bottom border
    [[color shadowWithLevel:0.6] set];
    rect.size.height = 1;
    [[NSBezierPath bezierPathWithRect:rect] fill];
}

@end
