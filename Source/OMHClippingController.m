/**
 * @file OMHClippingController.m
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


#import "OMHClippingController.h"
#import "OMHClipboardController.h"
#import "OMHClipping.h"


@implementation OMHClippingController

@synthesize currentActiveItem;
@synthesize clippingPurgeLimit;

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self setSorting];
    
    // Register for updates from the clipboard controller
    [[OMHClipboardController sharedController] setDelegate:self];
}

/**
 * Puts new content inserted on the pastboard into the clipping list
 *
 * OMHClippingController delegate method.
 *
 * @param newContent id Object containing the new clipboard content
 */
- (void) pasteboardUpdated:(id)newContent
{
    [self addObjectWithContent:newContent];
}

/**
 * Adds a new object to the arrangedObject array.
 *
 * @param object id The object to add
 */
- (void) addObject:(id)object
{
    [super addObject:object];
    if ( [[self arrangedObjects] count] > clippingPurgeLimit )
    {
        [self purgeUntilCountIs:clippingPurgeLimit];
    }
}

/**
 * Creates and returns a new clipping object.
 *
 * The create clipping object is not added to the arrangedObjects.
 * 
 * @param content NSAttributedString 
 */
- (id) createObject:(NSAttributedString *)content;
{
    // Create new object and add it
    id object = [super newObject];
    [object setValue:content forKey:@"content"];
    
    return object;
}

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
{  
    NSAttributedString *content;
    
    if ( [newContent isKindOfClass:[NSAttributedString class]] )
    {
        content = newContent;
    }
    else if ( [newContent isKindOfClass:[NSString class]] )
    {
        content = [[NSAttributedString alloc] initWithString:newContent];
    }
    else
    {
        NSLog( @"The new clipboard content wasn't a NSAttributedString" ); 
        return;
    }
        
    // Check if existing object exists...
    OMHClipping *existingObject = [self objectWithContent:content];
    if ( existingObject != nil )
    {
        [self markObjectAsCurrentWithoutClipboard:existingObject];        
        return;
    }
    
    // Create new object and add it
    id object = [self createObject:content];
    [self addObject:object];
    [self markObjectAsCurrentWithoutClipboard:object];
}

/**
 * Makes sure [self arrangedObjects] only contains as many objects as specified by the
 * limit parameter
 *
 * @param limit int Maximum number of items to allow in the clipping array.
 */
- (void) purgeUntilCountIs:(int)limit
{
    if ( limit <= 0 )
        return;
    
    // Make sure sorting is correct since we'll be removing items from the 
    // bottom and up making the sorting very critical.
    [self setSorting];  
    int count = [[self content] count];
    while ( count > limit )
    {
        [self removeObjectAtArrangedObjectIndex:count - 1];
        count = [[self content] count];
    }
}

/**
 * Returns an object with content matching the content parameter.
 *
 * @param content Instance of NSAttributedString that contains the clipbarod content.
 */
- (id) objectWithContent:(NSAttributedString *)content;
{
    NSArray *objects = [self arrangedObjects];
    for ( OMHClipping *object in objects )
    {
        if ( [[object.content string] isEqualToString:[content string]] )
        {
            return object;
        }
    }
    
    return nil;
}

/**
 * ￼Sets the default sorting which is sort by 'current' then 'lastUsed'
 */
- (void) setSorting;
{
    NSSortDescriptor *current = [[NSSortDescriptor alloc] initWithKey:@"current" 
                                                            ascending:NO];
    
    NSSortDescriptor *lastUsed = [[NSSortDescriptor alloc] initWithKey:@"lastUsed.timeIntervalSince1970" 
                                                             ascending:NO];
    
    [self setSortDescriptors:[NSArray arrayWithObjects:current, lastUsed, nil]];
}

/**
 * Peforms a Rapid Paste
 *
 * Rapid Paste takes the current item and changes the last used date to make it 
 * jump down the bottom of the list. The next item in the list will be promoted 
 * to the current item.
 */
- (void) rapidPaste;
{
    OMHClipping *object = self.currentActiveItem;
    [self markObjectAsSelectedOnRow:[NSNumber numberWithInt:1]];

    // Make timeIntervalSince1970 negative so the clipping will end up at the bottom
    NSTimeInterval interval = -fabs( [[NSDate date] timeIntervalSince1970] );
    object.lastUsed = [NSDate dateWithTimeIntervalSince1970:interval];
    [self setSelectionIndex:0];
    [self setSorting];
}


/**
 * Removes the first selected clipping
 *
 * If the selected clipping is also the clipping on the clipboard the clipping
 * next in the list will be marked as the current and put on the clipboard.
 *
 * @param sender id The caller of this method
 */
- (void) remove:(id)sender
{
    if ( [[self selectedObjects] objectAtIndex:0] == self.currentActiveItem )
        if ( [[self arrangedObjects] count] >= 2 )
            [self markObjectAsSelectedOnRow:[NSNumber numberWithInt:1]];
    
    [super remove:sender];
}

/**
 * Removes all clippings from the arrangedObject array
 */
- (void) removeAllObjects;
{
    int count = [[self arrangedObjects] count];
    
    // We make a range starting from 1 to not remove the first (current) item
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, count - 1)];
    [self removeObjectsAtArrangedObjectIndexes:set];    
}

/**
 * Asks the user if it's ok to remove a object
 */
- (IBAction) removeObject:(id)sender;
{
    if ( [[self arrangedObjects] count] <= 1 )
    {
        NSBeep();
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Remove"];
    [alert addButtonWithTitle:@"Don't Remove"];
    [alert setMessageText:@"Are you sure you want to remove the selected clipping?"];
    [alert setInformativeText:@"This action cannot be undone."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    
    [alert beginSheetModalForWindow:[[NSApp delegate] mainWindow]
                      modalDelegate:self 
                     didEndSelector:@selector( alertRemoveObjectDidEnd:returnCode:contextInfo: ) 
                        contextInfo:nil];
}


/**
 * Asks the user if it's ok to remove all objects
 *
 * @param sender id Caller of the method
 */
- (IBAction) removeAllObjects:(id)sender;
{
    if ( [[self selectedObjects] count] <= 0 )
    {
        NSBeep();
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Remove"];
    [alert addButtonWithTitle:@"Don't Remove"];
    [alert setMessageText:@"Are you sure you want to remove all clippings?"];
    [alert setInformativeText:@"This action cannot be undone."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    
    [alert beginSheetModalForWindow:[[NSApp delegate] mainWindow]
                      modalDelegate:self 
                     didEndSelector:@selector( alertRemoveAllDidEnd:returnCode:contextInfo: ) 
                        contextInfo:nil];
}

/**
 * Removes the first selected clipping object if the user agreed to it in the alert.
 *
 * @param alert Instance of NSAlert
 * @param returnCode int The return code
 * @param contextInfo void* Context Info
 */
- (void) alertRemoveObjectDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if ( returnCode == NSAlertFirstButtonReturn ) 
    {
        [self remove:self];
    }
}

/**
 * Removes all clipping objects if the user agreed to it in the alert.
 *
 * @param alert Instance of NSAlert
 * @param returnCode int The return code
 * @param contextInfo void* Context Info
 */
- (void) alertRemoveAllDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if ( returnCode == NSAlertFirstButtonReturn ) 
    {
        [self removeAllObjects];
    }
}

/**
 * Puts and marks the first selected object as the current clipboard object.
 *
 * @param sender id the caller of this method
 */
- (IBAction) markAsCurrent:(id)sender;
{
    [self markObjectAsCurrent:[[self selectedObjects] objectAtIndex:0]];
}

/**
 * Marks the clipping at 'row' as current.
 *￼
 * @param row The index of the object that should be marked.
 */
- (void) markObjectAsSelectedOnRow:(NSNumber *)row
{
    if ( [row intValue] < 0 || [row intValue] > [[self arrangedObjects] count] )
        return;
    
    OMHClipping *object = [[self arrangedObjects] objectAtIndex:[row intValue]];    
    [self markObjectAsCurrent:object];
    [self setSelectionIndex:[row intValue]];
}

/**
 * Marks a clipping object as current and put its content on the clipboard
 *
 * @param object OMHClipping The object to mark and put on the clipboard
 */
- (void) markObjectAsCurrent:(OMHClipping *)object;
{
    [self markObjectAsCurrentWithoutClipboard:object];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pb setString:[self.currentActiveItem.content string] forType:NSStringPboardType];    
    
    NSRange range = NSMakeRange( 0, [self.currentActiveItem.content length] );
    NSData *data = [self.currentActiveItem.content RTFFromRange:range documentAttributes:nil];
    [pb declareTypes:[NSArray arrayWithObject:NSRTFPboardType] owner:nil];
    [pb setData:data forType:NSRTFPboardType];
}

/**
 * Marks a clipping object as current but does not put it on the clipboard.
 *
 * @param object OMHClipping The object to mark as current
 */
- (void) markObjectAsCurrentWithoutClipboard:(OMHClipping *)object;
{
    if ( self.currentActiveItem == nil )
        if ( [[self arrangedObjects] count] >= 1 )
            self.currentActiveItem = [[self arrangedObjects] objectAtIndex:0];
    
    object.isCurrent = [NSNumber numberWithBool:YES];
    object.lastUsed = [NSDate date];
    
    self.currentActiveItem.isCurrent = [NSNumber numberWithBool:NO];
    self.currentActiveItem = object;
    
    [self setSorting];
}

@end