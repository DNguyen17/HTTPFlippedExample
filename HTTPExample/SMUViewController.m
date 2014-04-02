//
//  SMUViewController.m
//  HTTPExample
//
//  Copyright (c) 2014 Eric Larson. All rights reserved.
//

#import "SMUViewController.h"

#define SERVER_URL "http://erics-macbook-pro.local:8000"

@interface SMUViewController () <NSURLSessionTaskDelegate>

@property (strong, nonatomic) NSNumber *value;
@property (strong,nonatomic) NSURLSession *session;
@property (strong,nonatomic) NSNumber *dsid;

@end

@implementation SMUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.value = @(0.5);
    _dsid = @1;
    
    //setup NSURLSession (background ephemeral)
    NSURLSessionConfiguration *sessionConfig =
    [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
//    [sessionConfig setHTTPAdditionalHeaders:
//     @{@"Accept": @"application/json"}];
    
    sessionConfig.timeoutIntervalForRequest = 5.0;
    sessionConfig.timeoutIntervalForResource = 8.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    
    self.session =
    [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:self
                             delegateQueue:nil];
    

}



- (IBAction)updateArgumentValue:(UISlider*)sender {
    self.value = @(sender.value);
}

- (IBAction)sendPostRequest:(id)sender {
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/DoPost",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    // data to send in body of post request (style of get arguments)
    NSData *requestBody=[[NSString stringWithFormat:@"arg1=%.4f",5.9]
                         dataUsingEncoding:NSUTF8StringEncoding];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];

    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &error];
        NSLog(@"%@",jsonDictionary);
    }];
    [postTask resume];

}


- (IBAction)sendJSONPostRequest:(id)sender {
    // an example for sending some data as JSON in the HTTP body
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/PostWithJson",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    // data to send in body of post request (send arguments as json)
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"arg":@[@3.2,@4.5,self.value]};
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"%@",response);
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
            NSLog(@"%@",jsonDictionary);
        }];
    [postTask resume];
    
}


- (IBAction)sendGetRequest:(id)sender {
    
    // create a GET request and get the reponse back as NSData
    NSString *baseURL = [NSString stringWithFormat:@"%s/GetExample",SERVER_URL];
    NSString *query = [NSString stringWithFormat:@"?arg=%.2f",0.45];
    
    
    NSURL *getUrl = [NSURL URLWithString: [baseURL stringByAppendingString:query]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:getUrl
                 completionHandler:^(NSData *data,
                                     NSURLResponse *response,
                                     NSError *error) {
                     NSLog(@"%@",response);
                     NSLog(@"%@",[[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]);
                     
                 }];
    [dataTask resume]; // start the task
}

- (IBAction)sendPostArray:(id)sender {
    // Add a data point and a label to the database for the current dataset ID
    
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/AddDataPoint",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    
    // make an array of feature data
    // and place inside a dictionary with the label and dsid
    float data = drand48()*10.0;
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"feature":@[@(data),@(data*drand48()),@(data*data)],
                                 @"label":@((int)data),
                                 @"dsid":self.dsid};
    
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSLog(@"%@",response);
         NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
         
         // we should get back the feature data from the server and the label it parsed
         NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
         NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
         NSLog(@"received %@ and %@",featuresResponse,labelResponse);
     }];
    [postTask resume];
}

- (IBAction)getDataSetId:(id)sender {
    // get a new dataset ID from the server (gives back a new dataset id)
    // Note that if data is not uploaded, the server may issue the same dsid to another requester
    // ---how might you solve this problem?---
    
    // create a GET request and get the reponse back as NSData
    NSString *baseURL = [NSString stringWithFormat:@"%s/GetNewDatasetId",SERVER_URL];

    NSURL *getUrl = [NSURL URLWithString: baseURL];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:getUrl
     completionHandler:^(NSData *data,
                         NSURLResponse *response,
                         NSError *error) {
         NSLog(@"%@",response);
         NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
         self.dsid = responseData[@"dsid"];
         NSLog(@"New dataset id is %@",self.dsid);
         
     }];
    [dataTask resume]; // start the task
    
}

- (IBAction)updateModel:(id)sender {
    // tell the server to train a new model for the given dataset id (dsid)
    
    // create a GET request and get the reponse back as NSData
    NSString *baseURL = [NSString stringWithFormat:@"%s/UpdateModel",SERVER_URL];
    NSString *query = [NSString stringWithFormat:@"?dsid=%d",[self.dsid intValue]];
    
    NSURL *getUrl = [NSURL URLWithString: [baseURL stringByAppendingString:query]];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:getUrl
         completionHandler:^(NSData *data,
                             NSURLResponse *response,
                             NSError *error) {
             // we should get back the accuracy of the model
             NSLog(@"%@",response);
             NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
             NSLog(@"Accuracy using resubstitution: %@",responseData[@"resubAccuracy"]);
             
         }];
    [dataTask resume]; // start the task
}

- (IBAction)predictFeature:(id)sender {
    // send the server new feature data and request back a prediction of the class
    
    // setup the url
    NSString *baseURL = [NSString stringWithFormat:@"%s/PredictOne",SERVER_URL];
    NSURL *postUrl = [NSURL URLWithString:baseURL];
    
    
    // data to send in body of post request (send arguments as json)
    float data = drand48()*10.0;
    int label = (int)data;
    NSError *error = nil;
    NSDictionary *jsonUpload = @{@"feature":@[@(data),@(data*drand48()),@(data*data)],
                                 @"dsid":self.dsid};
    
    NSData *requestBody=[NSJSONSerialization dataWithJSONObject:jsonUpload options:NSJSONWritingPrettyPrinted error:&error];
    
    // create a custom HTTP POST request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    // start the request, print the responses etc.
    NSURLSessionDataTask *postTask = [self.session dataTaskWithRequest:request
         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
             NSLog(@"%@",response);
             NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
             
             NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"prediction"]];
             NSLog(@"Actual label:%d prediction:%@",label,labelResponse);
         }];
    [postTask resume];
}


@end
