//
//  EKEnumerations.h
//  ErlenmeyerKit
//
//  Created by Patrick Perini on 7/28/13.
//

#pragma mark - External Macros
/*!
 *  DOCME
 */
#define EKEnum(EnumName, EnumValues...)                                                                                                     \
    typedef enum                                                                                                                            \
    {                                                                                                                                       \
        EnumValues                                                                                                                          \
    } EnumName;                                                                                                                             \
                                                                                                                                            \
    static NSString *__EK##EnumName##Constants = @"" #EnumValues;                                                                           \
    __EKEnumDefine(EnumName)

#pragma mark - Internal Macros
/*!
 *  DOCME
 */
#define __EKEnumDefine(EnumName)                                                                                                            \
    static NSDictionary *__EK##EnumName##ValuesByName()                                                                                     \
    {                                                                                                                                       \
        NSArray *valueNameStrings = [__EK##EnumName##Constants componentsSeparatedByString: @","];                                          \
        NSMutableDictionary *valuesByName = [NSMutableDictionary dictionary];                                                               \
                                                                                                                                            \
        NSInteger lastValue = -1;                                                                                                           \
        for (NSString *valueNameString in valueNameStrings)                                                                                 \
        {                                                                                                                                   \
            NSArray *valueNamePair = [valueNameString componentsSeparatedByString: @"="];                                                   \
            id value;                                                                                                                       \
            if ([valueNamePair count] > 1)                                                                                                  \
            {                                                                                                                               \
                value = [[valueNamePair objectAtIndex: 1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];        \
                lastValue = [value integerValue];                                                                                           \
            }                                                                                                                               \
            else                                                                                                                            \
            {                                                                                                                               \
                lastValue++;                                                                                                                \
            }                                                                                                                               \
            value = @(lastValue);                                                                                                           \
                                                                                                                                            \
            [valuesByName setObject: value forKey: [valueNamePair objectAtIndex: 0]];                                                                                   \
        }                                                                                                                                   \
                                                                                                                                            \
        return (NSDictionary *)valuesByName;                                                                                                \
    }                                                                                                                                       \
                                                                                                                                            \
    static NSDictionary *__EK##EnumName##NamesByValue()                                                                                     \
    {                                                                                                                                       \
        NSArray *valueNameStrings = [__EK##EnumName##Constants componentsSeparatedByString: @","];                                          \
        NSMutableDictionary *namesByValue = [NSMutableDictionary dictionary];                                                               \
                                                                                                                                            \
        NSInteger lastValue = -1;                                                                                                           \
        for (NSString *valueNameString in valueNameStrings)                                                                                 \
        {                                                                                                                                   \
            NSArray *valueNamePair = [valueNameString componentsSeparatedByString: @"="];                                                   \
            NSString *name = [[valueNamePair objectAtIndex: 0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];   \
                                                                                                                                            \
            id value;                                                                                                                       \
            if ([valueNamePair count] > 1)                                                                                                  \
            {                                                                                                                               \
                value = [[valueNamePair objectAtIndex: 1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];        \
                lastValue = [value integerValue];                                                                                           \
            }                                                                                                                               \
            else                                                                                                                            \
            {                                                                                                                               \
                lastValue++;                                                                                                                \
            }                                                                                                                               \
            value = @(lastValue);                                                                                                           \
                                                                                                                                            \
            [namesByValue setObject: name forKey: value];                                                                                   \
        }                                                                                                                                   \
                                                                                                                                            \
        return (NSDictionary *)namesByValue;                                                                                                \
    }                                                                                                                                       \
                                                                                                                                            \
    __EKEnumStringConversionFunctionsDefine(EnumName);                                                                                      \
    __EKEnumIntegerConversionFunctionsDefine(EnumName);                                                                                     \
    __EKEnumNSStringCategoryDefine(EnumName);                                                                                               \


/*!
 *  DOCME
 */
#define __EKEnumStringConversionFunctionsDefine(EnumName)                                                                                   \
    static NSString *NSStringFrom##EnumName(EnumName value)                                                                                 \
    {                                                                                                                                       \
        id valueObject = @(value);                                                                                                          \
        return [__EK##EnumName##NamesByValue() objectForKey: valueObject];                                                                  \
    }                                                                                                                                       \
                                                                                                                                            \
    static EnumName EnumName##FromString(NSString *string)                                                                                  \
    {                                                                                                                                       \
        id valueObject = [__EK##EnumName##ValuesByName() objectForKey: string];                                                             \
        return (EnumName)[valueObject integerValue];                                                                                        \
    }

/*!
 *  DOCME
 */
#define __EKIntegerConversionFunctionsDefine(EnumName)                                                                                      \
    static EnumName EnumName##FromInteger(NSInteger integer)                                                                                \
    {                                                                                                                                       \
        NSArray *enumValues = [[__EK##EnumName##ValuesByName() allValues] sortedArrayUsingSelector: @selector(compare:)];                   \
        EnumName closestWithoutGoingOver = INT_MIN;                                                                                         \
                                                                                                                                            \
        for (NSNumber *enumValue in enumValues)                                                                                             \
        {                                                                                                                                   \
            EnumName value = [enumValue integerValue];                                                                                      \
            if (value <= integer)                                                                                                           \
            {                                                                                                                               \
                closestWithoutGoingOver = value;                                                                                            \
            }                                                                                                                               \
        }                                                                                                                                   \
                                                                                                                                            \
        return closestWithoutGoingOver;                                                                                                     \
    }

/*!
 *  DOCME
 */
#define __EKNSStringCategoryDefine(EnumName)                                                                                            \
    @interface NSString (__EKEnum##EnumName##Extensions)                                                                                \
    - (EnumName)EnumName##Value;                                                                                                        \
    - (id)EnumName##ValueObject;                                                                                                        \
    @end                                                                                                                                \
                                                                                                                                        \
    @implementation NSString (__EKEnum##EnumName##Extensions)                                                                           \
    - (EnumName)EnumName##Value                                                                                                         \
    {                                                                                                                                   \
        return EnumName##FromString(self);                                                                                              \
    }                                                                                                                                   \
                                                                                                                                        \
    - (id)EnumName##ValueObject                                                                                                         \
    {                                                                                                                                   \
        return @([self EnumName##Value]);                                                                                               \
    }                                                                                                                                   \
    @end