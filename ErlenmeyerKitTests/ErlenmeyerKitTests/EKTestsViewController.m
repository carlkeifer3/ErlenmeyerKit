//
//  EKTestsViewController.m
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 7/28/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import "EKTestsViewController.h"
#import "EKTestUser.h"
#import "EKTestItem.h"
#import "NSManagedObject+EKManagedObjectExtensions.h"
#import "NSManagedObject+EKQueryingExtensions.h"
#import "EKEnumerations.h"

EKEnum(EKTestEnumeration,
    EKTestEnumeration0,
    EKTestEnumeration1
);

@implementation EKTestsViewController

- (EKTestUser *)testUser
{
    EKTestUser *testUser = [[EKTestUser alloc] init];
    [testUser setUuid: @"0001"];
    [testUser setEmail: @"test@dummy.com"];
    [testUser setCreationDate: [NSDate date]];
    
    return testUser;
}

- (void)viewDidLoad
{
    NSLog(@"%d", EKTestEnumerationFromInteger(1));
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
