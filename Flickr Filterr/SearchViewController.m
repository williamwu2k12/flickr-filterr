//
//  SearchViewController.m
//  Flickr Filterr
//
//  Created by William Wu on 12/1/13.
//  Copyright (c) 2013 William Wu. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "FSNConnection.h"

@implementation SearchViewController
{
    AppDelegate * appDelegateSingleton;
    DetailViewController * fvc;
    NSMutableArray * urlArray;
    NSMutableArray * searchGrid;
    NSString * urlRequest;
    NSURL * request;
    int currentPage;
    int maxPage;
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
    fvc = appDelegateSingleton.filterViewController;
    [self addBackground];
    [self addSearchLabel];
    [self addSearchText];
    [self addButton: self.searchButton startx: 255.0f starty: 70.0f action: @selector(searchButtonPressed) titleText: @"Search"];
    [self addButton: self.prevPageButton startx: 5.0f starty: 525.0f action: @selector(prevPageButtonPressed) titleText: @"Prev"];
    [self addButton: self.nextPageButton startx: 255.0f starty: 525.0f action: @selector(nextPageButtonPressed) titleText: @"Next"];
    [self addSearchGrid];
    /////////////
    // Testing //
    /////////////
//  [self.searchText setText: @"Cal Berkeley"];
//  [self searchButtonPressed];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//////////////////
// Add Elements //
//////////////////

- (void)addBackground
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(exitKeyboard)];
    [tap setNumberOfTapsRequired: 1];
    [self.view addGestureRecognizer: tap];
}

- (void) addSearchLabel
{
    self.searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 300.0f, 30.0f)];
    [self.searchLabel setText: @"Flickr Filterr"];
    [self.searchLabel setTextAlignment: NSTextAlignmentCenter];
    [self.view addSubview: self.searchLabel];
}
    
- (void) addSearchText
{
    self.searchText = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 240.0f, 30.0f)];
    [self.searchText setBorderStyle: UITextBorderStyleLine];
    [self.view addSubview: self.searchText];
}

- (void) addButton: (UIButton *) button startx: (CGFloat) x starty: (CGFloat) y action: (SEL) function titleText: (NSString *) title
{
    button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setFrame: CGRectMake(x, y, 60.0f, 30.0f)];
    [button addTarget: self action: function forControlEvents: UIControlEventTouchUpInside];
    [button setTitle: title forState:UIControlStateNormal];
    [self.view addSubview: button];
}

- (void) addSearchGrid
{
    CGFloat startx = 15.0f;
    CGFloat starty = 110.0f;
    CGFloat width = 90.0f;
    CGFloat height = 90.0f;
    CGFloat spacex = 100.0f;
    CGFloat spacey = 100.0f;
    CGFloat changex = 0.0f;
    CGFloat changey = 0.0f;
    urlArray = [[NSMutableArray alloc] init];
    searchGrid = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++)
    {
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(startx + changex, starty + changey, width, height)];
        [[imageView layer] setBorderWidth: 1.0f];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewPressed:)];
        [tap setNumberOfTapsRequired: 1];
        [imageView setUserInteractionEnabled: YES];
        [imageView addGestureRecognizer: tap];
        [searchGrid addObject: imageView];
        [self.view addSubview: [searchGrid lastObject]];
        if ((i + 1) % 3 == 0)
        {
            changex = 0.0f;
            changey += spacey;
        }
        else
        {
            changex += spacex;
        }
    }
}



///////////////////////////
// Image Loading Helpers //
///////////////////////////

- (FSNConnection *) loadSearch
{
    request = [[NSURL alloc] initWithString:[urlRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [FSNConnection withUrl:request method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:^id(FSNConnection *c, NSError **error)
    {
        NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
        if (!d)
        {
            return nil;
        }
        if (c.response.statusCode != 200)
        {
            *error = [NSError errorWithDomain:@"FSAPIErrorDomain" code:1 userInfo:[d objectForKey:@"meta"]];
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
        NSError *error = nil;
        NSDictionary * flickrDict = [c.responseData dictionaryFromJSONWithError:&error];
        NSArray * jsonArray = [[flickrDict objectForKey: @"photos"] objectForKey: @"photo"];
        [self clearImages];
        [self clearUrlArray];
        for (int i = 0; i < [jsonArray count]; i++)
        {
            NSArray * urlImageArray = [[NSArray alloc] initWithObjects: @"http://farm", [[[jsonArray objectAtIndex:i] objectForKey:@"farm"] stringValue], @".staticflickr.com/", [[jsonArray objectAtIndex:i] objectForKey:@"server"], @"/", [[jsonArray objectAtIndex:i] objectForKey:@"id"], @"_", [[jsonArray objectAtIndex:i] objectForKey:@"secret"], @"_q.jpg", nil];
            NSString * urlImage = [urlImageArray componentsJoinedByString: @""];
            [urlArray addObject: urlImage];
        }
        currentPage = 1;
        maxPage = (int)(([urlArray count] + 12 - 1) / 12);
        for (int i = 0; i < [urlArray count] && i < [searchGrid count]; i++)
        {
            [self changePage: i image: i];
        }
    }
    progressBlock:^(FSNConnection *c)
    {
        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
    }];
}

- (FSNConnection *) loadFilters
{
    request = [NSURL URLWithString: [fvc.urlString stringByReplacingOccurrencesOfString: @".jpg" withString: @"_q.jpg"]];
    return [FSNConnection withUrl:request method:FSNRequestMethodGET headers:nil parameters:nil parseBlock:^id(FSNConnection *c, NSError **error)
    {
        NSData *d = c.responseData;
        if (!d) return nil;
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
            CIImage * ciImage = [CIImage imageWithData:c.responseData];
            NSMutableArray * filterArray = [[NSMutableArray alloc] init];
            [filterArray addObject: [fvc invertImage: ciImage]];
            [filterArray addObject: [fvc sepiaImage: ciImage]];
            [filterArray addObject: [fvc pixellateImage: ciImage]];
            [filterArray addObject: [fvc bloomImage: ciImage]];
            [filterArray addObject: [fvc photoEffectTransferImage: ciImage]];
            [filterArray addObject: [fvc photoEffectTonalImage: ciImage]];
            [filterArray addObject: [fvc photoEffectInstantImage: ciImage]];
            [filterArray addObject: [fvc colorClampImage: ciImage]];
            [filterArray addObject: [fvc gloomImage: ciImage]];
            [filterArray addObject: [fvc colorCubeImage: ciImage]];
            CIFilter * filter;
            for (int i = 0; i < [filterArray count]; i++)
            {
                filter = [filterArray objectAtIndex: i];
                CIImage * filteredImage = [filter outputImage];
                CIContext * softwareContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
                CGImageRef cgImage = [softwareContext createCGImage: filteredImage fromRect: [filteredImage extent]];
                UIImage * resultImage = [[UIImage alloc] initWithCGImage:cgImage];
                UIImageView * currentImageView;
                for (UIImageView * subview in [fvc.scrollFilters subviews])
                {
                    if ([subview tag] == i)
                    {
                        currentImageView = subview;
                    }
                }
                [currentImageView setImage: resultImage];
            }
            [fvc clearHighlights];
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

- (void) searchButtonPressed
{
    [self exitKeyboard];
    //Constructing request URL
    urlRequest = [[@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=6343a66eb46c461c91934e8a7a981056&text=" stringByAppendingString: [self.searchText text]] stringByAppendingString:@"&format=json&nojsoncallback=1"];
    request = [[NSURL alloc] initWithString:[urlRequest stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    connection = [self loadSearch];
    [connection start];
}

- (void) prevPageButtonPressed
{
    if (currentPage > 1)
    {
        currentPage -= 1;
        for (int i = 0, x = 12 * (currentPage - 1); i < 12; i++, x++)
        {
            [self changePage: i image: x];
        }
    }
}

- (void) nextPageButtonPressed
{
    int restImages;
    if (currentPage <= maxPage - 1)
    {
        currentPage += 1;
        if (currentPage == maxPage)
        {
            restImages = [urlArray count] % 12;
            [self clearImages];
        }
        else
        {
            restImages = 12;
        }
        for (int i = 0, x = 12 * (currentPage - 1); i < restImages && i < 12; i++, x++)
        {
            [self changePage: i image: x];
        }
    }
}

- (void) imageViewPressed: (UITapGestureRecognizer *) sender
{
    @try
    {
        fvc.urlString = [urlArray objectAtIndex:sender.view.tag];
    }
    @catch (NSException * exception)
    {
        [self exitKeyboard];
        return;
    }
    [self presentViewController: fvc animated: NO completion: nil];
    [fvc.imageView setImage:nil];
    for (UIImageView * subview in [fvc.scrollFilters subviews])
    {
        [subview setImage:nil];
    }
    [fvc updateImageView];
    connection = [self loadFilters];
    [connection start];
}



//////////////////////
// Helper Functions //
//////////////////////

- (void) clearImages
{
    for (int i = 0; i < [searchGrid count]; i++)
    {
        UIImageView * imageView = [searchGrid objectAtIndex: i];
        [imageView setImage: nil];
    }
}

- (void) clearUrlArray
{
    [urlArray removeAllObjects];
}

- (void) changePage: (int) i image: (int) x
{
    UIImageView * imageView = [searchGrid objectAtIndex: i];
    [imageView setImage: [UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [urlArray objectAtIndex: x]]]]];
    [imageView setTag: i + 12 * (currentPage - 1)];
    [imageView setContentMode: UIViewContentModeScaleAspectFit];
}

- (void) exitKeyboard
{
    [self.searchText resignFirstResponder];
}

@end