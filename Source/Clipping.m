//
//  Clipping.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 4/3/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import "Clipping.h"


@implementation Clipping


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
#pragma mark Instance Methods

- (NSString *) titleFromContent:(NSAttributedString *)newContent;
{
    NSString *newTitle = [[newContent string] copy];
    NSString *newlineReplacementString = @"⏎ ";
        
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

- (NSImage *) image
{
    if ( [self.isCurrent boolValue] )
    {
        NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize( 64, 64 )];
        NSImage *cachedImage = [[NSWorkspace sharedWorkspace] iconForFileType:@".textClipping"];
        NSImage *stamp = [NSImage imageNamed:@"Stamp"];
        
        [newImage lockFocus];
        
        [cachedImage drawInRect:NSMakeRect( 0, 0, newImage.size.width, newImage.size.height ) 
                       fromRect:NSMakeRect( 0, 0, cachedImage.size.width, cachedImage.size.height ) 
                       operation:NSCompositeSourceOver 
                       fraction:1];

        [stamp drawInRect:NSMakeRect( 13, 13, newImage.size.width / 1.70, newImage.size.height / 1.70 ) 
                 fromRect:NSMakeRect( 0, 0, stamp.size.width, stamp.size.height ) 
                operation:NSCompositeSourceOver 
                 fraction:1];
        
        [newImage unlockFocus];
        return newImage;
    }

    return [[NSWorkspace sharedWorkspace] iconForFileType:@".textClipping"];
}

- (NSString *) meta
{
    NSString *dateString = [self.created descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" 
                                                   timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];

    return [NSString stringWithFormat:@"Added on %@ from %@", dateString, self.createdFromApp];   
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
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