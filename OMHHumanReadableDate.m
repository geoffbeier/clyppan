/**
 * @file OMHHumanRedableDate.h
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

#import "OMHHumanReadableDate.h"


@implementation OMHHumanReadableDate

+ (NSString *) dateToHumanReadableString:(NSDate *)date
{
	return [self dateToHumanReadableString:date format:@"%i %@ ago"];
}

+ (NSString *) dateToHumanReadableString:(NSDate *)date format:(NSString *)format
{
    // TODO: Add X months ago
    NSTimeInterval secondsSinceNow = [[NSDate date] timeIntervalSinceDate:date];
    
    NSLog( @"Seconds: %f", secondsSinceNow );

    // if date less than a minute return "less than a minute ago"
    if ( secondsSinceNow < MINUTE_IN_SECONDS )
        return @"less than a minute ago";

    NSInteger timePart = 0;
    NSString *timeType = nil;
    if ( secondsSinceNow <= HOUR_IN_SECONDS )
    {
        timeType = @"minutes";
        timePart = (NSInteger) round( secondsSinceNow / 60 );
		if ( timePart == 1 )
			timeType = @"minute";
    }
    
    if ( secondsSinceNow <= DAY_IN_SECONDS && secondsSinceNow > HOUR_IN_SECONDS )
    {
        timeType = @"hours";
        timePart = (NSInteger) round( secondsSinceNow / 3600 );
		if ( timePart == 1 )
			timeType = @"hour";
    }

    if ( secondsSinceNow <= WEEK_IN_SECONDS && secondsSinceNow > DAY_IN_SECONDS )
    {
        timeType = @"days";
        timePart = (NSInteger) round( secondsSinceNow / ( 3600 * 24 ) );
		if ( timePart == 1 )
			timeType = @"day";
    }
    
    if ( timePart != 0 )
        return [NSString stringWithFormat:format, timePart, timeType];
    
    
    // if date less than a week ago return "x days ago"
    
    return [date descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" 
                                      timeZone:nil
                                        locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
}
@end
