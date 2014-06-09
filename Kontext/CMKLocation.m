//
//  CMKLocation.m
//  Kontext
//
//  Created by Adam Durity on 3/26/14.
//  Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
//

#import "CMKLocation.h"

#import "CMKDefaults.h"

@implementation CMKLocation

+ (instancetype)locationWithIdentifier:(NSString *)identifier
{
    CMKLocation *location;
    
    NSUInteger locationIndex = [[[CMKDefaults sharedDefaults] locations]
            indexOfObjectPassingTest: ^(id obj, NSUInteger idx, BOOL *stop)
    {
        CMKLocation *l = (CMKLocation *) obj;
        if ([l.identifier isEqualToString:identifier])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }];

    if (locationIndex != NSNotFound)
    {
        location = [CMKDefaults sharedDefaults].locations[locationIndex];
    }

    return location;
}


- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                            region:(CLBeaconRegion *)region
                            events:(NSDictionary *)events {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _name = name;
        _region = region;
        _events = events;
    }

    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dict {
    NSString *name = dict[@"name"];
    NSString *identifier = dict[@"identifier"];
    NSDictionary *events = dict[@"events"];

    NSDictionary *beacon = dict[@"beacon"];
    NSUUID *proximityUUID = [[NSUUID alloc]
                             initWithUUIDString:beacon[@"proximityUUID"]];
    CLBeaconMajorValue major = [beacon[@"major"] unsignedShortValue];
    CLBeaconMinorValue minor = [beacon[@"minor"] unsignedShortValue];
    CLBeaconRegion *region;

    if (proximityUUID && major && minor && identifier)
    {
        region = [[CLBeaconRegion alloc]
                        initWithProximityUUID:proximityUUID
                        major:major
                        minor:minor
                        identifier:identifier];
    }
    else if (proximityUUID && major && identifier)
    {
        region = [[CLBeaconRegion alloc]
                        initWithProximityUUID:proximityUUID
                        major:major
                        identifier:identifier];
    }
    else if (proximityUUID && identifier)
    {
        region = [[CLBeaconRegion alloc]
                        initWithProximityUUID:proximityUUID
                        identifier:identifier];
    }
    else
    {
        NSLog(@"WARNING: Unable to create beacon region %@", identifier);
    }

    return [self initWithIdentifier:identifier
                               name:name
                             region:region
                             events:events];
}

@end
