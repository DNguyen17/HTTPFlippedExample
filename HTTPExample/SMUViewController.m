//
//  SMUViewController.m
//  HTTPExample
//
//  Copyright (c) 2014 Eric Larson. All rights reserved.
//

#import "SMUViewController.h"
#import "HttpCommHandler.h"

@interface SMUViewController ()
- (IBAction)sendPostRequest:(id)sender;
- (IBAction)updateArgumentValue:(id)sender;
- (IBAction)sendGetRequest:(id)sender;
- (IBAction)sendPostArray:(id)sender;
- (IBAction)getDataSetId:(id)sender;
- (IBAction)updateModel:(id)sender;
- (IBAction)predictFeature:(id)sender;

@property (strong, nonatomic) NSNumber* value;

@end

@implementation SMUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.value = @(0.5);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendPostRequest:(id)sender {
    
    NSURL* url = [NSURL URLWithString:@"http://eric-mac-pro.local:8000/DoPost"];

    NSData *requestBody=[[NSString stringWithFormat:@"arg1=%f",[self.value floatValue]]
                         dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
    NSString *response = [httpHandler sendPostRequestTo:url withBody:requestBody];
    
    NSDictionary* responseData = [httpHandler getTupleFromJSONString:response];
    
    NSString *arg1 = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"arg1"]];
    
    NSLog(@"received %@",arg1);

}



//-(void)sendPostArray{
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
//    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
//    
//    documentsDirectoryPath= [documentsDirectoryPath stringByAppendingString:@"/"];
//    documentsDirectoryPath = [documentsDirectoryPath stringByAppendingString:@"temp.txt"];
//    
//    const char *filePathString;
//    
//    filePathString = [documentsDirectoryPath UTF8String];
//    
//    FILE *fid = fopen(filePathString,"w");
//    fprintf(fid,"%f,%f,%f\n",[self.value floatValue],1.0,10.1);
//    fclose(fid);
//    
//    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
//    NSURL *url = [NSURL URLWithString:@"http://users-mac-Mini.local:8000/Upload"];
//    
//    NSData *myData = [NSData dataWithContentsOfFile:documentsDirectoryPath];
//    
//    NSString *fileName = [NSString stringWithFormat:@"%f",CFAbsoluteTimeGetCurrent()];
//    
//    NSString *secondResponse = [httpHandler sendPostWithData:myData at:url withFileName:fileName andServerSessionID:@"1_1_1"];
//    
//}


- (IBAction)updateArgumentValue:(UISlider*)sender {
    self.value = @(sender.value);
}

- (IBAction)sendGetRequest:(id)sender {
    
    NSString* url = [[NSString alloc]initWithFormat:@"http://users-mac-mini.local:8000/DoPost?arg1=%.2f",
                     [self.value floatValue]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod: @"GET"];
    
    NSError *requestError;
    NSHTTPURLResponse *urlResponse = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                              returningResponse:&urlResponse
                                                          error:&requestError];
    
    NSString* newStr = [[NSString alloc] initWithData:responseData
                                             encoding:NSUTF8StringEncoding];
    
    NSInteger code = [urlResponse statusCode];
    
    NSLog(@" recieved \"%@\" from server \n code: %ld",newStr,(long)code);
}

- (IBAction)sendPostArray:(id)sender {
    
    NSURL* url = [NSURL URLWithString:@"http://users-mac-Mini.local:8000/AddDataPoint"];
    
    float data = drand48()*10.0;
    NSData *requestBody=[[NSString stringWithFormat:@"feature=%f,%f,%f&label=%d&dsid=1",data,data*drand48(),data*data,(int)data]
                         dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
    NSString *response = [httpHandler sendPostRequestTo:url withBody:requestBody];
    
    NSDictionary* responseData = [httpHandler getTupleFromJSONString:response];
    
    NSString *featuresResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"feature"]];
    NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"label"]];
    NSLog(@"received %@ and %@",featuresResponse,labelResponse);
}

- (IBAction)getDataSetId:(id)sender {
    NSURL* url = [NSURL URLWithString:@"http://users-mac-Mini.local:8000/GetNewDatasetId"];
    
    NSData *requestBody=[@"" dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
    NSString *response = [httpHandler sendPostRequestTo:url withBody:requestBody];
    
    NSDictionary* responseData = [httpHandler getTupleFromJSONString:response];
    
}

- (IBAction)updateModel:(id)sender {
    NSURL* url = [NSURL URLWithString:@"http://users-mac-Mini.local:8000/UpdateModel"];
    
    NSData *requestBody=[@"dsid=1" dataUsingEncoding:NSUTF8StringEncoding];
    
    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
    NSString *response = [httpHandler sendPostRequestTo:url withBody:requestBody];
    
    NSDictionary* responseData = [httpHandler getTupleFromJSONString:response];
}

- (IBAction)predictFeature:(id)sender {
    NSURL* url = [NSURL URLWithString:@"http://users-mac-Mini.local:8000/PredictOne"];
    
    float data = drand48()*10.0;
    NSData *requestBody=[[NSString stringWithFormat:@"feature=%f,%f,%f&dsid=1",data,data*drand48(),data*data]
                         dataUsingEncoding:NSUTF8StringEncoding];
    int label = (int)data;
    
    HttpCommHandler *httpHandler = [[HttpCommHandler alloc]init];
    NSString *response = [httpHandler sendPostRequestTo:url withBody:requestBody];
    
    NSDictionary* responseData = [httpHandler getTupleFromJSONString:response];
    
    NSString *labelResponse = [NSString stringWithFormat:@"%@",[responseData valueForKey:@"prediction"]];
    NSLog(@"Actual label:%d prediction:%@",label,labelResponse);
}


@end
