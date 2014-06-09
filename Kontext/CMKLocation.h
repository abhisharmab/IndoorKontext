//
//  CMKLocation.h
//  Kontext
//
//  Created by Adam Durity on 3/26/14.
//  Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
//

#import <Foundation/Foundation.h>

@import CoreLocation;

@interface CMKLocation : NSObject

@property NSString *identifier;
@property NSString *name;
@property CLBeaconRegion *region;
@property NSDictionary *events;

+ (instancetype)locationWithIdentifier:(NSString *) identifier;

- (instancetype)initWithIdentifier:(NSString *) identifier
                              name:(NSString *) name
                            region:(CLBeaconRegion *) region
                            events:(NSDictionary *) events;
- (instancetype)initWithDictionary:(NSDictionary *) dict;

@end
