//
//  TextFieldTableViewCell.m
//  Screen
//
//  Created by Eric Galluzzo on 8/21/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

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
