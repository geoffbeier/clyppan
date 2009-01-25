//
//  OMHClippingController.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

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

/*!
 * Puts new content inserted on the pastboard into the clipping list
 *
 * OMHClippingController delegate method.
 */
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

/*!
 * Creates and returns a new clipping object
 */
- (id) createObject:(NSAttributedString *)content;
{
    // Create new object and add it
    id object = [super newObject];
    [object setValue:content forKey:@"content"];
    
    return object;
}

/*!
 * Adds a new clipping
 *
 * A check for duplicates is performed before adding anything. If
 * a duplicate is found it will be marked as the current clipping.
 */
- (void) addObjectWithContent:(id)newContent;
{  
    NSAttributedString *content;
    NSString *type = NSStringPboardType;
    
    if ( [newContent isKindOfClass:[NSAttributedString class]] )
    {
        content = newContent;
        type = NSRTFPboardType;
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
    [object setContentType:type];
    [self addObject:object];
    [self markObjectAsCurrentWithoutClipboard:object];
}

/*!
 * Makes sure [self arrangedObjects] only contains as many objects as specified by the
 * limit parameter
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

/*!
 * Returns an object with content matching the content parameter.
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

/*!
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

/*!
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

- (void) remove:(id)sender
{
    if ( [[self selectedObjects] objectAtIndex:0] == self.currentActiveItem )
        if ( [[self arrangedObjects] count] >= 2 )
            [self markObjectAsSelectedOnRow:[NSNumber numberWithInt:1]];
    
    [super remove:sender];
}

/*!
 * Removes all clippings from the array
 */
- (void) removeAllObjects;
{
    int count = [[self arrangedObjects] count];
    
    // We make a range starting from 1 to not remove the first (current) item
    NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, count - 1)];
    [self removeObjectsAtArrangedObjectIndexes:set];    
}

/*!
 * Ask the user if it's ok to remove a object
 */
- (IBAction) removeObject:(id)sender;
{
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


/*!
 * Ask the user if it's ok to remove all objects
 */
- (IBAction) removeAllObjects:(id)sender;
{
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

- (void) alertRemoveObjectDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if ( returnCode == NSAlertFirstButtonReturn ) 
    {
        [self remove:self];
    }
}

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

/*!
 * Marks the clipping at 'row' as current.
 *￼
 * @param ￼row The index of the object that should be marked.
 */
- (void) markObjectAsSelectedOnRow:(NSNumber *)row
{
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
    if ( [object.isCurrent boolValue] == YES )
        return;
    
    if ( self.currentActiveItem == nil )
        if ( [[self arrangedObjects] count] >= 1 )
            self.currentActiveItem = [[self arrangedObjects] objectAtIndex:0];
    
    object.isCurrent = [NSNumber numberWithBool:YES];
    object.lastUsed = [NSDate date];
    
    self.currentActiveItem.isCurrent = [NSNumber numberWithBool:NO];
    self.currentActiveItem = object;
    
    [self setSorting];
    [self setSelectedObjects:[NSArray arrayWithObject:object]];    
}

@end