/**
 * @file OMHClippingController.h
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

#import <Cocoa/Cocoa.h>
#import "AppController.h"

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
