//
//  CMKLocationTableViewController.m
//  Kontext
//
//  Created by Adam Durity on 3/27/14.
//  Copyright (c) 2014 Carnegie Mellon University. All rights reserved.
//

#import "CMKLocationTableViewController.h"

#import "CMKDefaults.h"
#import "CMKEventTableViewController.h"
#import "CMKLocation.h"

@interface CMKLocationTableViewController ()

@property (nonatomic) NSArray *locations;

@end

@implementation CMKLocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locations = [[CMKDefaults sharedDefaults] locations];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"LocationCell"
                                        forIndexPath:indexPath];
    if (indexPath.section == 0)
    {
        CMKLocation *location = [self.locations objectAtIndex:indexPath.row];
        cell.textLabel.text = location.name;
    }

    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEvents"])
    {
        CMKEventTableViewController *destinationViewController =
            segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CMKLocation *location;

        if (indexPath.section == 0 &&
               (location = [self.locations objectAtIndex:indexPath.row]))
        {
            destinationViewController.location = location;
        }
    }
}


@end
