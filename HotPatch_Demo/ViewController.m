//
//  ViewController.m
//  HotPatch_Demo
//
//  Created by 陈小明 on 2017/8/14.
//  Copyright © 2017年 陈小明. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "SSZipArchive.h"
#import "UIViewAdditions.h"

@interface ViewController ()
{
    NSString *_filePathOne;
    NSString *_filepathTwo;
    UIProgressView *_progressView;
    UILabel *_progressLabel;
    NSString *_destinationPath;//文件路径
    NSString *_destinationPathX;//重新下载的文件路径
    NSString *_newPath;//新的保存的路径
}
@end

/*
 * 判断文件是否存在
 * 不存在 ->下载文件 ->解压->加载framework
 * 存在 - >下载重命名文件 ->比较两个文件是否相同
 * 是 -> 不更新
 * 否 -> 更新framewok
 * Download_Url 是你上传的framework的下载地址
 */
#define Download_Url @"https://github.com/chenXming/HotPatch/archive/master.zip"


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
   
    [self makeProgressView];
    
    [self compareAndLoadFile];
}
-(void)initData{

    self.title = @"正在检查更新...";
    self.view.backgroundColor =[UIColor cyanColor];
    
    _destinationPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/HotPatch-master"]];
    
    _destinationPathX = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/HotPatch-masterX"]];
    
    _newPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/HotPatch-masterX/HotPatch-master"]];
    
}
-(void)makeProgressView{

    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.tintColor = [UIColor redColor];
    _progressView.progressTintColor = [UIColor whiteColor];
    _progressView.progress  =0.0f;
    [self.view addSubview:_progressView];

    
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(320, 85, 50, 30)];
    _progressLabel.text = @"0%";
    _progressLabel.textColor = [UIColor redColor];
    _progressLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_progressLabel];
    
}
#pragma mark - 两个下载方法
-(void)downloadFile{

    //下载保存的路径
    NSString *savedPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/HotPatch-master.zip"]];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"GET" URLString:Download_Url parameters:nil error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        _progressView.progress  =progress;
        _progressLabel.text = [NSString stringWithFormat:@"%.2f%%",progress*100];
        NSLog(@"progress==%.2f",progress);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"下载成功");
        NSString *destinationPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents"]];
        //对下载下来的ZIP包进行解压
        BOOL isScu = [SSZipArchive unzipFileAtPath:savedPath toDestination:destinationPath];
        
        if(isScu){
            NSLog(@"解压成功");
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:savedPath];
            if (bRet) {
                [fileMgr removeItemAtPath:savedPath error:nil];//解压成功后删除压缩包
            }

            [self reloadFramework];
            
        }else{
            NSLog(@"解压失败 --- 开启失败");
        
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"error===%@",error);
       
        NSLog(@"下载失败 --- 开启失败");
        
    }];
    
    [operation start];

}
-(void)reDownloadFile{

    //重新下载保存的路径
    NSString *savedPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/HotPatch-masterX.zip"]];
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request = [serializer requestWithMethod:@"GET" URLString:Download_Url parameters:nil error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        _progressView.progress  =progress;
        _progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];

        NSLog(@"progress==%.2f",progress);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"下载成功");
        
        //对下载下来的ZIP包进行解压
        BOOL isScu = [SSZipArchive unzipFileAtPath:savedPath toDestination:_destinationPathX];
        
        if(isScu){
            NSLog(@"解压成功");
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:savedPath];
            if (bRet) {
                [fileMgr removeItemAtPath:savedPath error:nil];//解压成功后删除压缩包
            }
            // 比较俩个文件
            [self compareFile];
            
            
        }else{
            NSLog(@"解压失败 --- 开启失败");
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        NSLog(@"error===%@",error);
        
        NSLog(@"下载失败 --- 开启失败");
        
    }];
    
    [operation start];


}
#pragma mark - 比较文件
-(void)compareFile{
    

    NSArray *arrFramework = [self getFilenamelistOfType:@"framework" fromDirPath:_destinationPath];
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",_destinationPath,[arrFramework lastObject]];
    _filePathOne = bundlePath;
    
    NSLog(@"_filePathOne===%@",_filePathOne);
    //获取framework的路径名

    NSArray *arrFrameworkX = [self getFilenamelistOfType:@"framework" fromDirPath:_newPath];
    NSString *bundlePathX = [NSString stringWithFormat:@"%@/%@",_newPath,[arrFrameworkX lastObject]];
    _filepathTwo = bundlePathX;
    
    NSLog(@"_filepathTwo==%@",_filepathTwo);
    
    if ([[NSFileManager defaultManager] contentsEqualAtPath:_filePathOne andPath:_filepathTwo]) {
        NSLog(@"文件相同");
        
        [[NSFileManager defaultManager] removeItemAtPath:_destinationPathX error:nil];//删除下载的文件
        
        [self reloadFramework];
        
    }else{
    
        NSLog(@"文件不同");
        [[NSFileManager defaultManager] removeItemAtPath:_destinationPath error:nil];//删除旧的下载的文件
       
        // 移动文件到Documents文件下
        NSError *error = nil;
        if ([[NSFileManager defaultManager] moveItemAtPath:_newPath toPath:_destinationPath error:&error] == YES){

            [[NSFileManager defaultManager] removeItemAtPath:_destinationPathX error:nil];//删除旧的文件

            NSLog(@"重命名成功！");
            [self reloadFramework];
            
        }else{
            NSLog(@"Unable to move file: %@", [error localizedDescription]);
            
        }
    }
}
#pragma mark - 下载以及比较文件
-(void)compareAndLoadFile{
    
    NSArray *arrFramework = [self getFilenamelistOfType:@"framework" fromDirPath:_destinationPath];
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",_destinationPath,[arrFramework lastObject]];
    
    NSLog(@"path===%@",bundlePath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
        NSLog(@"文件不存在");
        
        NSString *requestURL = Download_Url;
        if(requestURL==nil || requestURL.length==0){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有下载地址，不能开启" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *sureBtn = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:sureBtn];
          
            return;
            
        }else{
            
            NSLog(@"去下载");

            [self downloadFile];
        }
        
    }else{
        
        NSLog(@"文件存在！");
        // 重新下载文件 命名不同
        [self reDownloadFile];

    }
}
#pragma mark - 加载framework
-(void)reloadFramework{
    
    NSArray *arrFramework = [self getFilenamelistOfType:@"framework" fromDirPath:_destinationPath];
    
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@",_destinationPath,[arrFramework lastObject]];
    
    NSLog(@"bundlePath==%@",bundlePath);
    
    _filePathOne = bundlePath;
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (!bundle || ![bundle load]) {
        NSLog(@"bundle加载出错");
    }
    // 下载的framework的封装的文件名
    NSString *className = @"HotPatchViewController";
    NSString *classtype = @"UIViewController";
    
    Class loadClass = [bundle classNamed:className];
    if (!loadClass) {
        NSLog(@"获取失败");
    }
    if([classtype isEqualToString:@"UIViewController"]){
        
        NSLog(@"成功了。。。");
        UIViewController *uvc = (UIViewController*)[loadClass new];
        [self.navigationController pushViewController:uvc animated:YES];
        
    }
}

- (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath{
    NSArray *fileList = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil] pathsMatchingExtensions:[NSArray arrayWithObject:type]];
    return fileList;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
