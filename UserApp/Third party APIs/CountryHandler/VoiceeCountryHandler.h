//
//  VoiceeCountryHandler.h
//  TimeToEnjoy
//
//  Created by Lakshaya Chhabra on 20/03/12.
//  Copyright (c) 2012 TimeToEnjoy.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define TTELocationDB_NAME @"VoiceeCountryList.sqlite" // Name of databse


@interface VoiceeCountryHandler : NSObject

-(void)prepareDataBace;
- (NSMutableArray *)fetchCityListData:(NSString *)queryString;
- (NSMutableArray *)FetchCountry;
- (NSMutableArray *)fetchCityStateCountryZipListData;


@end
