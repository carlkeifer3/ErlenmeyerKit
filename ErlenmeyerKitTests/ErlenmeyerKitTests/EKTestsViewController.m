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

@interface EKTestsViewController ()

@end

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
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [NSManagedObject setServerURL: @"http://127.0.0.1:8082"];

//    
//    EKTestUser *testUser = [self testUser];    
    EKTestItem *item = [[EKTestItem alloc] init];
    [item setUuid: @"1000"];
    [item setName: @"TEST ITEM"];
//    [testUser addItemsObject: item];
//    
//    item = [[EKTestItem alloc] init];
    [item setUuid: @"2000"];
    [item setName: @"TEST ITEM 2"];
//    [testUser addItemsObject: item];
//    
//    [testUser saveToServer: ^(NSError *error)
//    {
//        assert(error == nil);
//    }];

    [EKTestUser get: @"0001"
         fromServer: ^(NSManagedObject *object, NSError *error) {
             NSLog(@"%@", [(EKTestUser *)object items]);
         }];
//    [EKTestUser allFromServer: ^(NSArray *all, NSError *error)
//     {
//         NSLog(@"%@", all);
//         
////         [[EKTestUser get: @"0001"] deleteFromServer: ^(NSError *error)
////          {
////              assert(error == nil);
////          }];
//     } where: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
