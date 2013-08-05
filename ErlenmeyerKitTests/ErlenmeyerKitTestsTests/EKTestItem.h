//
//  EKTestItem.h
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 7/29/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EKTestUser;

@interface EKTestItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) EKTestUser *user;

@end
