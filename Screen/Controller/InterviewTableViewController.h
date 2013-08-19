//
//  InterviewTableViewController.h
//  Screen
//
//  Created by Hitanshu Pande on 8/18/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterviewDetailViewController.h"

@interface InterviewTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) InterviewDetailViewController *detailViewController;

@end
