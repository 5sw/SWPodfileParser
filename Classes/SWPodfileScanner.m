//
//  SWPodfileScanner.m
//  SWPodfileParser
//
//  Created by Sven Weidauer on 18.02.14.
//  Copyright (c) 2014 Sven Weidauer. All rights reserved.
//

#import "SWPodfileScanner.h"

@interface SWPodfileScanner ()

@property (strong, nonatomic) NSScanner *scanner;

@end

@implementation SWPodfileScanner

- (instancetype)initWithString:(NSString *)string
{
    NSParameterAssert( string );

    self = [super init];
    if (!self) return nil;

    _scanner = [[NSScanner alloc] initWithString: string];
    _scanner.charactersToBeSkipped = nil;

    return self;
}

- (BOOL)scanString: (NSString **)outString
{
    [self skipWhitespace];

    return [self tryScan: ^{
        NSString *end = nil;

        if ([self.scanner scanString: @"\"" intoString: NULL]) {
            end = @"\"";
        } else if ([self.scanner scanString: @"'" intoString: NULL]) {
            end = @"'";
        } else {
            return NO;
        }

        NSMutableCharacterSet *set = [NSMutableCharacterSet characterSetWithRange: NSMakeRange( '\\', 1 )];
        [set addCharactersInString: end];

        NSMutableString *result = [NSMutableString string];
        for (;;) {
            NSString *part = nil;
            if ([self.scanner scanUpToCharactersFromSet: set intoString: &part]) {
                [result appendString: part];
            }

            if ([self.scanner scanString: end intoString: NULL]) {
                break;
            } if ([self.scanner scanString: @"\\" intoString: NULL]) {
                if ([self.scanner scanString: @"\\" intoString: NULL]) {
                    [result appendString: @"\\"];
                } else if ([self.scanner scanString: end intoString: NULL]) {
                    [result appendString: end];
                }
            } else {
                return NO;
            }
        }

        if (outString) {
            *outString = [result copy];
        }

        return  YES;
    }];
}

- (BOOL)scanIdentifier: (NSString **)outIdentifier
{
    NSMutableCharacterSet *letters = [NSMutableCharacterSet letterCharacterSet];
    [letters addCharactersInString: @"_"];

    NSMutableCharacterSet *lettersAndDigits = [NSMutableCharacterSet decimalDigitCharacterSet];
    [lettersAndDigits formUnionWithCharacterSet: letters];

    NSString *result = nil;

    if (![self.scanner scanCharactersFromSet: letters intoString: &result]) {
        return NO;
    }

    NSString *partTwo = nil;
    if ([self.scanner scanCharactersFromSet: lettersAndDigits intoString: &partTwo]) {
        result = [result stringByAppendingString: partTwo];
    }

    if (outIdentifier) {
        *outIdentifier = result;
    }

    return YES;
}

- (BOOL)scanAtom:(NSString **)outAtom
{
    [self skipWhitespace];

    return [self tryScan: ^{
        if (![self.scanner scanString: @":" intoString: NULL]) {
            return NO;
        }

        NSString *result = nil;
        if (![self scanIdentifier: &result] && ![self scanString: &result]) {
            return NO;
        }

        if (outAtom) {
            *outAtom = result;
        }
        
        return YES;
    }];
}

- (NSString *)tailString
{
    return [self.scanner.string substringFromIndex: self.scanner.scanLocation];
}

- (BOOL)tryScan: (BOOL (^)())block
{
    NSParameterAssert( block );

    NSUInteger scanLocation = self.scanner.scanLocation;

    BOOL result = block();

    if (!result) {
        self.scanner.scanLocation = scanLocation;
    }

    return result;
}

- (BOOL)scanComma
{
    [self skipWhitespace];
    return [self.scanner scanString: @"," intoString: NULL];
}

- (BOOL)scanArrow
{
    [self skipWhitespace];
    return [self.scanner scanString: @"=>" intoString: NULL];
}

- (void)skipWhitespace
{
    [self.scanner scanCharactersFromSet: [NSCharacterSet whitespaceCharacterSet] intoString: NULL];
}

@end
