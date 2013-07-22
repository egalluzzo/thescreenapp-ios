//
//  Candidate.h
//  Screen
//
//  Created by Eric Galluzzo on 7/20/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Candidate : NSManagedObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *rating;

//@property (readonly, nonatomic) NSString *fullName;
- (NSString *)fullName;

@end
