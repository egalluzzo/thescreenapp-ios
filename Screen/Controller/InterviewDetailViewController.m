//
//  InterviewDetailViewController.m
//  Screen
//
//  Created by Hitanshu Pande on 8/18/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <EventKit/EventKit.h>

#import "InterviewDetailViewController.h"
#import "TextFieldTableViewCell.h"

#define QUESTIONS_SECTION 2

@interface InterviewDetailViewController ()

@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIPopoverController *datePopoverController;
@property (nonatomic, strong) NSArray *sortedQuestions;

- (void)configureView;
- (void)configureQuestionCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addToCalendar;
- (void)addQuestion;
- (void)editQuestions;

- (void)showAlertWithTitle:title message:message;

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
    
    [self.addToCalendarButton addTarget:self
                                 action:@selector(addToCalendar)
                       forControlEvents:UIControlEventTouchUpInside];
    
    [self.addQuestionButton addTarget:self
                               action:@selector(addQuestion)
                     forControlEvents:UIControlEventTouchUpInside];
    
    [self.editQuestionsButton addTarget:self
                                 action:@selector(editQuestions)
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

- (void)addToCalendar
{
    // See http://stackoverflow.com/questions/13082678/add-event-to-calendar-in-xcode-ios
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    [self showAlertWithTitle:@"Interview Not Added" message:@"Could not add the event to your calendar."];
                }
                else if (!granted)
                {
                    [self showAlertWithTitle:@"Interview Not Added" message:@"Access to your calendar was denied."];
                }
                else
                {
                    // access granted
                    [self addEventToCalendarAfterAccessGranted];
                }
            });
        }];
    }
    else
    {
        // This code runs in iOS 4 or iOS 5
        [self addEventToCalendarAfterAccessGranted];
    }
}

- (void)addEventToCalendarAfterAccessGranted
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.title = [NSString stringWithFormat:@"Interview for %@", self.interview.candidate.fullName];
    
    event.startDate = self.interview.interviewDate;
    event.endDate = [self.interview.interviewDate dateByAddingTimeInterval:60*60];
    event.location = self.interview.location;
    
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    NSError *error;
    if (![eventStore saveEvent:event span:EKSpanThisEvent error:&error]) {
        // FIXME: Need a better error handling mechanism...
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self showAlertWithTitle:@"Interview Added" message:@"The interview has been added to your calendar."];
}

- (void)showAlertWithTitle:title message:message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil];
    [alert show];
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

- (void)editQuestions
{
    // Doesn't work yet
//    self.editing = !self.editing;
//    [self.editQuestionsButton setTitle:(self.editing ? @"Done" : @"Edit")
//                              forState:UIControlStateNormal | UIControlStateSelected | UIControlStateHighlighted | UIControlStateDisabled];
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
        TextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextFieldTableViewCell"];
        if (cell == nil) {
            // Find the table cell out of the NIB.
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TextFieldTableViewCell" owner:nil options:nil];
            for (UIView *view in views) {
                if([view isKindOfClass:[UITableViewCell class]]) {
                    cell = (TextFieldTableViewCell *)view;
                }
            }
            cell.textField.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [self configureQuestionCell:cell cellForRowAtIndexPath:indexPath];
        return cell;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)configureQuestionCell:(TextFieldTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
    cell.textField.text = question.question;
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
    if (indexPath.section == QUESTIONS_SECTION) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == QUESTIONS_SECTION);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Question *question = nil;
    if (indexPath.section == QUESTIONS_SECTION) {
        switch (editingStyle) {
            case UITableViewCellEditingStyleDelete:
                question = [self.sortedQuestions objectAtIndex:indexPath.row];
                [self.interview removeQuestionsObject:question];
                [self saveInterview];
                [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:QUESTIONS_SECTION]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            default:
                break;
        }
    }
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

#pragma mark - Text field delegate

// See http://stackoverflow.com/questions/4375442/accessing-uitextfield-in-a-custom-uitableviewcell
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    // this should return you your current indexPath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(TextFieldTableViewCell*)[[textField superview] superview]];
    if (indexPath.section == QUESTIONS_SECTION) {
        Question *question = [self.sortedQuestions objectAtIndex:indexPath.row];
        question.question = textField.text;
        
        NSError *error;
        if ([question.managedObjectContext hasChanges] && ![question.managedObjectContext save:&error]) {
            // FIXME: Need a better error handling mechanism...
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    TextFieldTableViewCell *cell = (TextFieldTableViewCell *) [[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
}

@end
