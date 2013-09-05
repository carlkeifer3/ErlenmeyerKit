//
//  EKTestItemName.h
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 8/6/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EKTestItem;

@interface EKTestItemName : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *items;
@end

@interface EKTestItemName (CoreDataGeneratedAccessors)

- (void)addItemsObject:(EKTestItem *)value;
- (void)removeItemsObject:(EKTestItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
