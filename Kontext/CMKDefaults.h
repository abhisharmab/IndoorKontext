/*
 * File: CMKDefaults.h
 * Description: Contains default values for the application.
 */

@import Foundation;


extern NSString *BeaconIdentifier;
extern NSString * const CMKUserDefaultUseBeaconsForContext;
extern NSString * const CMKUserDefaultHasDisplayedBeaconNotification;


@interface CMKDefaults : NSObject

@property (nonatomic, readonly) NSArray *locations;
@property (nonatomic, readonly) BOOL useBeaconsForContext;
@property (nonatomic) BOOL hasDisplayedBeaconNotification;

+ (CMKDefaults *)sharedDefaults;

- (void)registerUserDefaults;

@end
