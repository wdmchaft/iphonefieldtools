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

#import "UserDefaults.h"

// Constant for converting  from metres to feet
const static float METRES_TO_FEET = 3.280839895f;

@interface DistanceFormatter ()

- (NSString*)formatDistance:(CGFloat)distance;
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
	if (![anObject isKindOfClass:[NSNumber class]])
	{
		return nil;
	}
	
	return [self formatDistance:[anObject floatValue]];
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
			return [NSString stringWithFormat:@"%.1f %@", distance * METRES_TO_FEET, 
					NSLocalizedString(@"FEET_ABBREVIATION", "Abbreviation for feet")];
			break;
			
		case DistanceUnitsFeetAndInches:
			distance *= METRES_TO_FEET;
			float feet = floorf(distance);
			float inches = rintf(12.0f * (distance - feet));
			inches = 12.0f * (distance - feet) + 0.125f;
			
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
			else
			{
				return [NSString stringWithFormat:@"%.0f' %@", feet, [self formatInches:inches]];
			}
			break;
			
		case DistanceUnitsMeters:
			return [NSString stringWithFormat:@"%.1f %@", distance, 
					NSLocalizedString(@"METRES_ABBREVIATION", "Abbreviation for metres")];
			break;
	}
	
	// We should never get here. This is here to satisfy a compiler warning.
	return @"FORMATTING ERROR";
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

@end
