/**
 * @file OMHClippingsTableView.m
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

#import "OMHClippingsTableView.h"


@implementation OMHClippingsTableView


#pragma mark -
#pragma mark Initialization and Setup
- (void) awakeFromNib
{
    // Set interspacing between cells
    [self setIntercellSpacing:NSMakeSize(0, 0)];

    // Create custom image and text cell
    cell = [[OMHImageTextCell alloc] init];
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
        [self.delegate performSelector:@selector( markObjectAsSelectedOnRow: ) 
                            withObject:[NSNumber numberWithInt:[self selectedRow]]];
        return;
    }    
    
    // If key == Enter or Return.
    if (  key == NSEnterCharacter || key == NSCarriageReturnCharacter )
    {
        [self.delegate performSelector:@selector( markObjectAsSelectedOnRow: ) 
                            withObject:[NSNumber numberWithInt:[self selectedRow]]];
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
        [self.delegate performSelector:@selector( markObjectAsSelectedOnRow: ) 
                            withObject:[NSNumber numberWithInt:[self selectedRow]]];
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
