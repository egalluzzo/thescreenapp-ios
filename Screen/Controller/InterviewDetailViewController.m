//
//  InterviewDetailViewController.m
//  Screen
//
//  Created by Hitanshu Pande on 8/18/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "InterviewDetailViewController.h"

#define QUESTIONS_SECTION 1

@interface InterviewDetailViewController ()
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *datePopoverController;
@property (nonatomic, strong) NSArray *sortedQuestions;
- (void)configureView;
- (void)configureQuestionCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addQuestion;
@end

@implementation InterviewDetailViewController

@synthesize interview = _interview;
@synthesize sortedQuestions = _sortedQuestions;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.addQuestionButton addTarget:self
                               action:@selector(addQuestion)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.locationField addTarget:self
                           action:@selector(saveInterview)
                 forControlEvents:UIControlEventEditingChanged];
    
    // Pop up the date picker when tapping the interview date.
    UITapGestureRecognizer *tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker)];
    [self.dateLabel addGestureRecognizer:tapGesture];

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

- (void)setInterview:(Interview *)interview
{
    if (_interview != interview) {
        _interview = interview;
        [self configureView];
        [[self tableView] reloadData];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)saveInterview
{
    if (self.interview != nil) {
        self.interview.location = self.locationField.text;
        
        NSError *error;
        if ([self.interview.managedObjectContext hasChanges] && ![self.interview.managedObjectContext save:&error]) {
            // FIXME: Need a better error handling mechanism...
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureView
{
    if (self.interview != nil) {
        self.candidateNameLabel.text = self.interview.candidate.fullName;
        self.locationField.text = self.interview.location;
        [self reloadDateLabel];
        
        // Reload the interviews in case they have changed.
        _sortedQuestions = [self.interview.questions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"question" ascending:NO]]];
        [[self tableView] reloadData];
    }
}

- (void)addQuestion
{
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:@"Question"
                                                       inManagedObjectContext:self.interview.managedObjectContext];
    question.interview = self.interview;
    [self.interview addQuestionsObject:question];
    [self saveInterview];
    
    _sortedQuestions = [self.interview.questions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"question" ascending:NO]]];
    
    // Note: I tried just inserting a single index path here but it
    // sometimes got confused and drew cells in different sections
    // over top of each other, probably due to the static/dynamic
    // nature of the table.
    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:QUESTIONS_SECTION]
                    withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadDateLabel
{
    // A date formatter for the time stamp.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    self.dateLabel.text = [dateFormatter stringFromDate:self.interview.interviewDate];
}

- (void)showDatePicker
{
    // Code adapted from http://stackoverflow.com/questions/7341835/uidatepicker-in-uipopover?rq=1
    UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
    
    UIView *popoverView = [[UIView alloc] init];
    popoverView.backgroundColor = [UIColor blackColor];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.date = self.interview.interviewDate;
    datePicker.frame = CGRectMake(0,44,320, 216);
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker setMinuteInterval:5];
    [datePicker setTag:10];
    [datePicker addTarget:self action:@selector(getDateFromPicker:) forControlEvents:UIControlEventValueChanged];
    [popoverView addSubview:datePicker];
    
    popoverContent.view = popoverView;
    self.datePopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    //popoverController.delegate=self;
    
    [self.datePopoverController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
    [self.datePopoverController presentPopoverFromRect:self.dateLabel.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)getDateFromPicker:(id)sender
{
    UIDatePicker *picker = (UIDatePicker *)sender;
    self.interview.interviewDate = picker.date;
    [self reloadDateLabel];
    [self saveInterview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If we have no candidate, there are no sections.
    if (self.interview == nil) {
        return 0;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == QUESTIONS_SECTION) {
        if (self.interview) {
            return self.sortedQuestions.count;
        } else {
            return 0;
        }
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == QUESTIONS_SECTION) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"QuestionCell"];
        }
        [self configureQuestionCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)configureQuestionCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
    cell.textLabel.text = question.question;
    cell.detailTextLabel.text = @""; // Not sure what we should put here...
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same height as row 0
    if (section == QUESTIONS_SECTION) {
        return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    
    // if dynamic section make all rows the same indentation level as row 0
    if (section == QUESTIONS_SECTION) {
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
    barButtonItem.title = NSLocalizedString(@"Interviews", @"Interviews");
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

@end
