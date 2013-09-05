//
//  NSManagedObject+EKCopyingExtensions.m
//  
//
//  Created by Patrick Perini on 7/28/13.
//
//

#import "NSManagedObject+EKCopyingExtensions.h"
#import "NSManagedObject+EKQueryingExtensions.h"

@implementation NSManagedObject (EKCopyingExtensions)

#pragma mark - Accessors
- (id)copyWithZone:(NSZone *)zone
{
    id newObject = [[[self class] alloc] init];
    
    // Add attributes
    for (NSString *attributeName in [[self entity] attributesByName])
    {
        id attributeValue = [[self valueForKey: attributeName] copy];
        if (!attributeValue)
            continue;
        
        [newObject setValue: attributeValue
                     forKey: attributeName];
    }
    
    // Do not add relationships. In order to add relationships, use -copyToKeyPaths:
    
    return newObject;
}

- (instancetype)copyToKeyPaths:(NSArray *)keyPaths
{
    // Copy self
    id newObject = [self copy];
    
    // Find the top-most key in each key path, for use at this recursion level
    NSMutableDictionary *keyPathSets = [NSMutableDictionary dictionary];
    for (NSString *keyPath in keyPaths)
    {
        NSMutableArray *keyPathPieces = [[keyPath componentsSeparatedByString: @"."] mutableCopy];
        NSString *propertyKey = [keyPathPieces objectAtIndex: 0];
        
        if (![[keyPathSets allKeys] containsObject: propertyKey])
        {
            [keyPathSets setObject: [NSMutableArray array]
                            forKey: propertyKey];
        }
        
        [keyPathPieces removeObjectAtIndex: 0];
        if ([keyPathPieces count] > 0)
        {
            [[keyPathSets objectForKey: propertyKey] addObject: [keyPath componentsSeparatedByString: @"."]];
        }
    }
    
    for (NSString *propertyKey in keyPathSets)
    {
        // The property key is invalid
        if (![[[[self entity] relationshipsByName] allKeys] containsObject: propertyKey])
            continue;
        
        NSRelationshipDescription *relationshipDescription = [[[self entity] relationshipsByName] objectForKey: propertyKey];
        if ([relationshipDescription isToMany])
        {
            NSSet *subObjects = [[self valueForKeyPath: propertyKey] copy];
            NSMutableSet *newSubObjects = [NSMutableSet set];
            for (id subObject in subObjects)
            {
                id newSubObject = [[self valueForKey: propertyKey] copyToKeyPaths: [keyPathSets objectForKey: propertyKey]];
                [newSubObjects addObject: newSubObject];
            }
            
            [newObject setValue: newSubObjects
                         forKey: propertyKey];
        }
        else // to-one
        {
            id newSubObject = [[self valueForKey: propertyKey] copyToKeyPaths: [keyPathSets objectForKey: propertyKey]];
            [newObject setValue: newSubObject
                         forKey: propertyKey];
        }
    }
    
    return newObject;
}

#pragma mark - Mutators
- (void)deleteToKeyPaths:(NSArray *)keyPaths
{
    // Find the top-most key in each key path, for use at this recursion level
    NSMutableDictionary *keyPathSets = [NSMutableDictionary dictionary];
    for (NSString *keyPath in keyPaths)
    {
        NSMutableArray *keyPathPieces = [[keyPath componentsSeparatedByString: @"."] mutableCopy];
        NSString *propertyKey = [keyPathPieces objectAtIndex: 0];
        
        if (![[keyPathSets allKeys] containsObject: propertyKey])
        {
            [keyPathSets setObject: [NSMutableArray array]
                            forKey: propertyKey];
        }
        
        [keyPathPieces removeObjectAtIndex: 0];
        if ([keyPathPieces count] > 0)
        {
            [[keyPathSets objectForKey: propertyKey] addObject: [keyPath componentsSeparatedByString: @"."]];
        }
    }
    
    for (NSString *propertyKey in keyPathSets)
    {
        // The property key is invalid
        if (![[[[self entity] relationshipsByName] allKeys] containsObject: propertyKey])
            continue;
        
        NSRelationshipDescription *relationshipDescription = [[[self entity] relationshipsByName] objectForKey: propertyKey];
        if ([relationshipDescription isToMany])
        {
            NSSet *subObjects = [[self valueForKeyPath: propertyKey] copy];
            for (id subObject in subObjects)
            {
                [subObject deleteToKeyPaths: [keyPathSets objectForKey: propertyKey]];
            }
        }
        else // to-one
        {
            [[self valueForKey: propertyKey] deleteToKeyPaths: [keyPathSets objectForKey: propertyKey]];
        }
    }
    
    [self delete];
}

@end