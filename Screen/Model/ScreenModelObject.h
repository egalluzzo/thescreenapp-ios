//
//  ScreenModelObject.h
//  Screen
//
//  Created by Eric Galluzzo on 2/13/14.
//  Copyright (c) 2014 Eric Galluzzo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ScreenModelObject : NSManagedObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSDate *updateDate;
@property (nonatomic, retain) NSNumber *deleted;

@end
