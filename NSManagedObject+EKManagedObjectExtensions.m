//
//  NSManagedObject+EKManagedObjectExtensions.m
//  
//
//  Created by Patrick Perini on 7/28/13.
//
//

#import "NSManagedObject+EKManagedObjectExtensions.h"
#import "NSManagedObject+EKQueryingExtensions.h"
#import <objc/message.h>

#pragma mark - External Constants
NSString *const EKPrimitiveTypeKey = @"EKPrimitiveType";

#pragma mark - Internal Constants
/*!
 *  DOCME
 */
NSString *const EKPrimitiveTypeValueObjectSelectorFormat = @"%@ValueObject";

#pragma mark - Globals
/*!
 *  DOCME
 */
static NSString *serverURL = @"http://127.0.0.1:5000";

/*!
 *  DOCME
 */
static NSString *primaryKey = @"uuid";

@implementation NSManagedObject (EKManagedObjectExtensions)

#pragma mark - Class Accessors
+ (NSString *)serverURL
{
    return serverURL;
}

+ (NSString *)primaryKey
{
    return primaryKey;
}

#pragma mark - Class Mutators
+ (void)setServerURL:(NSString *)aURL
{
    serverURL = [aURL copy];
}

+ (void)setPrimaryKey:(NSString *)aKey
{
    primaryKey = [aKey copy];
}

#pragma mark - Accessors
- (BOOL)hasValueForKey:(NSString *)key
{
    return [self respondsToSelector: @selector(key)];
}

- (BOOL)hasValueForKeyPath:(NSString *)keyPath
{
    NSArray *keyPathPieces = [keyPath componentsSeparatedByString: @"."];
    
    id value = self;
    for (NSString *key in keyPathPieces)
    {
        BOOL hasValueForKeyPath = [value hasValueForKey: key];
        if (!hasValueForKeyPath)
            return NO;
        
        value = [value valueForKey: key];
    }
    
    return YES;
}

- (NSDictionary *)dictionaryValue
{
    NSMutableSet *relationshipKeys = [NSMutableSet set];
    NSMutableArray *propertyKeys = [NSMutableArray array];
    for (NSString *key in [[[self entity] propertiesByName] allKeys])
    {
        NSPropertyDescription *propertyDescription = [[[self entity] propertiesByName] objectForKey: key];
        if ([propertyDescription isKindOfClass: [NSRelationshipDescription class]])
        {
            [relationshipKeys addObject: key];
            continue;
        }
        
        [propertyKeys addObject: key];
    }
    
    NSMutableDictionary *dictionaryValue = [[self dictionaryWithValuesForKeys: propertyKeys] mutableCopy];
    for (NSString *key in relationshipKeys)
    {
        NSString *keyPath = [NSString stringWithFormat: @"%@.%@", key, [[self class] primaryKey]];
        id value = [self valueForKeyPath: keyPath];
        
        if ([[[[self entity] relationshipsByName] objectForKey: key] isToMany])
        {
            value = [value allObjects];
        }
        else if (!value)
        {
            value = [NSNull null];
        }
        
        [dictionaryValue setObject: value forKey: key];
    }
    
    return (NSDictionary *)dictionaryValue;
}

#pragma mark - Mutators
- (void)addEntriesFromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in dictionary)
    {
        id value = [dictionary objectForKey: key];
        if ([value isKindOfClass: [NSNull class]])
            continue;
        
        // Add relationships
        if ([[[[self entity] relationshipsByName] allKeys] containsObject: key])
        {
            NSRelationshipDescription *relationshipDescription = [[[self entity] relationshipsByName] objectForKey: key];
            Class objectClass = NSClassFromString([[relationshipDescription destinationEntity] managedObjectClassName]);
            
            if ([relationshipDescription isToMany])
            {
                // Coerce value's type. Assume it's a string, as its rare to have to coerce from another type.
                if ([value isKindOfClass: [NSString class]])
                {
                    value = [value componentsSeparatedByString: @","];
                }
                
                for (id objectID in value)
                {
                    id object = [objectClass get: objectID];
                    if (!object)
                        continue;
                    
                    [[self mutableSetValueForKey: key] addObject: object];
                }
                
                continue;
            }
            
            value = [objectClass get: value];
        }
        
        // Refine attributes
        else
        {
            // Coerce value's type. Assume it's a string, as its rare to have to coerce from another type.
            NSAttributeDescription *attributeDescription = [[[self entity] attributesByName] objectForKey: key];
            if (![value isKindOfClass: NSClassFromString([attributeDescription attributeValueClassName])])
            {
                if ([[attributeDescription attributeValueClassName] isEqualToString: NSStringFromClass([NSNumber class])]) // Numbers
                {
                    if ([[[attributeDescription userInfo] allKeys] containsObject: EKPrimitiveTypeKey]) // Custom Primitives
                    {
                        NSString *primitiveTypeName = [[attributeDescription userInfo] objectForKey: EKPrimitiveTypeKey];
                        SEL primitiveTypeValueSelector = NSSelectorFromString([NSString stringWithFormat: EKPrimitiveTypeValueObjectSelectorFormat, primitiveTypeName]);
                        
                        if ([value respondsToSelector: primitiveTypeValueSelector])
                        {
                            value = objc_msgSend(value, primitiveTypeValueSelector);
                        }
                    }
                    else if ([attributeDescription attributeType] == NSBooleanAttributeType)
                    {
                        value = @([value boolValue]);
                    }
                    else
                    {
                        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                        value = [numberFormatter numberFromString: value];
                    }
                }
                else if ([[attributeDescription attributeValueClassName] isEqualToString: NSStringFromClass([NSData class])]) // Data
                {
                    value = [value dataUsingEncoding: NSUTF8StringEncoding];
                }
            }
        }
        
        if (value)
        {
            [self setValue: value
                    forKey: key];
        }
    }
    
    [self awakeFromLoad];
}

- (void)realizeFromFault
{
    [self willAccessValueForKey: nil];
}

- (void)awakeFromLoad
{
    // Do nothing
}

@end
