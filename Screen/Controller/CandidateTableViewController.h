//
//  CandidateTableViewController.h
//  Screen
//
//  Created by Eric Galluzzo on 7/20/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CandidateDetailViewController.h"

@interface CandidateTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) CandidateDetailViewController *detailViewController;
@property (nonatomic, retain) UIBarButtonItem *addButton;

@end
