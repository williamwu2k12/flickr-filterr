//
//  SearchViewController.h
//  Flickr Filterr
//
//  Created by William Wu on 12/1/13.
//  Copyright (c) 2013 William Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSNConnection.h"

@interface SearchViewController : UIViewController

@property (nonatomic, strong) UILabel * searchLabel;
@property (nonatomic, strong) UITextField * searchText;

@property (nonatomic, strong) UIButton * searchButton;
@property (nonatomic, strong) UIButton * prevPageButton;
@property (nonatomic, strong) UIButton * nextPageButton;

- (void) addBackground;
- (void) addSearchLabel;
- (void) addSearchText;
- (void) addButton: (UIButton *) button startx: (CGFloat) x starty: (CGFloat) y action: (SEL) function titleText: (NSString *) title;
- (void) addSearchGrid;

- (FSNConnection *) loadSearch;
- (FSNConnection *) loadFilters;

- (void) searchButtonPressed;
- (void) prevPageButtonPressed;
- (void) nextPageButtonPressed;
- (void) imageViewPressed: (UITapGestureRecognizer *) sender;

- (void) clearImages;
- (void) clearUrlArray;
- (void) changePage: (int) i image: (int) x;
- (void) exitKeyboard;

@end