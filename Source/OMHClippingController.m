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

- (void) pasteboardUpdated:(id)newContent
{
    [self addObjectWithContent:newContent];
}

- (void) addObject:(id)object
{
    [super addObject:object];
    if ( [[self arrangedObjects] count] > clippingPurgeLimit )
    {
        [self purgeUntilCountIs:clippingPurgeLimit];
    }
}

- (id) createObject:(NSAttributedString *)content;
{
    id object = [super newObject];
    [object setValue:content forKey:@"content"];
    
    return object;
}

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
    [[AppController sharedAppController] flashStatusMenu];
}

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

- (void) setSorting;
{
    NSSortDescriptor *current = [[NSSortDescriptor alloc] initWithKey:@"current" 
                                                            ascending:NO];
    
    NSSortDescriptor *lastUsed = [[NSSortDescriptor alloc] initWithKey:@"lastUsed.timeIntervalSince1970" 
                                                             ascending:NO];
    
    [self setSortDescriptors:[NSArray arrayWithObjects:current, lastUsed, nil]];
}

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

- (void) remove:(id)sender
{
    if ( [[self selectedObjects] objectAtIndex:0] == self.currentActiveItem )
        if ( [[self arrangedObjects] count] >= 2 )
            [self markObjectAsSelectedOnRow:[NSNumber numberWithInt:1]];
    
    [super remove:sender];
}

- (void) removeAllObjects;
{
    int count = [[self arrangedObjects] count];
    
    // We make a range starting from 1 to not remove the first (current) item
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, count - 1)];
    [self removeObjectsAtArrangedObjectIndexes:set];    
}

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
 */
- (void) alertRemoveAllDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if ( returnCode == NSAlertFirstButtonReturn ) 
    {
        [self removeAllObjects];
    }
}

- (IBAction) markAsCurrent:(id)sender;
{
    [self markObjectAsCurrent:[[self selectedObjects] objectAtIndex:0]];
}

- (void) markObjectAsSelectedOnRow:(NSNumber *)row
{
    if ( [row intValue] < 0 || [row intValue] > [[self arrangedObjects] count] )
        return;
    
    OMHClipping *object = [[self arrangedObjects] objectAtIndex:[row intValue]];    
    [self markObjectAsCurrent:object];
    [self setSelectionIndex:[row intValue]];
}

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


- (void) markObjectAsCurrentWithoutClipboard:(OMHClipping *)object;
{
    if ( self.currentActiveItem == nil )
        if ( [[self arrangedObjects] count] >= 1 )
            self.currentActiveItem = [[self arrangedObjects] objectAtIndex:0];
    
    if ( self.currentActiveItem != object )
    {
        self.currentActiveItem.isCurrent = [NSNumber numberWithBool:NO];
        object.isCurrent = [NSNumber numberWithBool:YES];
        object.lastUsed = [NSDate date];
        self.currentActiveItem = object;        
    }
    else
    {
        object.isCurrent = [NSNumber numberWithBool:YES];
    }

    [self setSorting];        
}

@end