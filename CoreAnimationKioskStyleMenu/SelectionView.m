/*
     File: SelectionView.m 
 Abstract: Implements the Core Animation kiosk-type behavior. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2011 Apple Inc. All Rights Reserved. 
  
 */

#import "SelectionView.h"
#import <Quartz/Quartz.h>
#import <QuartzCore/CoreAnimation.h>


@implementation SelectionView

@synthesize selectedIndex;
@synthesize menuLayer;
@synthesize selectionLayer;
@synthesize names;

#pragma mark - Listing: Implementation of awakeFromNib

- (void)awakeFromNib
{
   // Adopt to your setting, or calc automatically
    if ( [[NSScreen screens] count] > 1 ) { /* setup dualscreen */
        self.screenSize  = CGSizeMake(1920.0,2000.0);
        self.bigBounds   = CGRectMake(0,0,1920.0,2000.0);
        self.smallBounds   = CGRectMake(0,0,192.0,200.0);
    } else { /* setup single */
        self.screenSize  = CGSizeMake(1280.0,800.0);
        self.bigBounds   = CGRectMake(0,0,1280.0,800.0);
        self.smallBounds   = CGRectMake(0,0,128.0,80.0);
        
    }
    
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [NSApp setPresentationOptions:(NSApplicationPresentationAutoHideDock|NSApplicationPresentationAutoHideMenuBar)];
    
    
	// create an array that contains the various 
	// strings
    self.names=[NSArray arrayWithObjects:@"",
				nil];
	
	// The cursor isn't used for selection, so we hide it
	//[NSCursor hide];
	NSLog(@"init: %@", [self.window title] );
	
	// setup the individual layers
    [self setupLayers];
	
	//[self.window setStyleMask:NSBorderlessWindowMask];
    [self.window setExcludedFromWindowsMenu:YES];
    
    // coorect for dualscreen arrangement
    [[self window] setFrame:CGRectMake(0.0,-800.0+0.0,self.screenSize.width,self.screenSize.height) display:YES animate:YES];
  	
	[[self window] setLevel:NSFloatingWindowLevel];
    
    // Make the window the first responder to get keystrokes
	[self.window makeFirstResponder:self];
	// bring the window to the front
	[self.window makeKeyAndOrderFront:self];

    // go full screen, as a kiosk application
	//[self enterFullScreenMode:[self.window screen] withOptions:NULL];
	//self.frame = CGRectMake(-200.0,-100.0,2600.0,2400.0);
    
    [self resizeLayer:self.selectionLayer to:self.screenSize old:self.bigBounds new:self.smallBounds close:NO];

}

- (BOOL)canBecomeMainWindow {
    return YES;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

#pragma mark Listing: Configuration of the Background rootLayer

-(void)setupLayers;
{
	// displaying a solid background
	// load the text to tell you how to quit
	// and center it
	CALayer *rootLayer=[CALayer layer];
	CGColorRef myBlackColor=CGColorCreateGenericRGB(0.0f, 0.0f, 0.0f, 1.0f);
	rootLayer.backgroundColor=myBlackColor;
	/*NSImage *theImage=[[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CommandImage" ofType:@"png"]];
    
   // theImage =
    self.menuLayer.contents = theImage; 
	
	rootLayer.contentsGravity=kCAGravityTop;
	[theImage release];
	*/
    CGColorRelease(myBlackColor);
    //rootLayer.frame.origin.x = 10.0;
    
	// Set the redLayer as the root layer
	// and then turn on wantsLayer. This order causes
	//  layer-hosting behavior on the part of the view.
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];

	
	
#pragma mark - Listing:Setup menuLayers Array. The Selectable Menu Items.
/*
	// Create a layer to contain the menus	
	self.menuLayer=[CALayer layer] ;
	self.menuLayer.frame=rootLayer.frame;
    self.menuLayer.frame=CGRectMake(0.0,0.0,1920.0,2000.0);

	self.menuLayer.layoutManager=[CAConstraintLayoutManager layoutManager];
   [rootLayer addSublayer:self.menuLayer];
*/	
	
	
	
    // setup and calculate the size and location of the individually selectable items.
    CGFloat width=800.0f;
    CGFloat height=200.0f;
    CGFloat spacing=200.0f;
    CGFloat fontSize=32.0f;
    //CGFloat initialOffset=(self.bounds.size.height/2-(height*5+spacing*4)/2.0f)+(+800+1200)/2;
	CGFloat initialOffset=200.0f-0.0f;
	
	
	
	//Create whiteColor it's used to draw the text and also in the selectionLayer
	CGColorRef myWhiteColor=CGColorCreateGenericRGB(1.0f,1.0f,1.0f,1.0f);
	
	/*
	// interate over the list of selection names and create layers for them.
	// The menuItemLayer's are also positioned during this loop.
	NSUInteger i;
	for (i=0;i<[names count];i++) {
		
		CATextLayer *menuItemLayer=[CATextLayer layer];
		menuItemLayer.string=[self.names objectAtIndex:i];
		menuItemLayer.font=@"Lucida-Grande";
		menuItemLayer.fontSize=fontSize;
		menuItemLayer.foregroundColor=myWhiteColor;
		[menuItemLayer addConstraint:[CAConstraint
									  constraintWithAttribute:kCAConstraintMaxY
									  relativeTo:@"superlayer"
									  attribute:kCAConstraintMaxY
									  offset:-(i*height+spacing+initialOffset)]];
		[menuItemLayer addConstraint:[CAConstraint
									  constraintWithAttribute:kCAConstraintMidX
									  relativeTo:@"superlayer"
									  attribute:kCAConstraintMidX]];
		[self.menuLayer addSublayer:menuItemLayer];
	} // end of for loop
	[self.menuLayer layoutIfNeeded];
	*/
    
#pragma mark - Listing: Setup selectionLayer. Displays the Currently Selected Item.
	
	// we use an additional layer, selectionLayer
	// to indicate that the current item is selected
	self.selectionLayer=[CALayer layer];
    
    self.selectionLayer.contents=(id) CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionAll, kCGNullWindowID, kCGWindowImageDefault);
 
    //if (  [[self.window title]isEqualToString: @"CoreAnimationKioskMenu"] ) {
    //    self.selectionLayer.contents=(id)   CGDisplayCreateImage(kCGDirectMainDisplay);
    //} else {
     //   self.selectionLayer.contents=(id) CGWindowListCreateImage(CGRectMake(0, 1200, 1280, 800), kCGWindowListOptionAll, kCGNullWindowID, kCGWindowImageDefault);
    //}
    
    /*
	CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
	[filter setDefaults];
	[filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
	[filter setName:@"pulseFilter"];
	[selectionLayer setFilters:[NSArray arrayWithObject:filter]];
	
	// The selectionLayer shows a subtle pulse as it
	// is displayed. This section of the code create the pulse animation
	// setting the filters.pulsefilter.inputintensity to range from 0 to 2.
	// This will happen every second, autoreverse, and repeat forever
	CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
	pulseAnimation.keyPath = @"bounds";
	pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0f];
	pulseAnimation.toValue = [NSNumber numberWithFloat: 40.0f];
	pulseAnimation.duration = 1.0;
	pulseAnimation.repeatCount = HUGE_VALF;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:
                                     kCAMediaTimingFunctionEaseInEaseOut];
	[selectionLayer addAnimation:pulseAnimation forKey:@"pulseAnimation"];
	*/
    
  
    
    
	// set the first item as selected
	[self changeSelectedIndex:0];
	
     self.selectionLayer.frame=CGRectMake(0.0,0.0,self.screenSize.width,self.screenSize.height);
	// finally, the selection layer is added to the root layer
	[rootLayer addSublayer:self.selectionLayer];
	
	// cleanup
	CGColorRelease(myWhiteColor);
	// end of setupLayers
    
    
    if ( NO ) { /* autostart animation, if keys are not working because of borderless window style*/
        //CGSize size      = CGSizeMake(192.0,200.0);
        [self resizeLayer:self.selectionLayer to:self.smallBounds.size old:self.bigBounds new:self.smallBounds close:NO];

    } else {
        [self resizeLayer:self.selectionLayer to:self.bigBounds.size old:self.bigBounds new:self.bigBounds close:NO];
    
    }
    // animation finished..
    //[[self window] setFrame:CGRectMake(0.0,-800.0+0.0,20,20.0) display:YES animate:YES];
  	//self.selectionLayer.contents = nil;
    
}

-(void)resizeLayer:(CALayer*)layer to:(CGSize)size old:(CGRect)bigBounds new:(CGRect)smallBounds close:(Boolean)close
{
    //CGRect bigBounds = CGRectMake(0,0, 1920.0+1280.0,1280.0+800.0);
    //CGRect smallBounds = CGRectMake(0,0, 192.0,200.0);
    
    /*self.selectionLayer.bounds=CGRectMake(0.0,0.0,800.0,600.0);
     self.selectionLayer.borderWidth=2.0;
     self.selectionLayer.cornerRadius=25;
     self.selectionLayer.borderColor=myWhiteColor;
     */
    
    
    // Prepare the animation from the old size to the new size
   // smallBounds.size = size;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    // NSValue/+valueWithRect:(NSRect)rect is available on Mac OS X
    // NSValue/+valueWithCGRect:(CGRect)rect is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // Mac OS X
    //animation.repeatCount = HUGE_VALF;
	//animation.autoreverses = YES;
	animation.duration = 1;
    animation.duration = 0.5;
    
    animation.fromValue = [NSValue valueWithRect:NSRectFromCGRect(bigBounds)];
    animation.toValue   = [NSValue valueWithRect:NSRectFromCGRect(smallBounds)];
    // iOS
    //animation.fromValue = [NSValue valueWithCGRect:bigBounds];
    //animation.toValue = [NSValue valueWithCGRect:smallBounds];
    
    // Update the layer's bounds so the layer doesn't snap back when the animation completes.
    layer.bounds = smallBounds;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"bounds"];
    
   // [self.window close];
    
    
   
}

/*
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    //if ( self.can_close ) {
        [NSApp terminate:self];
    //}
}
*/

#pragma mark Listing: Handle Changes in the Selection

-(void)changeSelectedIndex:(NSInteger)theSelectedIndex
{
    self.selectedIndex=theSelectedIndex;
	
    if (self.selectedIndex == (NSInteger)[names count]) 
		self.selectedIndex=[names count]-1;
    if (self.selectedIndex < 0) 
		self.selectedIndex=0;
	
    CALayer *theSelectedLayer=[[self.menuLayer sublayers] objectAtIndex:self.selectedIndex];
	
	// Moves the selectionLayer to illustrate the 
	// currently selected item. It does this
	// using an animation so that the transition 
	// is visible.
    self.selectionLayer.position=theSelectedLayer.position;
};


#pragma mark Listing: Handling Up and Down Key Presses


-(void)moveUp:(id)sender
{
    [self resizeLayer:self.selectionLayer to:self.bigBounds.size old:self.smallBounds new:self.bigBounds close:NO];
 
}

-(void)moveDown:(id)sender
{
    [self resizeLayer:self.selectionLayer to:self.smallBounds.size old:self.bigBounds new:self.smallBounds close:NO];
    
	
}

#pragma mark Listing: Dealloc and Cleanup


-(void)dealloc
{
    [self setLayer:nil];
	self.menuLayer=nil;
	self.selectionLayer=nil;
	self.names=nil;
    [super dealloc];
}

@end
