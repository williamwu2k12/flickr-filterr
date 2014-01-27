//
//  DetailViewController.h
//  Flickr Filterr
//
//  Created by William Wu on 12/2/13.
//  Copyright (c) 2013 William Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSNConnection.h"

@interface DetailViewController : UIViewController

@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UIButton * saveButton;
@property (nonatomic, strong) UIButton * undoButton;
@property (nonatomic, strong) UIButton * processButton;

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIScrollView * scrollFilters;
@property (nonatomic, strong) UILabel * labelFilters;

@property (nonatomic, strong) NSString * urlString;
@property (nonatomic, strong) NSMutableArray * prevImages;

- (void) addButton: (UIButton *) button startx: (CGFloat) x starty: (CGFloat) y action: (SEL) function titleText: (NSString *) title;
- (void) addImageView;
- (void) addScrollFilters;
- (void) addLabelFilters;

- (FSNConnection *) loadImage;

- (void) backButtonPressed;
- (void) saveButtonPressed;
- (void) undoButtonPressed;
- (void) processButtonPressed;
- (void) filterPressed: (UITapGestureRecognizer *) sender;

- (CIFilter *) invertImage: (CIImage *) ciImage;
- (CIFilter *) sepiaImage: (CIImage *) ciImage;
- (CIFilter *) pixellateImage: (CIImage *) ciImage;
- (CIFilter *) bloomImage: (CIImage *) ciImage;
- (CIFilter *) photoEffectTransferImage: (CIImage *) ciImage;
- (CIFilter *) photoEffectTonalImage: (CIImage *) ciImage;
- (CIFilter *) photoEffectInstantImage: (CIImage *) ciImage;
- (CIFilter *) colorClampImage: (CIImage *) ciImage;
- (CIFilter *) gloomImage: (CIImage *) ciImage;
- (CIFilter *) colorCubeImage: (CIImage *) ciImage;

- (void) updateImageView;
- (UIImage *) changeImage;
- (void) clearHighlights;

@end
