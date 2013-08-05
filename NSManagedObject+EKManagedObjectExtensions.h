//
//  NSManagedObject+EKManagedObjectExtensions.h
//  ErlenmeyerKit
//
//  Created by Patrick Perini on 7/28/13.
//

#import <CoreData/CoreData.h>

#pragma mark - External Constants
/*!
 *  DOCME
 */
extern NSString *const EKPrimitiveTypeKey;

@interface NSManagedObject (EKManagedObjectExtensions)

#pragma mark - Class Accessors
/*!
 *  DOCME
 */
+ (NSString *)serverURL;

/*!
 *  DOCME
 */
+ (NSString *)primaryKey;

#pragma mark - Class Mutators
/*!
 *  DOCME
 */
+ (void)setServerURL:(NSString *)serverURL;

/*!
 *  DOCME
 */
+ (void)setPrimaryKey:(NSString *)primaryKey;

#pragma mark - Accessors
/*!
 *  DOCME
 */
- (NSDictionary *)dictionaryValue;

#pragma mark - Mutators
/*!
 *  DOCME
 */
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary;

/*!
 *  DOCME
 */
- (void)realizeFromFault;

/*!
 *  DOCME
 */
- (void)awakeFromLoad;

@end
