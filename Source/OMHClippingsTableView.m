//
//  ClippingsTableView.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/7/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import "OMHClippingsTableView.h"
#import "AppController.h"

@implementation OMHClippingsTableView

#pragma mark -
#pragma mark Initialization and Setup
- (void) awakeFromNib
{
    // Set interspacing between cells
    [self setIntercellSpacing:NSMakeSize(0, 0)];

    // Create custom image and text cell
    cell = [[ImageTextCell alloc] init];
    [cell setPrimaryTextKeyPath: @"title"];
    [cell setSecondaryTextKeyPath: @"meta"];
    [cell setIconKeyPath: @"image"];
    [cell setHighlightCellKeyPath:@"isCurrent"];    

    NSTableColumn *column = [[self tableColumns] objectAtIndex:0];
    [column setDataCell:cell];
    
    // Avoid issue where there's a cap at the end of the cell. Even though it's 
    // set to auto resize the cell seem to be missing a couple of pixels on 
    // the right side when there's no scroll bar. This should take care of that.
    [column setWidth:self.bounds.size.width];    
}


#pragma mark -
#pragma mark Interface Actions

- (IBAction) scrollToCurrentItem:(id)sender
{
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    [self scrollRowToVisible:0];
}


#pragma mark -
#pragma mark Event Handling

- (void) keyDown:(NSEvent *)event
{
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
        
    if ( [self numberOfSelectedRows] == 0 )
    {
        [super keyDown:event];
        return;
    }
    
    // If key == Space.
    if ( key == 32 )        
    {		
        [[NSApp delegate] toogleQuickPreviewWindow:self];
		return;
    }
    
    // If key == Shift+Enter
    if ( key == NSCarriageReturnCharacter && [event modifierFlags] & NSShiftKeyMask )
    {
        [[self delegate] markObjectAsSelectedOnRow:[self selectedRow]];
        return;
    }    
    
    // If key == Enter or Return.
    if (  key == NSEnterCharacter || key == NSCarriageReturnCharacter )
    {
        [[self delegate] markObjectAsSelectedOnRow:[self selectedRow]];
        [[NSApplication sharedApplication] hide:self];
        return;
    }
    
    // If key == delete or backspace.
    if ( key == NSDeleteFunctionKey || key == NSDeleteCharacter )
    {
        [[self delegate] removeObject:self];
        return;
    }
    
    [super keyDown:event];
}

- (void) mouseDown:(NSEvent *)event
{  
    if ( [event clickCount] == 2 )
    {
        [[self delegate] markObjectAsSelectedOnRow:[self selectedRow]];
        return;
    }
    
    [super mouseDown:event];
}


#pragma mark -
#pragma mark Drawing

- (void) highlightSelectionInClipRect:(NSRect)rect;
{
    NSResponder *firstResponder = [[self window] firstResponder];
    if ( ![firstResponder isKindOfClass:[NSView class]] || ![(NSView *)firstResponder isDescendantOf:self] || ![[self window] isKeyWindow] ) 
    {
        [cell setTextColor:[NSColor blackColor]];
    }
    else
    {
        [cell setTextColor:[NSColor whiteColor]];
    }
    [super highlightSelectionInClipRect:rect];
}

@end
