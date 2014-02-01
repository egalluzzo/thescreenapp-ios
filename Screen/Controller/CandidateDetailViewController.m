//
//  CandidateDetailViewController.m
//  Screen
//
//  Created by Eric Galluzzo on 1/28/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "NSString+MD5.h"
#import "CandidateDetailViewController.h"
#import "InterviewDetailViewController.h"

// The number of seconds between the time the user changes the email address and the time we re-request the Gravatar image
#define EMAIL_CHANGE_IMAGE_DELAY 0.5

@interface CandidateDetailViewController ()

@property (nonatomic, strong) NSArray *sortedInterviews;

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet StarRatingView *ratingField;
@property (nonatomic, weak) IBOutlet UITextField *phoneField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;

@property (nonatomic, weak) IBOutlet UIButton *addInterviewButton;
@property (nonatomic, weak) IBOutlet UITableView *interviewTable;

@property (nonatomic, strong) InterviewDetailViewController *interviewDetailViewController;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSTimer *emailRequestTimer;

- (void)configureView;
- (void)configureInterviewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addInterview;
- (void)emailChanged;
- (void)requestAvatarWithTimer:(NSTimer *)timer;

@end


@implementation CandidateDetailViewController

@synthesize nameField, ratingField, phoneField, emailField;
@synthesize addInterviewButton, interviewTable;
@synthesize interviewDetailViewController, masterPopoverController, emailRequestTimer;

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
        self.emailField.text = @"";
        self.ratingField.rating = 0;
    } else {
        self.nameField.text = self.candidate.fullName;
        self.phoneField.text = self.candidate.phone;
        self.emailField.text = self.candidate.email;
        self.ratingField.rating = self.candidate.rating.intValue;
    }
    self.ratingField.userRating = 0;
    
    self.sortedInterviews = [self.candidate.interviews sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"interviewDate" ascending:NO]]];
    [[self interviewTable] reloadData];
    
    [self requestAvatarWithTimer:nil];
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
        self.candidate.email = self.emailField.text;
        self.candidate.rating = [NSNumber numberWithInt:self.ratingField.rating];
        
        NSError *error;
        if ([self.candidate.managedObjectContext hasChanges] && ![self.candidate.managedObjectContext save:&error]) {
            // FIXME: Need a better error handling mechanism...
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)emailChanged
{
    if (self.emailRequestTimer) {
        [self.emailRequestTimer invalidate];
    }
    self.emailRequestTimer = [NSTimer scheduledTimerWithTimeInterval:EMAIL_CHANGE_IMAGE_DELAY
                                                              target:self
                                                            selector:@selector(requestAvatarWithTimer:)
                                                            userInfo:nil
                                                             repeats:NO];
    [self saveCandidate];
}

- (void)requestAvatarWithTimer:(NSTimer *)timer
{
    // We request an image with twice the height of the frame so that it looks nice
    // on Retina displays.  The default image if the user has no Gravatar is "mm",
    // which is a built-in Gravatar image of a "mystery man" (silhouette of a
    // cartoon-ish headshot).
    
    NSString *emailMD5Hash = [[self.emailField.text lowercaseString] MD5];
    NSString *gravatarURL = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d&d=mm",
                             emailMD5Hash, (int)(self.avatarImageView.frame.size.height * 2)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:gravatarURL]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               UIImage *downloadedImage = [UIImage imageWithData:data];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   self.emailRequestTimer = nil;
                                   self.avatarImageView.image = downloadedImage;
                               });
                           }];
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
    
    [self.emailField addTarget:self
                        action:@selector(emailChanged)
              forControlEvents:UIControlEventEditingChanged];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// FIXME: Move all the table stuff to a separate delegate class.

#pragma mark - Table view data source (for interview table)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If we have no candidate, there are no sections.
    if (self.candidate == nil) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.candidate) {
        return self.sortedInterviews.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterviewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"InterviewCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self configureInterviewCell:cell cellForRowAtIndexPath:indexPath];
    return cell;
}

- (void)configureInterviewCell:(UITableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    Interview *interview = [self.sortedInterviews objectAtIndex:indexPath.row];
    cell.textLabel.text = [dateFormatter stringFromDate:interview.interviewDate];
    cell.detailTextLabel.text = interview.location;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]].frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Interview *interview = [self.sortedInterviews objectAtIndex:indexPath.row];
    self.interviewDetailViewController.interview = interview;
    [self.navigationController pushViewController:self.interviewDetailViewController animated:YES];
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
