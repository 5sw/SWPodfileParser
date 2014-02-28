//
//  SWPodfileParserTests.m
//  SWPodfileParserTests
//
//  Created by Sven Weidauer on 18.02.14.
//  Copyright (c) 2014 Sven Weidauer. All rights reserved.
//

#import "SWPodfileScanner.h"

@interface SWPodfileParserTests : XCTestCase
@end

@implementation SWPodfileParserTests {
    SWPodfileScanner *scanner;
}

#pragma mark - Strings

- (void)testScanSingleQuoteString
{
    [self prepareScannerWithString: @"'test'"];
    [self assertValidString: @"test"];
}

- (void)testScanDoubleQuoteString
{
    [self prepareScannerWithString: @"\"test\""];
    [self assertValidString: @"test"];
}

- (void)testScanEscapedQuotes
{
    [self prepareScannerWithString: @"\"test\\\"string\""];
    [self assertValidString: @"test\"string"];
}

- (void)testScanEscapedBackslash
{
    [self prepareScannerWithString: @"\"test\\\\string\""];
    [self assertValidString: @"test\\string"];
}

- (void)testWhitespaceBeforeString
{
    [self prepareScannerWithString: @" 'testing'"];
    [self assertValidString: @"testing"];
}

#pragma mark Identifiers

- (void)testScanningIdentifier
{
    [self prepareScannerWithString: @"ident"];
    [self assertValidIdentifier: @"ident"];
}

- (void)testScanIdentifierWithDigits
{
    [self prepareScannerWithString: @"ident123"];
    [self assertValidIdentifier: @"ident123"];
}

- (void)testIdentifierCannotStartWithDigit
{
    [self prepareScannerWithString: @"123ident"];

    assertThatBool( [scanner scanIdentifier: NULL], is( @NO ) );
}

- (void)testIdentifierWithUnderscore
{
    [self prepareScannerWithString: @"_ident1_23"];
    [self assertValidIdentifier: @"_ident1_23"];
}

#pragma mark - Atoms

- (void)testScanAtom
{
    [self prepareScannerWithString: @":testing"];
    [self assertValidAtom: @"testing"];
}

- (void)testFailToScanAtomWithoutColon
{
    [self prepareScannerWithString: @"testing"];
    assertThatBool( [scanner scanAtom: nil], is( @NO ) );
}

- (void)testScanAtomWithQuotedString
{
    [self prepareScannerWithString: @":'test 123'"];
    [self assertValidAtom: @"test 123"];
}

- (void)testScanningAtomWithoutNameFails
{
    [self prepareScannerWithString: @":"];
    assertThatBool( [scanner scanAtom: NULL], is( @NO ) );
}

- (void)testFailedAtomLeavesRest
{
    [self prepareScannerWithString: @":123"];
    assertThatBool( [scanner scanAtom: NULL], is( @NO ) );
    assertThat( scanner.tailString, is( @":123" ) );
}

- (void)testIgnoringWhitespaceBeforeAtom
{
    [self prepareScannerWithString: @" :atom"];
    [self assertValidAtom: @"atom"];
}

- (void)testFailScanningAtomWithWhitespaceAfterColon
{
    [self prepareScannerWithString: @": atom2"];
    assertThatBool( [scanner scanAtom: NULL], is( @NO ) );
}

#pragma mark - Symbols

- (void)testScanComma
{
    [self prepareScannerWithString: @","];
    assertThatBool( [scanner scanComma], is( @YES ) );
}

- (void)testScanArrow
{
    [self prepareScannerWithString: @"=>"];
    assertThatBool( [scanner scanArrow], is( @YES ) );
}

- (void)testScanArrowFailsWithWhitespaceBetween
{
    [self prepareScannerWithString: @"= >"];
    assertThatBool( [scanner scanArrow], is( @NO ) );
}

- (void)testScanArrowWithWhitespaceBefore
{
    [self prepareScannerWithString: @" \t=>"];
    assertThatBool( [scanner scanArrow], is( @YES ) );
}

#pragma mark - Misc

- (void)testTailString
{
    [self prepareScannerWithString: @"some random string"];
    assertThat( scanner.tailString, is( @"some random string" ) );
}

#pragma mark - Helpers

- (void)prepareScannerWithString: (NSString *)testString
{
    scanner = [[SWPodfileScanner alloc] initWithString: testString];
}

- (void)assertValidIdentifier: (NSString *)identifier
{
    NSString *result = nil;
    assertThatBool( [scanner scanIdentifier: &result], is( @YES ) );
    assertThat( result, is( identifier ) );
}

- (void)assertValidAtom: (NSString *)atom
{
    NSString *result = nil;
    assertThatBool( [scanner scanAtom: &result], is( @YES ) );
    assertThat( result, is( atom ) );
}

- (void)assertValidString: (NSString *)string
{
    NSString *result = nil;
    assertThatBool( [scanner scanString: &result], is( @YES ) );
    assertThat( result, is( string ) );
}

@end
