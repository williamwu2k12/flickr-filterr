//
//  DetailViewController.m
//  Flickr Filterr
//
//  Created by William Wu on 12/2/13.
//  Copyright (c) 2013 William Wu. All rights reserved.
//

#import "DetailViewController.h"
#import "SearchViewController.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "FSNConnection.h"


@implementation DetailViewController
{
    AppDelegate * appDelegateSingleton;
    SearchViewController * svc;
    int numberFilters;
    int currentFilter;
    FSNConnection * connection;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    appDelegateSingleton = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    svc = appDelegateSingleton.mainViewController;
    [self addImageView];

    [self addButton: self.backButton startx: 10.0f starty: 40.0f action: @selector(backButtonPressed) titleText: @"Back"];
    [self addButton: self.saveButton startx: 250.0f starty: 40.0f action: @selector(saveButtonPressed) titleText: @"Save"];
    [self addButton: self.undoButton startx: 10.0f starty: 520.0f action: @selector(undoButtonPressed) titleText: @"Undo"];
    [self addButton: self.processButton startx: 240.0f starty: 520.0f action: @selector(processButtonPressed) titleText: @"Process"];
    [self addScrollFilters];
    [self addLabelFilters];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//////////////////
// Add Elements //
//////////////////

- (void) addButton: (UIButton *) button startx: (CGFloat) x starty: (CGFloat) y action: (SEL) function titleText: (NSString *) title
{
    button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setFrame: CGRectMake(x, y, 60.0f, 30.0f)];
    [button addTarget: self action: function forControlEvents: UIControlEventTouchUpInside];
    [button setTitle: title forState:UIControlStateNormal];
    [self.view addSubview: button];
}

- (void) addImageView
{
    self.prevImages = [[NSMutableArray alloc] init];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 300.0f, 300.0f)];
    [[self.imageView layer] setBorderWidth:1.0f];
    [self.imageView setContentMode: UIViewContentModeScaleAspectFit];
    [self.view addSubview: self.imageView];
}

- (void) addScrollFilters
{
    numberFilters = 10;
    currentFilter = -1;
    self.scrollFilters = [[UIScrollView alloc] initWithFrame: CGRectMake(10.0f, 410.0f, 300.0f, 110.0f)];
    [[self.scrollFilters layer] setBorderWidth:1.0f];
    [self.scrollFilters setContentSize: CGSizeMake(100.0f * numberFilters + 10.0f, self.scrollFilters.frame.size.height)];
    [self.scrollFilters setScrollEnabled: YES];
    [self.scrollFilters setShowsHorizontalScrollIndicator: YES];
    [self.scrollFilters setShowsVerticalScrollIndicator: NO];
    [self.scrollFilters setScrollsToTop: NO];
    for (int i = 0; i < numberFilters; i++)
    {
        UIImageView * filterPreview = [[UIImageView alloc] initWithFrame: CGRectMake(10.0f + i * 100.0f, 10.0f, 90.0f, 90.0f)];
        [filterPreview setContentMode: UIViewContentModeScaleToFill];
        [[filterPreview layer] setBorderWidth: 1.0f];
        [filterPreview setTag: i];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterPressed:)];
        [tap setNumberOfTapsRequired: 1];
        [filterPreview setUserInteractionEnabled: YES];
        [filterPreview addGestureRecognizer: tap];
        [self.scrollFilters addSubview: filterPreview];
    }
    [self.view addSubview: self.scrollFilters];
}

- (void) addLabelFilters
{
    self.labelFilters = [[UILabel alloc] initWithFrame: CGRectMake(10.0f, 375.0f, 300.0f, 30.0f)];
    [self.labelFilters setTextAlignment: NSTextAlignmentCenter];
    [self.labelFilters setText: @"Filters"];
    [self.view addSubview: self.labelFilters];
}



///////////////////////////
// Image Loading Helpers //
///////////////////////////

- (FSNConnection *) loadImage
{
    return [FSNConnection withUrl:[NSURL URLWithString:self.urlString] method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:^id(FSNConnection *c,NSError **error)
    {
        NSData *d = c.responseData;
        if (!d)
        {
            return nil;
        }
        return d;
    }
    completionBlock:^(FSNConnection *c)
    {
        if (c.responseData==nil)
        {
            UIAlertView *noInternet = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network not found" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles: nil];
            [noInternet show];
        }
        else
        {
            [self.imageView setImage: [UIImage imageWithData: c.responseData]];
            [self.prevImages addObject: [self.imageView image]];
        }
    }
    progressBlock:^(FSNConnection *c)
    {
        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
    }];
}



////////////////////////////
// Button Pressed Methods //
////////////////////////////

- (void) backButtonPressed
{
    [self.prevImages removeAllObjects];
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void) saveButtonPressed
{
    if ([self.imageView image]!=nil)
    {
        UIImageWriteToSavedPhotosAlbum([self.imageView image], nil, nil, nil);
    }
    else
    {
        UIAlertView *noImage = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Image to save" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles: nil];
        [noImage show];
    }
}

- (void) undoButtonPressed
{
    if ([self.prevImages count] > 1)
    {
        [self.prevImages removeLastObject];
        [self.imageView setImage: [self.prevImages lastObject]];
    }
}

- (void) processButtonPressed
{
    if ([self.imageView image]!=nil)
    {
        UIImage * resultImage = [self changeImage];
        NSData * dataOld = UIImagePNGRepresentation([self.prevImages lastObject]);
        NSData * dataNew = UIImagePNGRepresentation(resultImage);
        if (![dataOld isEqualToData: dataNew])
        {
            [self.prevImages addObject: resultImage];
            [self.imageView setImage: resultImage];
        }
        [self clearHighlights];
    }
    else
    {
        UIAlertView *noImage = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Image to Process" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles: nil];
        [noImage show];
    }
}

- (void) filterPressed: (UITapGestureRecognizer *) sender
{
    UIImageView * imageView = (UIImageView *) sender.view;
    if ([[imageView layer] borderWidth] == 1.0f)
    {
        [self clearHighlights];
        [[imageView layer] setBorderWidth: 3.0f];
        [[imageView layer] setBorderColor: [[UIColor blackColor] CGColor]];
        currentFilter = (int) sender.view.tag;
    }
    else
    {
        currentFilter = -1;
        [self clearHighlights];
    }
}



//////////////////////
// Filter Functions //
//////////////////////

- (CIFilter *) invertImage: (CIImage *) ciImage
{
    CIFilter * invertColour = [CIFilter filterWithName:@"CIColorInvert" keysAndValues:@"inputImage", ciImage, nil];
    return invertColour;
}

- (CIFilter *) sepiaImage: (CIImage *) ciImage
{
    CIFilter * sepiaColour = [CIFilter filterWithName:@"CISepiaTone" keysAndValues:@"inputImage", ciImage, nil];
    return sepiaColour;
}

- (CIFilter *) pixellateImage: (CIImage *) ciImage
{
    CIFilter * pixellateColour = [CIFilter filterWithName:@"CIPixellate" keysAndValues:@"inputImage", ciImage, nil];
    return pixellateColour;
}

- (CIFilter *) bloomImage: (CIImage *) ciImage
{
    CIFilter * bloomColour = [CIFilter filterWithName:@"CIBloom" keysAndValues:@"inputImage", ciImage, nil];
    return bloomColour;
}

- (CIFilter *) photoEffectTransferImage: (CIImage *) ciImage
{
    CIFilter * photoEffectTransferColour = [CIFilter filterWithName:@"CIPhotoEffectTransfer" keysAndValues:@"inputImage", ciImage, nil];
    return photoEffectTransferColour;
}

- (CIFilter *) photoEffectTonalImage: (CIImage *) ciImage
{
    CIFilter * photoEffectTonalColour = [CIFilter filterWithName:@"CIPhotoEffectTonal" keysAndValues:@"inputImage", ciImage, nil];
    return photoEffectTonalColour;
}

- (CIFilter *) photoEffectInstantImage: (CIImage *) ciImage
{
    CIFilter * photoEffectInstantColour = [CIFilter filterWithName:@"CIPhotoEffectInstant" keysAndValues:@"inputImage", ciImage, nil];
    return photoEffectInstantColour;
}

- (CIFilter *) colorClampImage: (CIImage *) ciImage
{
    CIFilter * colorClampColour = [CIFilter filterWithName:@"CIColorClamp" keysAndValues:@"inputImage", ciImage, nil];
    return colorClampColour;
}

- (CIFilter *) gloomImage: (CIImage *) ciImage
{
    CIFilter * gloomColour = [CIFilter filterWithName:@"CIGloom" keysAndValues:@"inputImage", ciImage, nil];
    return gloomColour;
}

- (CIFilter *) colorCubeImage: (CIImage *) ciImage
{
    CIFilter * colorCubeColour = [CIFilter filterWithName:@"CIColorCube" keysAndValues:@"inputImage", ciImage, nil];
    return colorCubeColour;
}



//////////////////////
// Helper Functions //
//////////////////////

- (void) updateImageView
{
    self.urlString = [self.urlString stringByReplacingOccurrencesOfString: @"_q.jpg" withString: @".jpg"];
    [[self loadImage] start];
}

- (UIImage *) changeImage
{
    CIImage * ciImage = [CIImage imageWithData: UIImagePNGRepresentation([self.imageView image])];
    CIFilter * filter;
    if (currentFilter == -1)
    {
        return [self.imageView image];
    }
    if (currentFilter == 0)
    {
        filter = [self invertImage: ciImage];
    }
    if (currentFilter == 1)
    {
        filter = [self sepiaImage: ciImage];
    }
    if (currentFilter == 2)
    {
        filter = [self pixellateImage: ciImage];
    }
    if (currentFilter == 3)
    {
        filter = [self bloomImage: ciImage];
    }
    if (currentFilter == 4)
    {
        filter = [self photoEffectTransferImage: ciImage];
    }
    if (currentFilter == 5)
    {
        filter = [self photoEffectTonalImage: ciImage];
    }
    if (currentFilter == 6)
    {
        filter = [self photoEffectInstantImage: ciImage];
    }
    if (currentFilter == 7)
    {
        filter = [self colorClampImage: ciImage];
    }
    if (currentFilter == 8)
    {
        filter = [self gloomImage: ciImage];
    }
    if (currentFilter == 9)
    {
        filter = [self colorCubeImage: ciImage];
    }
    CIImage * filteredImage = [filter outputImage];
    CIContext * softwareContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    CGImageRef cgImage = [softwareContext createCGImage: filteredImage fromRect: [filteredImage extent]];
    UIImage * resultImage = [[UIImage alloc] initWithCGImage:cgImage];
    return resultImage;
}

- (void) clearHighlights
{
    for (UIImageView * imageView in [self.scrollFilters subviews])
    {
        [[imageView layer] setBorderWidth: 1.0f];
        [[imageView layer] setBorderColor: [[UIColor blackColor] CGColor]];
    }
}

@end