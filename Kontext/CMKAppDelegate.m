/*
 * File: CMKAppDelegate.m
 * Description: Main entry point for the application. Displays the main menu and
 * notifies the user when region state transitions occur.
 */

#import "CMKAppDelegate.h"

#import "CMKDefaults.h"
#import "CMKEventTableViewController.h"
#import "CMKLocation.h"
@import CoreLocation;


@interface CMKAppDelegate () <UIApplicationDelegate, CLLocationManagerDelegate,
                              UIAlertViewDelegate>

@property CLLocationManager *locationManager;
@property UILocalNotification *lastNotification;

- (void)registerBeaconsForMonitoring;
- (void)unregisterBeaconsForMonitoring;

@end

@implementation CMKAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // This location manager will be used to notify the user of region state transitions.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    // establish user default settings
    [[CMKDefaults sharedDefaults] registerUserDefaults];

    // on first execution, show notification before registering beacons
    if ([CMKDefaults sharedDefaults].useBeaconsForContext &&
        ![CMKDefaults sharedDefaults].hasDisplayedBeaconNotification)
    {
        // show just-in-time notification on the first use of beacons
        NSString *alertTitle = NSLocalizedString(@"Beacons", @"Beacon notification title");
        NSString *alertMessage = NSLocalizedString(@"This app uses iBeacons to provide information based on your location. You may disable this feature within the Settings app.", @"Beacon notification message");
        NSString *alertCancelButtonTitle = NSLocalizedString(@"OK", @"Beacon notification cancel button title");

        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:self
                          cancelButtonTitle:alertCancelButtonTitle
                          otherButtonTitles:nil];
        [alert show];
        [CMKDefaults sharedDefaults].hasDisplayedBeaconNotification = YES;
    }

    // finally, register for notification of any changes to defaults
    [[NSNotificationCenter defaultCenter]
         addObserver:self
            selector:@selector(defaultsDidChange:)
                name:NSUserDefaultsDidChangeNotification
              object:nil];

    return YES;
}


- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSLog(@"Entered region %@", region.identifier);
    CMKLocation *location = [CMKLocation locationWithIdentifier:region.identifier];

    if (location)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody =
            [NSString stringWithFormat:NSLocalizedString(@"Welcome to %@", @"Location entry notification body"),
                 location.name];
        notification.alertAction = NSLocalizedString(@"view events", @"Location entry notification action");
        notification.userInfo = @{@"identifier": region.identifier};

        [[UIApplication sharedApplication]
             presentLocalNotificationNow:notification];
        self.lastNotification = notification;
    }
}


- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited region %@", region.identifier);

    if (self.lastNotification && self.lastNotification.userInfo &&
        [self.lastNotification.userInfo[@"identifier"] isEqualToString:region.identifier])
    {
        [[UIApplication sharedApplication]
             cancelLocalNotification:self.lastNotification];
        self.lastNotification = nil;
    }
}


- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    NSString *stateString;
    switch (state) {
        case CLRegionStateInside:
            stateString = @"inside";
            break;

        case CLRegionStateOutside:
            stateString = @"outside";
            break;

        case CLRegionStateUnknown:
            stateString = @"unknown";

        default:
            break;
    }

    NSLog(@"Determined %@ state for region %@", stateString, region.identifier);
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSString *identifier = notification.userInfo[@"identifier"];
    CMKLocation *location = [CMKLocation locationWithIdentifier:identifier];

    UIStoryboard *mainStoryboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController =
        (UITabBarController *)self.window.rootViewController;
    UINavigationController *locationsNavigationController =
        (UINavigationController *)tabBarController.viewControllers[0];

    CMKEventTableViewController *eventTableViewContoller =
        [mainStoryboard instantiateViewControllerWithIdentifier:@"EventTableViewController"];
    eventTableViewContoller.location = location;

    tabBarController.selectedIndex = 0;
    [locationsNavigationController popToRootViewControllerAnimated:NO];
    [locationsNavigationController pushViewController:eventTableViewContoller animated:NO];
}


#pragma UIAlertView

- (void)alertView:(UIAlertView *)alert
            clickedButtonAtIndex:(NSInteger) buttonIndex
{
    if (buttonIndex == 0) // cancel
    {
        if ([CMKDefaults sharedDefaults].useBeaconsForContext) {
            [self registerBeaconsForMonitoring];
        }
    }
}


- (void)registerBeaconsForMonitoring
{
    for (CMKLocation *location in [[CMKDefaults sharedDefaults] locations]) {
        CLBeaconRegion *region = location.region;

        if (![self.locationManager.monitoredRegions member:region])
        {
            region.notifyOnEntry = YES;
            region.notifyOnExit = YES;
            [self.locationManager startMonitoringForRegion:region];
            NSLog(@"Started monitoring region %@", region);
        }
    }

    NSLog(@"Monitored regions: %@", self.locationManager.monitoredRegions);
}


- (void)unregisterBeaconsForMonitoring
{
    for (CMKLocation *location in [[CMKDefaults sharedDefaults] locations])
    {
        CLBeaconRegion *region = location.region;

        if ([self.locationManager.monitoredRegions member:region])
        {
            [self.locationManager stopMonitoringForRegion:region];
            NSLog(@"Stopped monitoring region %@", region);
        }
    }

    NSLog(@"Monitored regions: %@", self.locationManager.monitoredRegions);
}


- (void)defaultsDidChange:(NSNotification *)notification
{
    if ([CMKDefaults sharedDefaults].useBeaconsForContext)
    {
        [self registerBeaconsForMonitoring];
    }
    else
    {
        [self unregisterBeaconsForMonitoring];
    }
}

@end
