/**
 * @file OMHClipping.m
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


#import "OMHClipping.h"


@interface OMHClipping( private )

- (NSString *) titleFromContent:(NSAttributedString *)newContent;

@end


@implementation OMHClipping( private )

- (NSString *) titleFromContent:(NSAttributedString *)newContent;
{
    NSString *newTitle = [[newContent string] copy];
    NSString *newlineReplacementString = @"↩ ";
    
    // Replace newlines/tabs
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\n" withString:newlineReplacementString];
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\r" withString:newlineReplacementString];
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\r\n" withString:newlineReplacementString];   
    newTitle = [newTitle stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    
    // Replace multiple spaces with single space
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    newTitle = [newTitle stringByTrimmingCharactersInSet:whitespace];
    
    // Replace all other known types of newlines
    unichar chrNEL[] = { 0x0085 }; // NEL: Next Line, U+0085
    unichar chrFF[] = { 0x000C }; // FF: Form Feed, U+000C
    unichar chrLS[] = { 0x2028 }; // LS: Line Separator, U+2028
    unichar chrPS[] = { 0x2029 }; // PS: Paragraph Separator, U+2029
    
    NSString *crString = [NSString stringWithCharacters:chrNEL length:1];    
    newTitle = [newTitle stringByReplacingOccurrencesOfString:crString withString:newlineReplacementString];
    
    crString = [NSString stringWithCharacters:chrFF length:1];    
    newTitle = [newTitle stringByReplacingOccurrencesOfString:crString withString:newlineReplacementString];
    
    crString = [NSString stringWithCharacters:chrLS length:1];    
    newTitle = [newTitle stringByReplacingOccurrencesOfString:crString withString:newlineReplacementString];
    
    crString = [NSString stringWithCharacters:chrPS length:1];    
    newTitle = [newTitle stringByReplacingOccurrencesOfString:crString withString:newlineReplacementString];   
    
    // Remove multiple spaces
    NSRange range = [newTitle rangeOfString:@"  " options:0];
    while ( range.length >= 2 )
    {
        newTitle = [newTitle stringByReplacingOccurrencesOfString:@"  " withString:@" "];        
        range = [newTitle rangeOfString:@"  " options:0];
    }
    
    // Shorten newTitle to max 350 chars.
    NSUInteger length = [newTitle length]; 
    if ( length > 350 )
        length = 350;
    
    return [newTitle substringToIndex:length];
}

@end


#pragma mark -

@implementation OMHClipping

@dynamic title;
@dynamic content;
@dynamic plainContent;
@dynamic meta;
@dynamic createdFromApp;
@dynamic lastUsed;
@dynamic created;
@dynamic isCurrent;

#pragma mark -
#pragma mark Initialization and Setup

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    
    self.lastUsed = [NSDate date];
    self.created = self.lastUsed;
    self.createdFromApp = [[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationName"];
    [self addObserver:self forKeyPath:@"content" options:0 context:NULL];
}

- (void) awakeFromFetch
{
    if ( self.content )
        self.title = [self titleFromContent:self.content];
    
    [self addObserver:self forKeyPath:@"content" options:0 context:NULL];    
}

#pragma mark -
#pragma mark Properties override methods

- (NSImage *) image
{
    return [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode( kClippingTextTypeIcon )];
}

- (NSString *) meta
{
    NSString *dateString = [self.created descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" 
                                                              timeZone:nil
                                                                locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    
    return [NSString stringWithFormat:@"Added on %@ from %@", dateString, self.createdFromApp];   
}

#pragma mark -
#pragma mark KVO methods

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ( [keyPath isEqualToString:@"content"] ) 
    {
        // If we're deleting a clipping this method will be called, but all 
        // the attributes will be nil.
        if ( self.content == nil )
            return;
        
        self.title = [self titleFromContent:self.content];
        self.plainContent = [self.content string];
    }
}

@end