//
//  InterviewTableViewController.h
//  Screen
//
//  Created by Hitanshu Pande on 8/18/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterviewDetailViewController.h"

@interface InterviewTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSMutableArray *interviewsArray;
    NSManagedObjectContext *managedObjectContext;
    UIBarButtonItem *addButton;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) InterviewDetailViewController *detailViewController;
@property (nonatomic, retain) UIBarButtonItem *addButton;


@end
