/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The application's primary table view controller showing a list of products.
 */

#import "APLMainTableViewController.h"
#import "APLDetailViewController.h"
#import "APLResultsTableController.h"
#import "Song.h"
#import "Singer.h"
#define SONGTABLE @"SongTable"
#define SINGERTABLE @"SingerTable"
#import "NSString+Utility.h"
#import "DataMananager.h"
#import "UIImage+Utility.h"
#import "SongListViewController.h"
enum selectSearchType{
    searchAll,
    searchSong,
    searchSinger
};
@interface APLMainTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating> {
    NSInteger _previousRow;
    dispatch_group_t group;
    NSOperationQueue *_queue;
    UIView *promtView;

}

@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) APLResultsTableController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

@property (nonatomic,strong)FMDatabase *searchDb;


@end


#pragma mark -

@implementation APLMainTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
     _previousRow = -1;
    group=dispatch_group_create();
    _queue=[[NSOperationQueue alloc]init];
    _queue.maxConcurrentOperationCount=1;
    _resultsTableController = [[APLResultsTableController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
//    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.navigationItem.titleView=self.searchController.searchBar;

    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.resultsTableController.tableView.rowHeight=60.0f;
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    self.searchController.searchBar.placeholder=NSLocalizedString(@"searchhinttext_searchVC", nil);
    self.extendedLayoutIncludesOpaqueBars=YES;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"songsList_bg"]];
    self.tableView.backgroundView=bgImageView;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.searchController.searchBar.backgroundImage=[UIImage imageWithColor:[UIColor clearColor]];
    self.searchController.hidesNavigationBarDuringPresentation=NO;
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self hidePromptView:NO];

    //open database
    _searchDb = [DataMananager instanceShare].db;
    [_searchDb open];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);

    [self hidePromptView:YES];
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    NSLog(@"%s",__func__);
    // do something after the search controller is dismissed
    [self hidePromptView:NO];
}

- (void)hidePromptView:(BOOL)hide {
    if (!promtView) {
        [self createDefaultView];
    }
    promtView.hidden=hide;
}

- (void)createDefaultView {
    promtView=[[UIView alloc]initWithFrame:CGRectMake(self.view.center.x-300/2, 10, 300, 150)];
    UILabel *labelStr=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
    labelStr.numberOfLines=0;
    labelStr.textColor=[UIColor groupTableViewBackgroundColor];
    labelStr.font=[UIFont systemFontOfSize:15];
    labelStr.text=NSLocalizedString(@"searchcomment_searchVC", ni);
    [labelStr sizeToFit];
    [promtView addSubview:labelStr];
    [self.view addSubview:promtView];
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
//    APLProduct *product = self.products[indexPath.row];
//    [self configureCell:cell forProduct:product];
//    
    return cell;
}

// here we are the table view delegate for both our main table and filtered table, so we can
// push from the current navigation controller (resultsTableController's parent view controller
// is not this UINavigationController)
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = (tableView == self.tableView) ?
        self.products[indexPath.row] : self.resultsTableController.filteredProducts[indexPath.row];
    SongListViewController *songVC=[[SongListViewController alloc]init];
    if ([object isKindOfClass:[Singer class]]) {
        songVC.singerName=[(Singer*)object singer];
        songVC.needLoadData=YES;
    } else {
        songVC.needLoadData=NO;
        [songVC setDataList:object];
    }
    [self.navigationController pushViewController:songVC animated:NO];
    
    
//    APLDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"APLDetailViewController"];
//    detailViewController.product = selectedProduct; // hand off the current product to the detail view controller
//    
//    [self.navigationController pushViewController:detailViewController animated:YES];
//    
//    // note: should not be necessary but current iOS 8.0 bug (seed 4) requires it
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    return CGFLoat height=(tableView == self.tableView)?0.0f:60.0f;
//}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    APLResultsTableController *tableController = (APLResultsTableController *)self.searchController.searchResultsController;
  [_queue cancelAllOperations];
  NSMutableArray *searchResult=[[NSMutableArray alloc]init];
    NSString *searchStr=[searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  NSString *enCodeSearchStr = [[searchStr uppercaseString] encodeBase64];
   NSBlockOperation *operationSong=[NSBlockOperation blockOperationWithBlock:^{
       if (searchStr && searchStr.length>0) {
            [searchResult addObjectsFromArray:[self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"]];
               NSLog(@"song done!");
       }
   }];

    NSBlockOperation *operationSinger=[NSBlockOperation blockOperationWithBlock:^{
        if (searchStr && searchStr.length>0) {
            [searchResult addObjectsFromArray:[self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"]];
        }}];
        
    [_queue addOperations:@[operationSinger,operationSong] waitUntilFinished:YES];
    [_queue waitUntilAllOperationsAreFinished];
    dispatch_group_notify(group,dispatch_get_main_queue(), ^{
        tableController.filteredProducts=searchResult;
        [tableController.tableView reloadData];
    });


}

- (void)initializeTableContent:(NSString*)searchStr {
//    NSString *enCodeSearchStr = [[searchStr uppercaseString] encodeBase64];
//    if (_searchResult==nil) {
//        _searchResult=[[NSMutableArray alloc]init];
//    }
////    [searchArray addObject:enCodeSearchStr];
////    if (_searchSelectIndex == searchAll) {
//        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
//        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
    
//        
//    }else if (_searchSelectIndex == searchSong){
//        [self searchSongData:SONGTABLE :@"songpiy" :enCodeSearchStr :@"songname"];
//    }else {
//        [self searchSingData:SINGERTABLE :@"pingyin" :enCodeSearchStr :@"singer"];
//    }
//    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    
}

#pragma mark - sql method
- (NSArray *)searchSongData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSMutableArray *songs=[[NSMutableArray alloc]init];
    NSString *temStr = [NSString stringWithFormat:@"%@%@%@",@"%",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE songname LIKE '%@' OR %@ LIKE '%@'" ,tableName,temStr,conditionColumn,temStr];
    //    NSLog(@"song:\n%@",sql);
    FMResultSet *rs = [_searchDb executeQuery:sql];
    while ([rs next]) {
        Song *oneSong=[[Song alloc]init];
        oneSong.addtime = [rs stringForColumn:@"addtime"];
        oneSong.bihua = [rs stringForColumn:@"bihua"];
        oneSong.channel = [rs stringForColumn:@"channel"];
        oneSong.language = [rs stringForColumn:@"language"];
        oneSong.movie = [rs stringForColumn:@"movie"];
        oneSong.newsong = [rs stringForColumn:@"newsong"];
        oneSong.number = [rs stringForColumn:@"number"];
        oneSong.pathid = [rs stringForColumn:@"pathid"];
        oneSong.sex = [rs stringForColumn:@"sex"];
        oneSong.singer = [rs stringForColumn:@"singer"];
        oneSong.singer1 = [rs stringForColumn:@"singer1"];
        oneSong.songname = [rs stringForColumn:@"songname"];
        oneSong.songpiy = [rs stringForColumn:@"songpiy"];
        oneSong.spath = [rs stringForColumn:@"spath"];
        oneSong.stype = [rs stringForColumn:@"stype"];
        oneSong.volume = [rs stringForColumn:@"volume"];
        oneSong.word = [rs stringForColumn:@"word"];
        [songs addObject:oneSong];
    }
    return songs;
} // limit 20

- (NSArray*)searchSingData:(NSString*)tableName :(NSString*)conditionColumn :(NSString*)searchStr :(NSString*)column {
    NSMutableArray *singers=[[NSMutableArray alloc]init];
    NSString *temStr = [NSString stringWithFormat:@"%@%@%@",@"%",searchStr,@"%"];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE singer LIKE '%@' OR  %@ LIKE '%@'",tableName,temStr,conditionColumn,temStr];
    //    NSLog(@"singer:\n%@",sql);
    FMResultSet *rs = [_searchDb executeQuery:sql];
    while ([rs next]) {
        Singer *oneSinger=[[Singer alloc]init];
        oneSinger.area = [rs stringForColumn:@"area"];
        oneSinger.pingyin = [rs stringForColumn:@"pingyin"];
        oneSinger.s_bi_hua = [rs stringForColumn:@"s_bi_hua"];
        oneSinger.singer = [rs stringForColumn:@"singer"];
        //        NSLog(@"%@",oneSinger.singer);
        [singers addObject:oneSinger];
        
    }
    return singers;
}


#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}

@end

