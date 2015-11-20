//
//  NSString+Utility.h
//  KTV
//
//  Created by admin on 15/10/12.
//  Copyright © 2015年 stevenhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utility)
+ (NSString*)encodeBase64WithString:(NSString*)decodestr;
+ (NSString*)decodeBase64WithString:(NSString*)encodeStr;
- (NSString*)encodeBase64;
- (NSString*)decodeBase64;

#pragma mark - chinease to pinyi
- (NSString *) pinyin;
- (NSString *) pinyinInitial;
- (NSInteger)indexOfString:(NSString *)s;
- (NSInteger)indexOfString:(NSString *)s fromIndex:(int)index;
- (NSInteger)indexOf:(int)ch;
- (NSInteger)indexOf:(int)ch fromIndex:(int)index;
+ (NSString *)valueOfChar:(unichar)value;

-(NSString *) stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement;
-(NSString *) stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase;
-(NSString *) stringByReplacingRegexPattern:(NSString *)regex withString:(NSString *) replacement caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(NSArray *) stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex;
-(NSArray *) stringsByExtractingGroupsUsingRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
-(BOOL) matchesPatternRegexPattern:(NSString *)regex;
-(BOOL) matchesPatternRegexPattern:(NSString *)regex caseInsensitive:(BOOL) ignoreCase treatAsOneLine:(BOOL) assumeMultiLine;
- (BOOL)isIpAddress;
@end
