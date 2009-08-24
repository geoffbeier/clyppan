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

    @protected
        NSTimer *updateMetaTimer;
}


#pragma mark -
#pragma mark Properties

/**
 * Holds the clipping that's currentlty on the clipboard
 */
@property( nonatomic, assign ) OMHClipping *currentActiveItem;

/**
 * How many items to hold in the clipping list
 */
@property( nonatomic, assign ) int clippingPurgeLimit;


#pragma mark -
#pragma mark Actions

/**
 * Removes an object from the clipping list
 */
- (IBAction) removeObject:(id)sender;

/**
 * Removes all objects from the clipping list
 */
- (IBAction) removeAllObjects:(id)sender;

/**
 * Marks the first selected object as current
 */
- (IBAction) markAsCurrent:(id)sender;


#pragma mark -
#pragma mark Instance methods

/**
 * Creates and returns a new clipping object.
 *
 * The create clipping object is not added to the arrangedObjects.
 * 
 * @param content NSAttributedString 
 */
- (id) createObject:(NSAttributedString *)content;

/**
 * Returns an object with content matching the content parameter.
 *
 * @param content Instance of NSAttributedString that contains the clipbarod content.
 */
- (id) objectWithContent:(NSAttributedString *)content;

/**
 * Adds a new clipping
 *
 * A check for duplicates is performed before adding anything. If
 * a duplicate is found it will be marked as the current clipping.
 *
 * @param newContent id Either a NSAttributedString or NSString object that
 contains the clipboard contents.
 */
- (void) addObjectWithContent:(id)newContent;

/**
 * Makes sure [self arrangedObjects] only contains as many objects as specified by the
 * limit parameter
 *
 * @param limit int Maximum number of items to allow in the clipping array.
 */
- (void) purgeUntilCountIs:(int)limit;

/**
 * Removes all clippings from the arrangedObject array
 */
- (void) removeAllObjects;

/**
 * Marks the clipping at 'row' as current.
 *￼
 * @param row The index of the object that should be marked.
 */
- (void) markObjectAsSelectedOnRow:(NSNumber *)row;

/**
 * Marks a clipping object as current and put its content on the clipboard
 *
 * @param object OMHClipping The object to mark and put on the clipboard
 */
- (void) markObjectAsCurrent:(OMHClipping *)object;

/**
 * Marks a clipping object as current but does not put it on the clipboard.
 *
 * @param object OMHClipping The object to mark as current
 */
- (void) markObjectAsCurrentWithoutClipboard:(OMHClipping *)object;

/**
 * Peforms a Rapid Paste
 *
 * Rapid Paste takes the current item and changes the last used date to make it 
 * jump down the bottom of the list. The next item in the list will be promoted 
 * to the current item.
 */
- (void) rapidPaste;

/**
 * ￼Sets the default sorting which is sort by 'current' then 'lastUsed'
 */
- (void) setSorting;

- (void) createMetaUpdateTimer;
- (void) updateMetaDataTimer;

@end
