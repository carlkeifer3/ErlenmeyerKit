//
//  EKTestItem.h
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 8/6/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EKEnumerations.h"

@class EKTestItemName, EKTestUser;

EKEnum(Test,
    TestValue,
    T2
);

@interface EKTestItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) EKTestUser *user;
@property (nonatomic, retain) NSSet *itemNames;
@end

@interface EKTestItem (CoreDataGeneratedAccessors)

- (void)addItemNamesObject:(EKTestItemName *)value;
- (void)removeItemNamesObject:(EKTestItemName *)value;
- (void)addItemNames:(NSSet *)values;
- (void)removeItemNames:(NSSet *)values;

@end
