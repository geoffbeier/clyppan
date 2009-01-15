//
//  OMHMainWindow.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 5/18/08.
//  Copyright 2008 omh.cc. All rights reserved.
//

#import "OMHMainWindow.h"

@implementation OMHMainWindow

- (BOOL) performKeyEquivalent:(NSEvent *)event
{
    NSString *findKey = [event charactersIgnoringModifiers];
	
    // Command+alt+f?
    if ( [findKey isEqualTo:@"f"] && [event modifierFlags] & NSCommandKeyMask )
	{
        if ( [event modifierFlags] & NSAlternateKeyMask )
        {
            [searchField becomeFirstResponder];
            return YES;            
        }
	}

    return [super performKeyEquivalent:event];
}

@end
