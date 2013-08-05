//
//  NSManagedObject+EKCopyingExtensions.h
//  ErlenmeyerKit
//
//  Created by Patrick Perini on 7/28/13.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EKCopyingExtensions) <NSCopying>

#pragma mark - Accessors
/*!
 *  DOCME
 */
- (instancetype)copyToKeyPaths:(NSArray *)keyPaths;

#pragma mark - Mutators
/*!
 *  DOCME
 */
- (void)deleteToKeyPaths:(NSArray *)keyPaths;

@end
