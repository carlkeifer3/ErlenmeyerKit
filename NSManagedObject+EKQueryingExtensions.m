//
//  NSManagedObject+EKQueryingExtensions.m
//  ErlenmeyerKitTests
//
//  Created by Patrick Perini on 7/28/13.
//  Copyright (c) 2013 MegaBits. All rights reserved.
//

#import "NSManagedObject+EKQueryingExtensions.h"
#import "NSManagedObject+EKManagedObjectExtensions.h"
#import "PCHTTP.h"

#pragma mark - Internal Constants
/*!
 *  DOCME
 */
NSString *const EKServerErrorDomain = @"EKServerErrorDomain";

@interface NSManagedObject (EKQueryingPrivateExtensions)

#pragma mark - Class Accessors
/*!
 *  DOCME
 */
+ (NSManagedObjectContext *)sharedManagedObjectContext;

/*!
 *  DOCME
 */
+ (NSManagedObjectModel *)sharedManagedObjectModel;

/*!
 *  DOCME
 */
+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator;

/*!
 *  DOCME
 */
+ (NSArray *)allMatchingPredicateString:(NSString *)predicateString limit:(NSInteger)limit;

#pragma mark - Class Error Handlers
/*!
 *  DOCME
 */
+ (void)throwExceptionForError:(NSError *)error;

@end

#pragma mark - Globals
/*!
 *  DOCME
 */
static NSManagedObjectContext *sharedManagedObjectContext;

/*!
 *  DOCME
 */
static NSManagedObjectModel *sharedManagedObjectModel;

/*!
 *  DOCME
 */
 static NSPersistentStoreCoordinator *sharedPersistentStoreCoordinator;

@implementation NSManagedObject (EKQueryingExtensions)

#pragma mark - Class Accessors
+ (NSManagedObjectContext *)sharedManagedObjectContext
{
    if (!sharedManagedObjectContext)
    {
        sharedManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [sharedManagedObjectContext setPersistentStoreCoordinator: [self sharedPersistentStoreCoordinator]];
    }
    
    return sharedManagedObjectContext;
}

+ (NSManagedObjectModel *)sharedManagedObjectModel
{
    if (!sharedManagedObjectModel)
    {
        NSMutableArray *allBundles = [NSMutableArray array];
        [allBundles addObjectsFromArray: [NSBundle allBundles]];
        [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
        sharedManagedObjectModel = [NSManagedObjectModel mergedModelFromBundles: allBundles];
    }
    
    return sharedManagedObjectModel;
}

+ (NSPersistentStoreCoordinator *)sharedPersistentStoreCoordinator
{
    if (!sharedPersistentStoreCoordinator)
    {
        NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory
                                                                                      inDomains: NSUserDomainMask] lastObject];
        NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent: @"NSManagedObjects.sqlite"];
        
        NSError *error;
        sharedPersistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self sharedManagedObjectModel]];
        [sharedPersistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                       configuration: nil
                                                                 URL: storeURL
                                                             options: nil
                                                               error: &error];
        [self throwExceptionForError: error];
    }
    
    return sharedPersistentStoreCoordinator;
}

+ (NSArray *)all
{
    return [self allMatchingPredicateString: nil limit: 0];
}

+ (NSArray *)allMatchingPredicateString:(NSString *)predicateString limit:(NSInteger)limit
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: NSStringFromClass(self)
                                                         inManagedObjectContext: [self sharedManagedObjectContext]];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: entityDescription];
    
    if (predicateString)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
        [fetchRequest setPredicate: predicate];
    }
    
    [fetchRequest setFetchLimit: limit];
    
    NSError *error;
    NSArray *results = [[self sharedManagedObjectContext] executeFetchRequest: fetchRequest
                                                                        error: &error];
    [self throwExceptionForError: error];
    [results makeObjectsPerformSelector: @selector(realizeFromFault)];
    
    return results;
}

+ (void)allFromServer:(void (^)(NSArray *, NSError *))responseHandler where:(NSDictionary *)filter
{    
    NSString *allRequestURL = [NSString stringWithFormat: @"%@/%@s", [self serverURL], self];
    PCHTTPResponseBlock allRequestResponseHandler = ^(PCHTTPResponse *response)
    {
        switch ([response status])
        {
            case PCHTTPResponseStatusOK:
                break;
                
            default:
            {
                NSError *error = [NSError errorWithDomain: EKServerErrorDomain
                                                     code: [response status]
                                                 userInfo: nil];
                responseHandler(nil, error);
                return;
            }
        }
        
        NSMutableArray *objects = [NSMutableArray array];
        for (NSDictionary *responseObject in [response object])
        {
            id primaryKeyValue = [responseObject objectForKey: [self primaryKey]];
            NSManagedObject *object = [self get: primaryKeyValue];
            if (!object)
            {
                object = [[self alloc] init];
            }
            
            [object addEntriesFromDictionary: responseObject];
            [objects addObject: object];
        }
        
        responseHandler(objects, nil);
    };
    
    [PCHTTPClient get: allRequestURL
           parameters: filter
      responseHandler: allRequestResponseHandler];
}

+ (instancetype)get:(id)anID
{
    NSString *predicateString = [NSString stringWithFormat: @"%@ == \"%@\"", [self primaryKey], anID];
    NSArray *results = [self allMatchingPredicateString: predicateString limit: 1];
    
    if ([results count] <= 0)
        return nil;
    
    return [results objectAtIndex: 0];
}

+ (void)get:(id)anID fromServer:(void (^)(NSManagedObject *, NSError *))responseHandler
{
    void (^allResponseHandler)(NSArray *, NSError *) = ^void (NSArray *all, NSError *error)
    {
        if ([all count] > 0)
        {
            responseHandler([all objectAtIndex: 0], error);
            return;
        }
        
        responseHandler(nil, error);
    };
    
    [self allFromServer: allResponseHandler where: @{[[self class] primaryKey]: anID}];
}

#pragma mark - Class Mutators
+ (void)deleteAll
{
    // Check to make sure the calling class is NSManagedObject, and not a subclass.
    if (![NSStringFromClass(self) isEqualToString: NSStringFromClass([NSManagedObject class])])
    {
        [self doesNotRecognizeSelector: _cmd];
        return;
    }
    
    for (NSPersistentStore *persistentStore in [[self sharedPersistentStoreCoordinator] persistentStores])
    {
        [[self sharedPersistentStoreCoordinator] removePersistentStore: persistentStore
                                                           error: nil];
        
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL: [persistentStore URL]
                                                  error: &error];
        [self throwExceptionForError: error];
    }
    
    // Flag for reestablishment.
    sharedManagedObjectModel = nil;
    sharedPersistentStoreCoordinator = nil;
    sharedManagedObjectContext = nil;
}

+ (void)saveAll
{
    // Check to make sure the calling class is NSManagedObject, and not a subclass.
    if (![NSStringFromClass(self) isEqualToString: NSStringFromClass([NSManagedObject class])])
    {
        [self doesNotRecognizeSelector: _cmd];
        return;
    }
    
    if ([[[self class] sharedManagedObjectContext] hasChanges])
    {
        NSError *error;
        [[[self class] sharedManagedObjectContext] save: &error];
        [[self class] throwExceptionForError: error];
    }
}

#pragma mark - Class Error Handlers
+ (void)throwExceptionForError:(NSError *)error
{
    if (!error)
        return;
    
    NSException *errorException = [NSException exceptionWithName: [error domain]
                                                          reason: [error localizedDescription]
                                                        userInfo: [error userInfo]];
    [errorException raise];
}

#pragma mark - Initializers
- (id)init
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName: NSStringFromClass([self class])
                                                         inManagedObjectContext: [[self class] sharedManagedObjectContext]];
    self = [self initWithEntity: entityDescription insertIntoManagedObjectContext: [[self class] sharedManagedObjectContext]];
    if (!self)
        return nil;
    
    return self;
}

#pragma mark - Mutators
- (void)saveToServer:(void (^)(NSError *))responseHandler
{
    // Add PUT requests
    NSString *saveRequestURL;
    
    PCHTTPBatchClient *batchClient = [[PCHTTPBatchClient alloc] init];
    
    for (NSString *relationshipKey in [[self entity] relationshipsByName])
    {
        NSRelationshipDescription *relationshipDescription = [[[self entity] relationshipsByName] objectForKey: relationshipKey];
        if ([relationshipDescription isToMany])
        {
            for (NSManagedObject *relationshipValue in [self valueForKey: relationshipKey])
            {
                saveRequestURL = [NSString stringWithFormat: @"%@/%@s", [[relationshipValue class] serverURL], [relationshipValue class]];
                
                NSMutableDictionary *relationshipValueDictionary = [[relationshipValue dictionaryValue] mutableCopy];
                [relationshipValueDictionary removeObjectsForKeys: [[[relationshipValue entity] relationshipsByName] allKeys]];
                
                [batchClient addPutRequest: saveRequestURL
                                   payload: relationshipValueDictionary];
            }
        }
        else
        {
            NSManagedObject *relationshipValue = [self valueForKey: relationshipKey];
            saveRequestURL = [NSString stringWithFormat: @"%@/%@s", [[relationshipValue class] serverURL], [relationshipValue class]];
            
            NSMutableDictionary *relationshipValueDictionary = [[relationshipValue dictionaryValue] mutableCopy];
            [relationshipValueDictionary removeObjectsForKeys: [[[relationshipValue entity] relationshipsByName] allKeys]];
            
            [batchClient addPutRequest: saveRequestURL
                               payload: relationshipValueDictionary];
        }
    }
    
    saveRequestURL = [NSString stringWithFormat: @"%@/%@s", [[self class] serverURL], [self class]];
    [batchClient addPutRequest: saveRequestURL
                       payload: [self dictionaryValue]];
    
    // Establish response handler
    PCHTTPBatchResponseBlock saveRequestResponseHandler = ^(NSArray *responses)
    {
        for (PCHTTPResponse *response in responses)
        {
            switch ([response status])
            {
                case PCHTTPResponseStatusOK:
                    break;
                    
                default:
                {
                    NSError *error = [NSError errorWithDomain: EKServerErrorDomain
                                                         code: [response status]
                                                     userInfo: nil];
                    responseHandler(error);
                    return;
                }
            }
        }
        
        responseHandler(nil);
    };
    
    [batchClient performRequestsWithResponseHandler: saveRequestResponseHandler];
}

- (void)delete
{
    [[[self class] sharedManagedObjectContext] deleteObject: self];
}

- (void)deleteFromServer:(void (^)(NSError *))responseHandler
{
    NSString *deleteRequestURL = [NSString stringWithFormat: @"%@/%@s/%@", [[self class] serverURL], [self class], [self valueForKey: [[self class] primaryKey]]];
    PCHTTPResponseBlock deleteRequestResponseHandler = ^(PCHTTPResponse *response)
    {
        switch ([response status])
        {
            case PCHTTPResponseStatusOK:
                break;
                
            default:
            {
                NSError *error = [NSError errorWithDomain: EKServerErrorDomain
                                                     code: [response status]
                                                 userInfo: nil];
                responseHandler(error);
                return;
            }
        }
        
        responseHandler(nil);
    };
    
    [PCHTTPClient delete: deleteRequestURL
         responseHandler: deleteRequestResponseHandler];
}

@end