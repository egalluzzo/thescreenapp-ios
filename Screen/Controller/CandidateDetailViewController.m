//
//  CandidateDetailViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 8/14/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "CandidateDetailViewController.h"
#import "Interview.h"

#define INTERVIEW_SECTION 1

@interface CandidateDetailViewController ()
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSArray *sortedInterviews;
- (void)configureView;
- (void)configureInterviewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addInterview;
@end


@implementation CandidateDetailViewController

@synthesize candidate = _candidate;
@synthesize sortedInterviews = _sortedInterviews;

@synthesize nameField;
@synthesize phoneField;
@synthesize ratingField;
@synthesize addInterviewButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.nameField.delegate = self;
        self.phoneField.delegate = self;
        self.ratingField.delegate = self;
    }
    return self;
}

- (void)setCandidate:(Candidate *)candidate
{
    if (_candidate != candidate) {
        _candidate = candidate;
        _sortedInterviews = [candidate.interviews sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"interviewDate" ascending:NO]]];
        NSLog(@"Candidate interviews: %@", self.candidate.interviews);
        NSLog(@"Sorted interviews: %@", _sortedInterviews);
        [self configureView];
        [[self tableView] reloadData];
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
}

- (void)addInterview
{
    Interview *interview = [NSEntityDescription insertNewObjectForEntityForName:@"Interview"
                                                         inManagedObjectContext:self.candidate.managedObjectContext];
    interview.candidate = self.candidate;
    [self.candidate addInterviewsObject:interview];
    [self saveCandidate];
    
    _sortedInterviews = [self.candidate.interviews sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"interviewDate" ascending:NO]]];
    NSLog(@"Candidate interviews: %@", self.candidate.interviews);
    NSLog(@"Sorted interviews: %@", _sortedInterviews);
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.sortedInterviews indexOfObject:interview]
                                                   inSection:INTERVIEW_SECTION];
    NSLog(@"New index path: %@", newIndexPath);
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                          withRowAnimation:UITableViewRowAnimationMiddle];
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
    
    [self.addInterviewButton addTarget:self
                                action:@selector(addInterview)
                      forControlEvents:UIControlEventTouchUpInside];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If we have no candidate, there are no sections.
    if (self.candidate == nil) {
        return 0;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == INTERVIEW_SECTION) {
        if (self.candidate) {
            return self.sortedInterviews.count;
        } else {
            return 0;
        }
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == INTERVIEW_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterviewCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"InterviewCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [self configureInterviewCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)configureInterviewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    Interview *interview = [self.sortedInterviews objectAtIndex:indexPath.row];
    cell.textLabel.text = [dateFormatter stringFromDate:interview.interviewDate];
    cell.detailTextLabel.text = interview.location;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same height as row 0
    if (section == INTERVIEW_SECTION) {
        return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same indentation level as row 0
    if (section == INTERVIEW_SECTION) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Text view delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self saveCandidate];
}

#pragma mark - Star rating view delegate

- (void)starRatingViewDidChangeRating:(StarRatingView *)starRatingView withRating:(int)rating
{
    [self saveCandidate];
}

@end
