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
//  Camera.h
//  FieldTools
//
//  Created by Brad on 2009/01/21.
//

@class CoC;

@interface Camera : NSObject 
{
	int identifier;
	NSString* description;
	CoC* coc;
}

+ (void)delete:(Camera*)camera;
+ (int)count;
+ (NSArray*)findAll;
+ (void)moveFromIndex:(int)fromIndex toIndex:(int)toIndex;

+ (Camera*)findFromDefaultsForIndex:(int)index;
+ (Camera*)findSelectedInDefaults;

// The designated initializer
- (id)initWithDescription:(NSString*)description coc:(CoC*)coc identifier:(int)identifier;

- (id)copyWithZone:(NSZone *)zone;

- (NSDictionary*) asDictionary;
- (void)save;

@property(nonatomic, retain) NSString* description;
@property(nonatomic, retain) CoC* coc;
@property(nonatomic) int identifier;

@end
