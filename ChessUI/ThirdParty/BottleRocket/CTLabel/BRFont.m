//
//  BRFont.m
//  UIPlayground
//
//  Created by Austen Green on 7/1/11.
//  Copyright (c) 2011 Bottle Rocket Apps. All rights reserved.
//

#import "BRFont.h"

CTFontRef CTFontCreateWithUIFont(UIFont *font)
{
    CTFontRef ctfont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    return ctfont;
}

CGFontRef CGFontCreateWithUIFont(UIFont *font)
{
    CGFontRef cgfont = CGFontCreateWithFontName((CFStringRef)font.fontName);
    return cgfont;
}

@implementation UIFont (BRFont)
+ (UIFont *)fontWithCTFont:(CTFontRef)font
{
    CFStringRef fontName = CTFontCopyFamilyName(font);
    CGFloat pointSize = CTFontGetSize(font);
    
    UIFont *uifont = [UIFont fontWithName:(NSString *)fontName size:pointSize];
    CFRelease(fontName);
    return uifont;
}

+ (UIFont *)fontWithCGFont:(CGFontRef)font
{
    CFStringRef fontName = CGFontCopyFullName(font);

    UIFont *uifont = [UIFont fontWithName:(NSString *)fontName size:0.0];
    CFRelease(fontName);
    return uifont;
}

@end