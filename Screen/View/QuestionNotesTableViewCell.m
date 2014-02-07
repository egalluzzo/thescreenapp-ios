//
//  QuestionNotesTableViewCell.m
//  Screen
//
//  Created by Eric Galluzzo on 2/7/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import "QuestionNotesTableViewCell.h"

@implementation QuestionNotesTableViewCell

// Override awakeFromNib so that the layout constraints get attached to the content view instead of
// the text field.  This is required to make the delete icon and move handles push the text field
// out of the way.  See http://nsscreencast.com/episodes/70-autolayout-with-cells
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        [self removeConstraint:constraint];
        id firstItem = constraint.firstItem == self ? self.contentView : constraint.firstItem;
        id secondItem = constraint.secondItem == self ? self.contentView : constraint.secondItem;
        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:constraint.firstAttribute
                                                                         relatedBy:constraint.relation
                                                                            toItem:secondItem
                                                                         attribute:constraint.secondAttribute
                                                                        multiplier:constraint.multiplier
                                                                          constant:constraint.constant];
        [self.contentView addConstraint:newConstraint];
    }
    
    // Add a rounded border to the view containing the text field and text view.  See:
    // http://stackoverflow.com/questions/4754392/uiview-with-rounded-corners-and-drop-shadow
    
    self.backgroundView.layer.cornerRadius = 5.0;
    self.backgroundView.layer.masksToBounds = YES;
    self.backgroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.backgroundView.layer.borderWidth = 1;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
