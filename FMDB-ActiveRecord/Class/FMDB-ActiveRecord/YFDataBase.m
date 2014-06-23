//
//  YFDataBase.m
//  FMDB-ActiveRecord
//
//  Created by   颜风 on 14-6-21.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "YFDataBase.h"

@interface YFDataBase ()

// !!!:提供对多线程的支持吗?block可以很好地支持多线程的!FMDB支持多线程吗?
#pragma mark - 私有属性.
@property (retain, nonatomic) NSMutableArray * arSelect;
@property (assign, nonatomic)           BOOL   arDistinct;
@property (retain, nonatomic) NSMutableArray * arFrom;
@property (retain, nonatomic) NSMutableArray * arJoin;
@property (retain, nonatomic) NSMutableArray * arWhere;
@property (retain, nonatomic) NSMutableArray * arLike;
@property (retain, nonatomic) NSMutableArray * arGroupby;
@property (retain, nonatomic) NSMutableArray * arHaving;
@property (retain, nonatomic) NSMutableArray * arKeys;
@property (assign, nonatomic)           BOOL   arLimit;
@property (assign, nonatomic)           BOOL   arOffset;
@property (assign, nonatomic)           BOOL   arOrder;
@property (retain, nonatomic) NSMutableArray * arOrderby;
@property (retain, nonatomic) NSMutableArray * arSet;
@property (retain, nonatomic) NSMutableArray * arWherein;
@property (retain, nonatomic) NSMutableArray * arAliasedTables;
@property (retain, nonatomic) NSMutableArray * arStoreArray;

// Active Record 缓存属性.
@property (assign, nonatomic)           BOOL   arCaching;
@property (retain, nonatomic) NSMutableArray * arCacheExists;
@property (retain, nonatomic) NSMutableArray * arCacheSelect;
@property (retain, nonatomic) NSMutableArray * arCacheFrom;
@property (retain, nonatomic) NSMutableArray * arCacheJoin;
@property (retain, nonatomic) NSMutableArray * arCacheWhere;
@property (retain, nonatomic) NSMutableArray * arCacheLike;
@property (retain, nonatomic) NSMutableArray * arCacheGroupby;
@property (retain, nonatomic) NSMutableArray * arCacheHaving;
@property (retain, nonatomic) NSMutableArray * arCacheOrderby;
@property (retain, nonatomic) NSMutableArray * arCacheSet;

#pragma mark - 私有方法.
/**
 *  为下面四个公开方法服务.
 *
 *  selectMax:alias:
 *  selectMin:alias:
 *  selectAvg:alias:
 *  selectSum:alias:
 *
 *  @param field  字段.
 *  @param alias  别名.
 *  @param type   类型.
 *
 *  @return 实例对象自身.
 */
- (YFDataBase *) YFDBMaxMinAvgSum: (NSString *) field
                            alias: (NSString *) alias
                             type: (NSString *) type;

/**
 *  根据表来产生别名.
 *
 *  @param item 一项.
 *
 *  @return 此项对应的别名.
 */
- (NSString *) YFDBCreateAliasFromTable: (NSString *) item;

/**
 *  供where: 和orWhere:type:调用.
 *
 *  @param where 一个字典,以字段或包含操作符的字段为key,以条件值为value.
 *  @param type  类型.
 *
 *  @return 实例对象自身.
 */
- (YFDataBase *) YFDBWhere: (NSDictionary *) where
                      type: (NSString *) type;

/**
 *  测试字符串是否含有一个SQL操作符.
 *
 *  @param str 字符串.
 *
 *  @return YES,含有;NO,不含有;
 */
- (BOOL) YFDBHasOperator: (NSString *) str;

/**
 *  清除字符串的首尾空白.
 *
 *  @param str 字符串.
 *
 *  @return 一个新的字符串.
 */
// !!!:有必要单独写一个类目吗?
- (NSString *) YFDBTrim: (NSString *) str;

// !!!:不建议同时支持 ","分隔的字符串和数组来表示多个对象.二选一吧!(前者更合理,可以使用正则来容错!)
- (YFDataBase *) YFDBWhereIN;
@end

@implementation YFDataBase

+ (instancetype) databaseWithPath: (NSString *)inPath
{
    return [[[self alloc] initWithPath: inPath] autorelease];
}

- (instancetype)initWithPath:(NSString *)inPath
{
    if (self = [super initWithPath: inPath]) {
        self.arSelect   = [NSMutableArray arrayWithCapacity: 42];
        self.arDistinct = NO;
        self.arFrom     = [NSMutableArray arrayWithCapacity: 42];
        self.arJoin     = [NSMutableArray arrayWithCapacity: 42];
        self.arWhere    = [NSMutableArray arrayWithCapacity: 42];
        self.arLike     = [NSMutableArray arrayWithCapacity: 42];
        self.arGroupby  = [NSMutableArray arrayWithCapacity: 42];
        self.arHaving   = [NSMutableArray arrayWithCapacity: 42];
        self.arKeys     = [NSMutableArray arrayWithCapacity: 42];
        self.arLimit    = NO;
        self.arOffset   = NO;
        self.arOrder    = NO;
        self.arOrderby  = [NSMutableArray arrayWithCapacity: 42];
        self.arSet      = [NSMutableArray arrayWithCapacity: 42];
        self.arWherein  = [NSMutableArray arrayWithCapacity: 42];
        self.arAliasedTables = [NSMutableArray arrayWithCapacity: 42];
        self.arStoreArray = [NSMutableArray arrayWithCapacity: 42];
        
        self.arCaching = NO;
        self.arCacheExists = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheSelect = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheFrom = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheJoin = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheWhere = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheLike = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheGroupby = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheHaving = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheOrderby = [NSMutableArray arrayWithCapacity: 42];
        self.arCacheSet = [NSMutableArray arrayWithCapacity: 42];
    }
    
    return self;
}

- (void)dealloc
{
    self.arSelect   = nil;
    self.arFrom     = nil;
    self.arJoin     = nil;
    self.arWhere    = nil;
    self.arLike     = nil;
    self.arGroupby  = nil;
    self.arHaving   = nil;
    self.arKeys     = nil;
    self.arOrderby  = nil;
    self.arSet      = nil;
    self.arWherein  = nil;
    self.arAliasedTables = nil;
    self.arStoreArray = nil;
    
    self.arCacheExists = nil;
    self.arCacheSelect = nil;
    self.arCacheFrom = nil;
    self.arCacheJoin = nil;
    self.arCacheWhere = nil;
    self.arCacheLike = nil;
    self.arCacheGroupby = nil;
    self.arCacheHaving = nil;
    self.arCacheOrderby = nil;
    self.arCacheSet = nil;
    
    [super dealloc];
}

- (YFDataBase *)select: (NSString *) field
{
    NSArray * fields = [(NSString *)select componentsSeparatedByString:@","];
    
    [fields enumerateObjectsUsingBlock:^(NSString * val, NSUInteger idx, BOOL *stop) {
        val = [self YFDBTrim: val];

        if (NO == [val isEqualToString: @""]) {
            [self.arSelect      addObject: val];
            
            if (YES == self.arCaching) {
                [self.arCacheSelect     addObject: val];
                [self.arCacheExists     addObject: @"select"];//!!!: 为什么不用大写?
            }
        }
        
    }];
    
    return self;
}

- (YFDataBase *) selectMax: (NSString *) field
                     alias: (NSString *) alias
{
    return [self YFDBMaxMinAvgSum: field alias: alias type: @"MAX"];
}

- (YFDataBase *) selectMin: (NSString *) field
                     alias: (NSString *) alias
{
    return [self YFDBMaxMinAvgSum: field alias: alias type: @"MIN"];
}

- (YFDataBase *) selectAvg: (NSString *) field
                     alias: (NSString *) alias
{
    return [self YFDBMaxMinAvgSum: field alias: alias type: @"AVG"];
}

- (YFDataBase *) selectSum: (NSString *) field
                     alias: (NSString *) alias
{
    return [self YFDBMaxMinAvgSum: field alias: alias type: @"SUM"];
}

- (YFDataBase *) selectMax: (NSString *) field
{
    return [self selectMax: field alias: nil];
}

- (YFDataBase *) selectMin: (NSString *) field
{
    return [self selectMin: field alias: nil];
}

- (YFDataBase *) selectAvg: (NSString *) field
{
    return [self selectAvg: field alias: nil];
}

- (YFDataBase *) selectSum: (NSString *) field
{
    return [self selectSum: field alias: nil];
}

- (YFDataBase *) distinct: (BOOL) distinct
{
    self.arDistinct = distinct;
    return self;
}

- (YFDataBase *) from: (NSString *) table
{
    if (NSNotFound == [table rangeOfString: @","].location) {
        table = [self YFDBTrim: table];
        
        [self.arFrom addObject: table];
        
        if (YES == self.arCaching) {
            [self.arCacheFrom addObject: table];
            [self.arCacheExists addObject: @"from"];
        }
        
        return self;
    }
    
    [[table componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL *stop) {
        obj = [self YFDBTrim: obj];
        
        [self.arFrom addObject: obj];
        
        if (YES == self.arCaching) {
            [self.arCacheFrom addObject: obj];
            [self.arCacheExists addObject: @"from"];
        }
    }];
    
    return self;
}

- (YFDataBase *) join: (NSString *) table
             condtion: (NSString *) condtion
                 type: (NSString *) type
{
    if (nil == type) {
        type = @"";
    }
    
    if (NO == [type isEqualToString: @""]) {
        type = [type uppercaseString];
        
        // ???:以下几种,sqlite都支持吗?
        if (NO == [@[@"LEFT", @"RIGHT", @"OUTER", @"INNER", @"LEFT OUTER", @"RIGHT OUTER"] containsObject: type]) {
            type = @"";
        }
        
    }
    
    // 拼接 JOIN 语句.
    NSString * join = [NSString stringWithFormat: @"%@ JOIN %@ ON %@", type, table, condtion];

    [self.arJoin addObject: join];
    
    if (YES == self.arCaching) {
        [self.arCacheJoin addObject: join];
        [self.arCacheExists addObject: @"join"];
    }
    
    return self;
}

// !!!:复杂的SQL语句,真的支持吗?试一下!
- (YFDataBase *) join: (NSString *) table
             condtion: (NSString *) condtion
{
    return [self join: table condtion: condtion type: nil];
}

- (YFDataBase *) where: (NSDictionary *)where
{
    return [self YFDBWhere: where type: @"AND"];
}

- (YFDataBase *) orWhere: (NSDictionary *) where
{
    return [self YFDBWhere: where type: @"OR"];   
}
#pragma mark - 私有方法.
- (YFDataBase *) YFDBMaxMinAvgSum: (NSString *) field
                            alias: (NSString *) alias
                             type: (NSString *) type
{
    if (NO == [field isKindOfClass: [NSString class]] || YES == [field isEqualToString:@""]) {
        // !!!:无法匹配语法
//        $this->display_error('db_invalid_query');
    }
    
    type = [type uppercaseString];
    
    if (NO == [@[@"MAX", @"MIN", @"AVG", @"SUM"] containsObject: type]) {
        // !!!:无法匹配语法
//        show_error('Invalid function type: '.$type);
    }
    
    if (nil == alias || [alias isEqualToString: @""]) {
        alias = [self YFDBTrim: field];
    }
    
    NSString * sql = [NSString stringWithFormat: @"%@(%@) AS %@", type, field, alias];
    
    [self.arSelect addObject: sql];
    
    if (YES == self.arCaching) {
        [self.arCacheSelect addObject: sql];
        [self.arCacheExists addObject: @"select"];
    }
    
    return self;
}

- (NSString *) YFDBCreateAliasFromTable: (NSString *) item
{
    if (NSNotFound != [item rangeOfString:@"."].location) {
        return [[item componentsSeparatedByString: @"."] lastObject];
    }
    
    return item;
}

- (YFDataBase*) YFDBWhere: (NSDictionary *) where
                     type: (NSString *) type
{
    type = [type uppercaseString];
    
    [where enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
        NSString * prefix = type;
        if (0 == self.arWhere.count && 0 == self.arCacheWhere.count) {
            prefix = @"";
        }
        
        if (NO == [self YFDBHasOperator: key]) {
            NSString * operator = @" =";
            
            if ([NSNull null] == obj) {
                operator = @" IS NULL";
            }
            
            key = [key stringByAppendingString: operator];
        }
        
        if ([NSNull null] == obj) {
            obj = @"";
        }
        
        [self.arWhere addObject: [NSString stringWithFormat: @"%@ %@ %@ ", prefix, key, obj]];

        if (YES == self.arCaching) {
            [self.arCacheWhere addObject: [NSString stringWithFormat: @"%@ %@ %@ ", prefix, key, obj]];
            [self.arCacheExists addObject: @"where"];
        }
        
    }];
    
    return self;
}

- (BOOL) YFDBHasOperator: (NSString *) str
{
    str = [self YFDBTrim: str];
    
    NSRegularExpression * regExp = [NSRegularExpression regularExpressionWithPattern: @"(\\s|<|>|!|=|is null|is not null)" options: NSRegularExpressionCaseInsensitive error: nil];
    NSRange range = [regExp rangeOfFirstMatchInString: str options:0 range: NSMakeRange(0, str.length)];
    if (NSNotFound == range.location) {
        return NO;
    }
    
    return YES;
}

- (NSString *) YFDBTrim: (NSString *) str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
