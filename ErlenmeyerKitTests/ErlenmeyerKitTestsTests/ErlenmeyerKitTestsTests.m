//
//  ErlenmeyerKitTestsTests.m
//  ErlenmeyerKitTestsTests
//
//  Created by Patrick Perini on 7/28/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "../../EKManagedObjectExtensions.h"
#import "EKTestUser.h"
#import "EKTestItem.h"

@interface ErlenmeyerKitTestsTests : XCTestCase

@end

@implementation ErlenmeyerKitTestsTests

- (void)setUp
{
    [NSManagedObject deleteAll];
    [NSManagedObject setServerURL: @"http://127.0.0.1:8082"];
}

- (void)tearDown
{
    [NSManagedObject deleteAll];
}

#pragma mark - DRY
- (EKTestUser *)testUser
{
    EKTestUser *testUser = [[EKTestUser alloc] init];
    [testUser setUuid: @"0001"];
    [testUser setEmail: @"test@dummy.com"];
    [testUser setCreationDate: [NSDate date]];
    
    return testUser;
}

- (EKTestItem *)testItem
{
    EKTestItem *testItem = [[EKTestItem alloc] init];
    [testItem setUuid: @"0100"];
    [testItem setName: @"Test Item"];
    
    return testItem;
}

#pragma mark - Test EKQueryingExtensions
- (void)testInit
{
    EKTestUser *testUser = [self testUser];
    
    XCTAssertEqualObjects([testUser uuid], @"0001", @"[testUser uuid] == %@", [testUser uuid]);
    XCTAssertEqualObjects([testUser email], @"test@dummy.com", @"[testUser email] == %@", [testUser email]);
    XCTAssertNotNil([testUser creationDate], @"[testUser creationDate] == %@", [testUser creationDate]);
}

- (void)testAll
{
    EKTestUser *testUser = [self testUser];
    NSArray *allUsers = [EKTestUser all];
    
    XCTAssertFalse([allUsers count] <= 0, @"[allUsers count] == %d", [allUsers count]);
    XCTAssertTrue([allUsers containsObject: testUser], @"![allUsers containsObject: testUser]");
}

- (void)testGet
{
    EKTestUser *testUser = [self testUser];
    testUser = [EKTestUser get: @"0001"];
    
    XCTAssertNotNil(testUser, @"testUser == %@", testUser);
}

- (void)testDelete
{
    EKTestUser *testUser = [EKTestUser get: @"0001"];
    [testUser delete];
    
    testUser = [EKTestUser get: @"0001"];
    XCTAssertNil(testUser, @"testUser != nil");
}

- (void)testSaveAll
{
    EKTestUser *testUser = [self testUser];
    [NSManagedObject saveAll];
    
    XCTAssertNotNil(testUser, @"testUser == %@", testUser);
    XCTAssertFalse([testUser hasChanges], @"[testUser hasChanges]");
}

- (void)testSaveToServer
{
    
}

//- (void)testAllFromServer
//{
//    EKTestUser *testUser = [self testUser];
//    [testUser saveToServer: ^(NSError *error)
//    {
//        XCTAssertNil(error, @"error == %@", error);
//        
//        [EKTestUser allFromServer: ^(NSArray *all, NSError *error)
//        {
//            XCTAssertNil(error, @"error == %@", error);
//            XCTAssertFalse([all count] <= 0, @"[all count] == %d", [all count]);
//        } where: @{}];
//    }];
//}

#pragma mark - EKManagedObjectExtensions
- (void)testDictionaryValue
{
    EKTestUser *testUser = [self testUser];
    EKTestItem *testItem = [self testItem];
    [testUser addItemsObject: testItem];
    
    NSDictionary *testUserDictionary = [testUser dictionaryValue];
    
    XCTAssertNotNil(testUserDictionary, @"testUserDictionary == %@", testUserDictionary);
    for (NSString *key in testUserDictionary)
    {
        if (![testUser valueForKey: key])
        {
            XCTAssertEqualObjects([testUserDictionary objectForKey: key], [NSNull null], @"[testUserDictionary objectForKey: %@] != [NSNull null]", key);
            continue;
        }
        else if ([[[[testUser entity] relationshipsByName] allKeys] containsObject: key])
        {
            NSRelationshipDescription *relationshipDescription = [[[testUser entity] relationshipsByName] objectForKey: key];
            NSString *keyPath = [NSString stringWithFormat: @"%@.%@", key, [[testUser class] primaryKey]];

            if ([relationshipDescription isToMany])
            {
                XCTAssertEqualObjects([testUserDictionary objectForKey: key], [[testUser valueForKeyPath: keyPath] allObjects], @"[testUserDictionary objectForKey: %@] != [[testUser valueForKeyPath: %@] allObjects]", key, keyPath);
            }
            else // to-one
            {
                XCTAssertEqualObjects([testUserDictionary objectForKey: key], [testUser valueForKeyPath: keyPath], @"[testUserDictionary objectForKey: %@] != [testUser valueForKeyPath: %@]", key, keyPath);
            }
            
            continue;
        }
        
        XCTAssertEqualObjects([testUserDictionary objectForKey: key], [testUser valueForKey: key], @"[testUserDictionary objectForKey: %@] != [testUser valueForKey: %@]", key, key);
    }
}

- (void)testAddEntriesFromDictionary
{
    EKTestUser *testUser0 = [self testUser];
    EKTestUser *testUser1 = [self testUser];
    
    NSDictionary *testUser1Dictionary = @{
        @"uuid": @"0002",
        @"siblingUser": @"0001"
    };
    [testUser1 addEntriesFromDictionary: testUser1Dictionary];
    
    XCTAssertEqualObjects([testUser1 uuid], @"0002", @"[testUser1 uuid] == %@", [testUser1 uuid]);
    XCTAssertEquals([testUser1 siblingUser], testUser0, @"[testUser1 siblingUser] == %@", [testUser1 siblingUser]);
    XCTAssertEquals([testUser0 siblingUser], testUser1, @"[testUser0 siblingUser] == %@", [testUser0 siblingUser]);
}

#pragma mark - EKCopyingExtensions
- (void)testCopy
{
    EKTestUser *testUser = [self testUser];
    EKTestUser *testUserCopy = [testUser copy];
    
    XCTAssertFalse(testUser == testUserCopy, @"testUser == testUserCopy");
    XCTAssertEqualObjects([testUser uuid], [testUserCopy uuid], @"[testUser uuid] != [testUserCopy uuid]");
    XCTAssertEqualObjects([testUser email], [testUserCopy email], @"[testUser email] != [testUserCopy email]");
    XCTAssertEqualObjects([testUser creationDate], [testUserCopy creationDate], @"[testUser creationDate] != [testUserCopy creationDate]");
}

- (void)testCopyToKeyPaths
{
    EKTestUser *testUser = [self testUser];
    EKTestUser *siblingUser = [self testUser];
    
    [siblingUser setUuid: @"0002"];
    [testUser setSiblingUser: siblingUser];
    
    EKTestUser *testUserCopy = [testUser copyToKeyPaths: @[NSStringFromSelector(@selector(siblingUser))]];
    
    XCTAssertFalse(testUser == testUserCopy, @"testUser0 == testUser1");
    XCTAssertEqualObjects([testUser uuid], [testUserCopy uuid], @"[testUser uuid] != [testUserCopy uuid]");
    
    XCTAssertFalse([testUser siblingUser] == [testUserCopy siblingUser], @"[testUser siblingUser] == [testUserCopy siblingUser]");
    XCTAssertEqualObjects([[testUser siblingUser] uuid], [[testUserCopy siblingUser] uuid], @"[[testuser siblingUser] uuid] != [[testUserCopy siblingUser] uuid]");
}

- (void)testDeleteToKeyPaths
{
    EKTestUser *testUser = [self testUser];
    EKTestUser *siblingUser = [self testUser];
    
    [siblingUser setUuid: @"0002"];
    [testUser setSiblingUser: siblingUser];
    
    NSArray *keyPaths = @[NSStringFromSelector(@selector(siblingUser))];
    EKTestUser *testUserCopy = [testUser copyToKeyPaths: keyPaths];
    [testUserCopy deleteToKeyPaths: keyPaths];
    
    NSMutableDictionary *usersByUUID = [NSMutableDictionary dictionary];
    NSArray *users = [EKTestUser all];
    for (EKTestUser *user in users)
    {
        if (![usersByUUID objectForKey: [user uuid]])
        {
            [usersByUUID setObject: @[] forKey: [user uuid]];
        }
        
        NSMutableArray *usersForUUID = [[usersByUUID objectForKey: [user uuid]] mutableCopy];
        [usersForUUID addObject: user];
        [usersByUUID setObject: usersForUUID forKey: [user uuid]];
    }
    
    XCTAssertTrue([[usersByUUID objectForKey: @"0001"] count] == 1, @"[[usersByUUID objectForKey: 0001] count] == %d", [[usersByUUID objectForKey: @"0001"] count]);
    XCTAssertTrue([[usersByUUID objectForKey: @"0002"] count] == 1, @"[[usersByUUID objectForKey: 0002] count] == %d", [[usersByUUID objectForKey: @"0002"] count]);
}

@end
