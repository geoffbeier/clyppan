//
//  OMHHumanReadableDateTest.m
//  Clyppan
//
//  Created by Ole Morten Halvorsen on 22/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OMHHumanReadableDateTest.h"
#import "OMHHumanReadableDate.h"

@implementation OMHHumanReadableDateTest

- (void) testLessThanAMinute
{
	NSDate *date = [NSDate date]; 
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];

	STAssertEqualObjects( string, @"less than a minute ago", @"Less than a minute ago" ); 
}

- (void) test59SecondsAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 59];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"less than a minute ago", @"Less than a minute ago" ); 
}

- (void) test1MinuteAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 60];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"1 minute ago", @"1 Minute ago" ); 
}

- (void) test2Minutes59secondsAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 179];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"3 minutes ago", @"2 Minutes 59 seconds ago" ); 
}

- (void) test3MinutesAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 180];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"3 minutes ago", @"3 Minutes ago" ); 
}

- (void) test59MinutesAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - (59 * 60)];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"59 minutes ago", @"59 Minutes ago" ); 
}

- (void) test1HourAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 3600];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"1 hour ago", @"1 hour ago" ); 
}

- (void) test2HoursAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - 7199];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"2 hours ago", @"2 hours ago" ); 
}

- (void) test1DayAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - (3600 * 24)];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"1 day ago", @"1 day ago" ); 
}

- (void) test2DaysAgo
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:now - (2 * 3600 * 24)];
	NSString *string = [OMHHumanReadableDate dateToHumanReadableString:date];
	
	STAssertEqualObjects( string, @"2 days ago", @"2 days ago" ); 
}



@end
