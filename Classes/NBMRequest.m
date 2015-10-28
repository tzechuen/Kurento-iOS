//
//  NBMRequest.m
//  KurentoClient-iOS
//
//  Created by Marco Rossi on 22/09/15.
//  Copyright © 2015 Telecom Italia S.p.A. All rights reserved.
//

#import "NBMRequest+Private.h"

#import "NBMJSONRCPConstants.h"

@implementation NBMRequest

@synthesize requestId, method, parameters;

#pragma mark - Public

+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters
{
    return [NBMRequest requestWithMethod:method parameters:parameters requestId:nil];
}

#pragma mark - Private

+ (instancetype)requestWithMethod:(NSString *)method
                       parameters:(id)parameters
                        requestId:(NSNumber *)requestId
{
    NSParameterAssert(method);
    
    if (!parameters) {
        parameters = @{};
    }
    
    NSAssert([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSArray class]], @"Expect NSArray or NSDictionary in JSONRPC parameters");
    
    NBMRequest *request = [[NBMRequest alloc] init];
    request.method = method;
    request.parameters = parameters;
    request.requestId = requestId;
    
    return request;
}

+ (instancetype)requestWithJSONDicitonary:(NSDictionary *)json
{
    NSString *method = json[kMethodKey];
    id params = json[kParamsKey];
    NSNumber *requestId = json[kIdKey];
    
    return [NBMRequest requestWithMethod:method parameters:params requestId:requestId];
}

- (BOOL)isEqualToRequest:(NBMRequest *)request
{
    if (!request) {
        return NO;
    }
    
    BOOL hasEqualMethods = (!self.method && !request.method) || ([self.method isEqualToString:request.method]);
    BOOL hasEqualParams = (!self.parameters && !request.parameters) || ([self.parameters isEqualToDictionary:request.parameters]);
    BOOL hasEqualRequestIds = (!self.requestId && !request.requestId) || ([self.requestId isEqualToNumber:request.requestId]);
    
    return hasEqualMethods && hasEqualParams && hasEqualRequestIds;
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return  YES;
    }
    if (![object isKindOfClass:[NBMRequest class]]) {
        return NO;
    }
    
    return [self isEqualToRequest:(NBMRequest *)object];
}

- (NSUInteger)hash
{
    return [self.method hash] ^ [self.parameters hash] ^ [self.requestId hash];
}

- (NSString *)description {
    return self.debugDescription;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"[method: %@, params: %@ id: %@]",
            self.method, self.parameters, self.requestId];
}

#pragma mark - Message

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:kJsonRpcVersion forKey:kJsonRpcKey];
    [json setObject:self.method forKey:kMethodKey];
    [json setObject:self.parameters forKey:kParamsKey];
    if (self.requestId) {
        [json setObject:self.requestId forKey:kIdKey];
    }
    
    return [json copy];
}

@end
