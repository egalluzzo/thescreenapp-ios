//
//  QuestionNotesTableViewCell.h
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionNotesTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) IBOutlet UITextField *questionField;
@property (nonatomic, strong) IBOutlet UITextView *notesField;

@end
