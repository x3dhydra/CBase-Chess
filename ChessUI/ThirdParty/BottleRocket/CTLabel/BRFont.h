//
//  BRFont.h
//  UIPlayground
//
//  Created by Austen Green on 7/1/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

CTFontRef CTFontCreateWithUIFont(UIFont *font);
CGFontRef CGFontCreateWithUIFont(UIFont *font);

@interface UIFont (BRFont)

+ (UIFont *)fontWithCTFont:(CTFontRef) font;
+ (UIFont *)fontWithCGFont:(CGFontRef) font;

@end