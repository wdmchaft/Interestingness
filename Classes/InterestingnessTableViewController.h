//
//  InterestingnessTableViewController.h
//  Interestingness
//
//  Created by sony on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InterestingnessTableViewController : UITableViewController {
	NSMutableArray *imageTitles;
	NSMutableArray *imageURLs;
}

-(void)fetchInterestingnessList;
-(void)disaggregatInterestingnessList:(NSDictionary*)results;

@end
