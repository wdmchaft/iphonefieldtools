// Copyright 2009 Brad Sokol
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  DistanceFormatter.m
//  FieldTools
//
//  Created by Brad on 2009/03/25.
//  Copyright 2009 Brad Sokol. All rights reserved.
//

#import "DistanceFormatter.h"

#import "DistanceRange.h"
#import "UserDefaults.h"

// Constant for converting  from metres to feet
const float METRES_TO_FEET = 3.280839895f;
const float METRES_TO_QUARTER_INCHES = 157.48031496f;

@interface DistanceFormatter ()

- (NSString*)formatDistance:(CGFloat)distance;
- (NSString*)formatDistancesForRange:(DistanceRange*)distanceRange;
- (NSString*)formatInches:(CGFloat)inches;

@property(nonatomic,getter=isTesting) BOOL testing;

@end

@implementation DistanceFormatter

@synthesize distanceUnits;
@synthesize testing;

- (id)init
{
	return [self initForTest:NO];
}

- (id)initForTest:(BOOL)test
{
	if (nil == (self = [super init]))
	{
		return nil;
	}
	
	[self setTesting:test];
	[self setDistanceUnits:DistanceUnitsMeters];
	
	return self;
}

- (NSString*)stringForObjectValue:(id)anObject
{
	if ([anObject isKindOfClass:[DistanceRange class]])
	{
		return [self formatDistancesForRange:anObject];
	}
	else if ([anObject isKindOfClass:[NSNumber class]])
	{
		return [self formatDistance:[anObject floatValue]];
	}
	
	return nil;
}

// Convert distance if necessary than format decimals and units
- (NSString*)formatDistance:(CGFloat)distance
{
	if (distance < 0)
	{
		// Return infinity symbol
		return @"∞";
	}
	
	DistanceUnits units = [self isTesting] ? [self distanceUnits] :
		[[NSUserDefaults standardUserDefaults] integerForKey:FTDistanceUnitsKey];
	switch (units)
	{
		case DistanceUnitsFeet:
			return [NSString stringWithFormat:[self formatStringForFeet], distance * METRES_TO_FEET, 
					NSLocalizedString(@"FEET_ABBREVIATION", "Abbreviation for feet")];
			break;
			
		case DistanceUnitsFeetAndInches:
			distance *= METRES_TO_FEET;
			float feet = floorf(distance);
			float inches = 12.0f * (distance - feet) + 0.125f;
			
			if (inches >= 12.0f)
			{
				feet += 1.0f;
				inches -= 12.0f;
			}
			
			if (feet == 0.0f)
			{
				return [self formatInches:inches];
			} 
			else if (inches <= 0.125f)
			{
				return [NSString stringWithFormat:@"%.0f'", feet];
			}
			else if (inches > 11.875f)
			{
				feet += 1.0f;
				return [NSString stringWithFormat:@"%.0f'", feet];
			}
			else
			{
				return [NSString stringWithFormat:@"%.0f' %@", feet, [self formatInches:inches]];
			}
			break;
			
		case DistanceUnitsMeters:
			return [NSString stringWithFormat:[self formatStringForMetric], distance, 
					NSLocalizedString(@"METRES_ABBREVIATION", "Abbreviation for metres")];
			break;
	}
	
	// We should never get here. This is here to satisfy a compiler warning.
	return @"FORMATTING ERROR";
}

- (NSString*)formatDistancesForRange:(DistanceRange*)distanceRange
{
	return [NSString stringWithFormat:@"%@\t%@\t%@", 
			[self formatDistance:[distanceRange nearDistance]],
			[self formatDistance:[distanceRange farDistance] - [distanceRange nearDistance]],
			[self formatDistance:[distanceRange farDistance]]];
}

- (NSString*)formatInches:(CGFloat)inches
{
	int quarters = inches / 0.25f;
	NSString* fraction = @"";
	switch (quarters % 4)
	{
		case 1:
			fraction = @"¼";
			break;
		case 2:
			fraction = @"½";
			break;
		case 3:
			fraction = @"¾";
			break;
	}
	if (floorf(inches) < 0.5)
	{
		return [NSString stringWithFormat:@"%@\"", fraction];
	}
	else
	{
		return [NSString stringWithFormat:@"%.0f%@\"", floorf(inches), fraction];
	}
}

- (NSString*)formatStringForFeet
{
	return [NSString stringWithFormat:@"%%.1f %@", 
			NSLocalizedString(@"FEET_ABBREVIATION", "Abbreviation for feet")];
}

- (NSString*)formatStringForMetric
{
	return [NSString stringWithFormat:@"%%.1f %@",
			NSLocalizedString(@"METRES_ABBREVIATION", "Abbreviation for metres")];
}

@end
