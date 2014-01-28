//
//  CandidateDetailViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 1/28/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "CandidateDetailViewController.h"
#import "InterviewDetailViewController.h"

@interface CandidateDetailViewController ()

@property (nonatomic, strong) NSArray *sortedInterviews;

@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet StarRatingView *ratingField;
@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;

@property (nonatomic, weak) IBOutlet UIButton *addInterviewButton;
@property (nonatomic, weak) IBOutlet UITableView *interviewTable;

@property (nonatomic, strong) InterviewDetailViewController *interviewDetailViewController;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;

- (void)configureView;
- (void)addInterview;

@end


@implementation CandidateDetailViewController

@synthesize nameField, ratingField, phoneField, emailField;
@synthesize addInterviewButton, interviewTable;
@synthesize interviewDetailViewController, masterPopoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setCandidate:(Candidate *)candidate
{
    if (_candidate != candidate) {
        _candidate = candidate;
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    if (self.candidate == nil) {
        self.nameField.text = @"";
        self.phoneField.text = @"";
        self.ratingField.rating = 0;
    } else {
        self.nameField.text = self.candidate.fullName;
        self.phoneField.text = self.candidate.phone;
        self.ratingField.rating = self.candidate.rating.intValue;
    }
    self.ratingField.userRating = 0;
    
    self.sortedInterviews = [self.candidate.interviews sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"interviewDate" ascending:NO]]];
    [[self interviewTable] reloadData];
}

- (void)addInterview
{
    Interview *interview = [NSEntityDescription insertNewObjectForEntityForName:@"Interview"
                                                         inManagedObjectContext:self.candidate.managedObjectContext];
    interview.candidate = self.candidate;
    [self.candidate addInterviewsObject:interview];
    [self saveCandidate];
    
    _sortedInterviews = [self.candidate.interviews sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"interviewDate" ascending:NO]]];
    
    self.interviewDetailViewController.interview = interview;
    [self.navigationController pushViewController:self.interviewDetailViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)saveCandidate
{
    if (self.candidate != nil) {
        // FIXME: Split the first and last name
        self.candidate.firstName = self.nameField.text;
        self.candidate.phone = self.phoneField.text;
        self.candidate.rating = [NSNumber numberWithInt:self.ratingField.rating];
        
        NSError *error;
        if ([self.candidate.managedObjectContext hasChanges] && ![self.candidate.managedObjectContext save:&error]) {
            // FIXME: Need a better error handling mechanism...
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interviewDetailViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"InterviewDetailViewController"];
    
    [self.addInterviewButton addTarget:self
                                action:@selector(addInterview)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.nameField addTarget:self
                       action:@selector(saveCandidate)
             forControlEvents:UIControlEventEditingChanged];
    
    [self.phoneField addTarget:self
                        action:@selector(saveCandidate)
              forControlEvents:UIControlEventEditingChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Candidates", @"Candidates");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Star rating view delegate

- (void)starRatingViewDidChangeRating:(StarRatingView *)starRatingView withRating:(int)rating
{
    [self saveCandidate];
}

@end
