//
//  EKTestUser.h
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 7/29/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EKTestItem, EKTestUser;

@interface EKTestUser : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) EKTestUser *siblingUser;
@end

@interface EKTestUser (CoreDataGeneratedAccessors)

- (void)addItemsObject:(EKTestItem *)value;
- (void)removeItemsObject:(EKTestItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
