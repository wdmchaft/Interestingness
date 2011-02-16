//
//  InterestingnessTableViewController.m
//  Interestingness
//
//  Created by sony on 14/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InterestingnessTableViewController.h"
#import "JSON.h"
#define API_KEY @"5bb2ca0d01abd3f18848cd99f6d27a05"

@implementation InterestingnessTableViewController


#pragma mark -
#pragma mark View lifecycle
-(id)initWithStyle:(UITableViewStyle)style{
	if(self=[super initWithStyle:style]) {
		imageTitles=[[NSMutableArray alloc] init];
		imageURLs=[[NSMutableArray alloc] init];
	}
	return self;
}
/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self performSelectorInBackground:@selector(fetchInterestingnessList) withObject:nil];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
    return [imageURLs count];
//	return 2;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	//NSLog(@"%@",imageURLs);
    // Configure the cell...
    cell.textLabel.text=[imageTitles objectAtIndex:indexPath.row];
	NSData *data=[NSData dataWithContentsOfURL:[imageURLs objectAtIndex:indexPath.row]];
	[[cell imageView] setImage:[UIImage imageWithData:data]];
//	NSLog(@"%@",[imageURLs objectAtIndex:indexPath.row]);
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[imageTitles release];
	[imageURLs release];
    [super dealloc];
}

#pragma mark Load from Flickr

-(void)fetchInterestingnessList{
	NSAutoreleasePool *localPool;
	[UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
	@try {
		localPool=[[NSAutoreleasePool alloc]init];
		
		if([NSThread isMainThread])
			NSLog(@"fetch is the main thread");
		else {
			NSLog(@"fetch is the background thread");
		}
		
		NSString *urlString=[NSString stringWithFormat:
							 @"http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=%@&extras=description&per_page=%d&format=json&nojsoncallback=1",
							 API_KEY,10];
		NSURL *url=[NSURL URLWithString:urlString];
		NSError *error=nil;
		NSString *jsonResultString=[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
		NSDictionary *results=[jsonResultString JSONValue];
		
		[self performSelectorOnMainThread:@selector(disaggregateInterestingnessList:)
							   withObject:results waitUntilDone:NO];
		
		

	}
	@catch (NSException * e) {
		NSLog(@"%@",[e reason]);
	}
	@finally {
		[localPool release];
	}	
}

-(void)disaggregateInterestingnessList:(NSDictionary*)results{
	[UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
	if([NSThread isMainThread])
	NSLog(@"disaggregate is in  main thread");
	else {
		NSLog(@"disaggregate is in background thread");
	}
	
	NSArray *imagesArray=[[results objectForKey:@"photos"] objectForKey:@"photo"];				
	
	for (NSDictionary *image in imagesArray) {
		
		if([image objectForKey:@"id"]!=[NSNull null]) {
		NSString *imageURLString=[NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",
									  [image objectForKey:@"farm"],
									  [image objectForKey:@"server"],
									  [image objectForKey:@"id"],
									  [image objectForKey:@"secret"]];
			[imageURLs addObject:[NSURL URLWithString:imageURLString]];	
			NSString  *imageTitle=[image objectForKey:@"title"];
			[imageTitles addObject:[imageTitle length]>0?imageTitle:@"Untitled"];
		}
	}
	

	[[self tableView] reloadData];
	
}
@end

