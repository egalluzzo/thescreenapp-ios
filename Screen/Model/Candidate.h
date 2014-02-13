//
//  Candidate.h
//  Screen
//
//  Created by Eric Galluzzo on 7/20/13.
//  Copyright (c) 2013 Eric Galluzzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "ScreenModelObject.h"

@class Interview;

@interface Candidate : ScreenModelObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSNumber *rating;
@property (nonatomic, retain) NSSet *interviews;

//@property (readonly, nonatomic) NSString *fullName;
- (NSString *)fullName;
@end

@interface Candidate (CoreDataGeneratedAccessors)

- (void)addInterviewsObject:(Interview *)value;
- (void)removeInterviewsObject:(Interview *)value;
- (void)addInterviews:(NSSet *)values;
- (void)removeInterviews:(NSSet *)values;

@end
