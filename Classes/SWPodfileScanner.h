//
//  SWPodfileScanner.h
//  SWPodfileParser
//
//  Created by Sven Weidauer on 18.02.14.
//  Copyright (c) 2014 Sven Weidauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWPodfileScanner : NSObject

- (instancetype)initWithString: (NSString *)string;

- (BOOL)scanString: (NSString **)outString;

- (BOOL)scanIdentifier: (NSString **)outIdentifier;

- (BOOL)scanAtom: (NSString **)outAtom;

- (BOOL)scanComma;
- (BOOL)scanArrow;

@property (readonly, nonatomic) NSString *tailString;

@end
