//
//  Question.h
//  Screen
//
//  Created by Eric Galluzzo on 8/17/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ScreenModelObject.h"

@class Interview;

@interface Question : ScreenModelObject

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) NSNumber *sortOrder;
@property (nonatomic, retain) Interview *interview;

@end
