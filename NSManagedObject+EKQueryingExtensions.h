//
//  NSManagedObject+EKQueryingExtensions.h
//  ErlenmeyerKit
//
//  Created by Patrick Perini on 7/28/13.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EKQueryingExtensions)

#pragma mark - Class Accessors
/*!
 *  DOCME
 */
+ (NSArray *)all;

/*!
 *  DOCME
 */
+ (void)allFromServer:(void(^)(NSArray *all, NSError *error))responseHandler where:(NSDictionary *)filter;

/*!
 *  DOCME
 */
+ (instancetype)get:(id)anID;

/*!
 *  DOCME
 */
+ (void)get:(id)anID fromServer:(void(^)(NSManagedObject *object, NSError *error))responseHandler;

#pragma mark - Class Mutators
/*!
 *  DOCME
 */
+ (void)deleteAll;

/*!
 *  DOCME
 */
+ (void)saveAll;

#pragma mark - Mutators
/*!
 *  DOCME
 */
- (void)saveToServer:(void(^)(NSError *error))responseHandler;

/*!
 *  DOCME
 */
- (void)delete;

/*!
 *  DOCME
 */
- (void)deleteFromServer:(void(^)(NSError *error))responseHandler;

@end
