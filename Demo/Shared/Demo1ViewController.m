//
//  Demo1ViewController.m
//  CMPopTipView
//
//  Created by Chris Miles on 13/11/10.
//  Copyright (c) Chris Miles 2010.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Demo1ViewController.h"

#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]
#define foo4random() (1.0 * (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX)
#define LzyReferenceW 375.0
#define LzyReferenceH 667.0// 注意修改参考比例
#define LZYFitX (LzyScreenWidth / LzyReferenceW)
#define LZYFitY (LzyScreenHeight / LzyReferenceH)
#define LzyScreenWidth      CGRectGetWidth([UIScreen mainScreen].bounds)
#define LzyScreenHeight      CGRectGetHeight([UIScreen mainScreen].bounds)


//字号宏定义，不要求字体粗细等
//#define FONT_SIZE(size) ([UIFont systemFontOfSize:FontSize(size)])

/**
 *  字号适配
 */
static inline CGFloat FontSize(CGFloat fontSize){
    if (LzyScreenWidth == 320) {
        return fontSize - 2;
    }else if (LzyScreenWidth == 375){
        return fontSize;
    }else{
        return fontSize + 2;
    }
}
/* lzy171118注:
 字体宏定义，返回特定字体粗细和字号适配
 */
#define Font_Regular(s)  (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?[UIFont fontWithName:@"PingFangSC-Regular" size:FontSize(s)]:[UIFont fontWithName:@"HelveticaNeue" size:FontSize(s)])

#define Font_Light(s)   (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?[UIFont fontWithName:@"PingFangSC-Light" size:FontSize(s)]:[UIFont fontWithName:@"HelveticaNeue-Light" size:FontSize(s)])

#define Font_Medium(s)   (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?[UIFont fontWithName:@"PingFangSC-Medium" size:FontSize(s)]:[UIFont fontWithName:@"HelveticaNeue-Medium" size:FontSize(s)])

#define Font_Semibold(s)   (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?[UIFont fontWithName:@"PingFangSC-Semibold" size:FontSize(s)]:[UIFont fontWithName:@"HelveticaNeue-Bold" size:FontSize(s)])

#define Font_Thin(s)   (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")?[UIFont fontWithName:@"PingFangSC-Thin" size:FontSize(s)]:[UIFont fontWithName:@"HelveticaNeue-Thin" size:FontSize(s)])



#pragma mark - Private interface

@interface Demo1ViewController ()
@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end


#pragma mark - Implementation

@implementation Demo1ViewController

- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (void)dismissAllPopTipViews
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}
}

- (IBAction)buttonAction:(id)sender
{
	[self dismissAllPopTipViews];
	
	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		NSNumber *key = [NSNumber numberWithInteger:[(UIView *)sender tag]];
		id content = [self.contents objectForKey:key];
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
			contentMessage = @"A CMPopTipView can automatically point to any view or bar button item.";
		}
		NSArray *colorScheme = [self.colorSchemes objectAtIndex:foo4random()*[self.colorSchemes count]];
		UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		UIColor *textColor = [colorScheme objectAtIndex:1];
		
		NSString *title = [self.titles objectForKey:key];
		
		CMPopTipView *popTipView;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else if (title) {
			popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = self;
		
		/* Some options to try.
		 */
		//popTipView.disableTapToDismiss = YES;
		//popTipView.preferredPointDirection = PointDirectionUp;
		//popTipView.hasGradientBackground = NO;
        //popTipView.cornerRadius = 2.0;
        //popTipView.sidePadding = 30.0f;
        //popTipView.topMargin = 20.0f;
        //popTipView.pointerSize = 50.0f;
        //popTipView.hasShadow = NO;
		
		if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
			popTipView.backgroundColor = backgroundColor;
		}
		if (textColor && ![textColor isEqual:[NSNull null]]) {
			popTipView.textColor = textColor;
		}
        
        popTipView.animation = arc4random() % 2;
		popTipView.has3DStyle = (BOOL)(arc4random() % 2);
		
		popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];

		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:self.view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
		[self.visiblePopTipViews addObject:popTipView];
		self.currentPopTipViewTarget = sender;
	}
}


#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
	[self.visiblePopTipViews removeObject:popTipView];
	self.currentPopTipViewTarget = nil;
}


#pragma mark - UIViewController methods

- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration
{
	for (CMPopTipView *popTipView in self.visiblePopTipViews) {
		id targetObject = popTipView.targetObject;
		[popTipView dismissAnimated:NO];
		
		if ([targetObject isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)targetObject;
			[popTipView presentPointingAtView:button inView:self.view animated:NO];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
		}
	}
}

#warning liu zhi yi  usage
- (IBAction)lzyUsageClicked:(UIButton *)sender {
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *textColor = RGBA(187, 187, 187, 1);;
    UIColor *titleColor = RGBA(51, 51, 51, 1);
    NSString *str;
               str = [NSString stringWithFormat: @"点击任意新闻，按需求阅读全文可\n获得奖励一次，本日可用奖励%@次" ,@"3"];
    
    NSString *title = str;
    
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithTitle:title message:@"\n奖励正常发放中"];
    popTipView.bubblePaddingX = 10;
    popTipView.bubblePaddingY = 10;
    popTipView.shouldEnforceCustomViewPadding = YES;
    //    popTipView.sidePadding = 10;
    //    popTipView.topMargin = 10;
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 200 * LZYFitX, 26 * LZYFitX)];
    iv.image = [self imageWithColor:[UIColor whiteColor] andSize:iv.frame.size];
    popTipView.customView = iv;
    
    popTipView.delegate = self;
    if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
        popTipView.backgroundColor = backgroundColor;
    }
    if (textColor && ![textColor isEqual:[NSNull null]]) {
        popTipView.textColor = textColor;
    }
    if (textColor && ![textColor isEqual:[NSNull null]]) {
        popTipView.titleColor = titleColor;
    }
    popTipView.titleFont = [UIFont systemFontOfSize:15];
    popTipView.textFont = [UIFont systemFontOfSize:12];
    popTipView.borderColor = [UIColor clearColor];
    popTipView.borderWidth = 0.5;
    
    //    popTipView.animation = arc4random() % 2;
    //    popTipView.has3DStyle = (BOOL)(arc4random() % 2);
    popTipView.hasShadow = YES;
    
    popTipView.dismissTapAnywhere = YES;
    //    [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
    
    if ([sender isKindOfClass:[UIView class]]) {
        
        [popTipView presentPointingAtView:sender inView:self.view animated:YES];
    }
    [self.visiblePopTipViews addObject:popTipView];
    self.currentPopTipViewTarget = sender;
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.visiblePopTipViews = [NSMutableArray array];
	
	self.contents = [NSDictionary dictionaryWithObjectsAndKeys:
					 // Rounded rect buttons
					 @"A CMPopTipView will automatically position itself within the container view.", [NSNumber numberWithInt:11],
					 @"A CMPopTipView will automatically orient itself above or below the target view based on the available space.", [NSNumber numberWithInt:12],
					 @"A CMPopTipView always tries to point at the center of the target view.", [NSNumber numberWithInt:13],
					 @"A CMPopTipView can point to any UIView subclass.", [NSNumber numberWithInt:14],
					 @"A CMPopTipView will automatically size itself to fit the text message.", [NSNumber numberWithInt:15],
					 [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appicon57.png"]], [NSNumber numberWithInt:16],	// content can be a UIView
					 // Nav bar buttons
					 @"This CMPopTipView is pointing at a leftBarButtonItem of a navigationItem.", [NSNumber numberWithInt:21],
					 @"Two popup animations are provided: slide and pop. Tap other buttons to see them both.", [NSNumber numberWithInt:22],
					 // Toolbar buttons
					 @"CMPopTipView will automatically point at buttons either above or below the containing view.", [NSNumber numberWithInt:31],
					 @"The arrow is automatically positioned to point to the center of the target button.", [NSNumber numberWithInt:32],
					 @"CMPopTipView knows how to point automatically to UIBarButtonItems in both nav bars and tool bars.", [NSNumber numberWithInt:33],
					 nil];
	self.titles = [NSDictionary dictionaryWithObjectsAndKeys:
				   @"Title", [NSNumber numberWithInt:14],
				   @"Auto Orientation", [NSNumber numberWithInt:12],
				   nil];
	
	// Array of (backgroundColor, textColor) pairs.
	// NSNull for either means leave as default.
	// A color scheme will be picked randomly per CMPopTipView.
	self.colorSchemes = [NSArray arrayWithObjects:
						 [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
						 [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
						 [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
						 [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
						 nil];
}

@end
