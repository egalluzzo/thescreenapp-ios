//
//  Question.h
//  Screen
//
//  Created by Eric Galluzzo on 8/17/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Interview;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) Interview *interview;

@end
