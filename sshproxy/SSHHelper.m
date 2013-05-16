//
//  SSHHelper.m
//  sshproxy
//
//  Created by Brant Young on 15/5/13.
//  Copyright (c) 2013 Charm Studio. All rights reserved.
//

#import "SSHHelper.h"

@implementation SSHHelper


+ (NSMutableArray*) getConnectArgs
{
    NSString* userHome = NSHomeDirectory();
    NSString* knownHostFile= [userHome stringByAppendingPathComponent:@".sshproxy_known_hosts"];
    NSString* identityFile= [userHome stringByAppendingPathComponent:@".sshproxy_identity"];
    //    NSString* configFile= [userHome stringByAppendingPathComponent:@".sshproxy_config"];
    
    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:
                                 [NSString stringWithFormat:@"-oUserKnownHostsFile=\"%@\"", knownHostFile],
                                 [NSString stringWithFormat:@"-oGlobalKnownHostsFile=\"%@\"", knownHostFile],
                                 [NSString stringWithFormat:@"-oIdentityFile=\"%@\"", identityFile],
                                 // TODO:
                                 //                        [NSString stringWithFormat:@"-F \"%@\"", configFile],
                                 @"-oIdentitiesOnly=yes",
                                 @"-oPubkeyAuthentication=no",
                                 @"-T", @"-2", @"-a",
                                 @"-oConnectTimeout=8", @"-oConnectionAttempts=3",
                                 @"-oServerAliveInterval=8", @"-oServerAliveCountMax=1",
                                 @"-oStrictHostKeyChecking=no", @"-oExitOnForwardFailure=yes",
                                 @"-oLogLevel=DEBUG",
                                 @"-oPreferredAuthentications=password",
                                 nil];
    
    return arguments;
}

// for ProxyCommand Env
+ (NSDictionary*) getProxyCommandEnv:(NSDictionary*) server
{
    NSMutableDictionary* env = [NSMutableDictionary dictionary];
    
    BOOL proxyCommand = [(NSNumber *)[server valueForKey:@"proxy_command"] boolValue];
    BOOL proxyCommandAuth = [(NSNumber *)[server valueForKey:@"proxy_command_auth"] boolValue];
    
    NSString* proxyCommandUsername = (NSString *)[server valueForKey:@"proxy_command_username"];
    NSString* proxyCommandPassword = (NSString *)[server valueForKey:@"proxy_command_password"];
    
    if (proxyCommand && proxyCommandAuth) {
        if (proxyCommandUsername) {
            [env setValue:@"YES" forKey:@"HTTP_PROXY_FORCE_AUTH"];
            [env setValue:proxyCommandUsername forKey:@"CONNECT_USER"];
            if (proxyCommandPassword) {
                [env setValue:proxyCommandPassword forKey:@"CONNECT_PASSWORD"];
            }
        }
    }
    
    return env;
}

// for ProxyCommand
+ (NSString*)getProxyCommandStr:(NSDictionary*) server
{
    NSString *connectPath = [NSBundle pathForResource:@"connect" ofType:@""
                                          inDirectory:[[NSBundle mainBundle] bundlePath]];
    
    BOOL proxyCommand = [(NSNumber *)[server valueForKey:@"proxy_command"] boolValue];
    int proxyCommandType = [(NSNumber *)[server valueForKey:@"proxy_command_type"] intValue];
    NSString* proxyCommandHost = (NSString *)[server valueForKey:@"proxy_command_host"];
    int proxyCommandPort = [(NSNumber *)[server valueForKey:@"proxy_command_port"] intValue];
    
    NSString* proxyCommandStr = nil;
    if (proxyCommand){
        if (proxyCommandHost) {
            NSString* proxyType = @"-S";
            
            switch (proxyCommandType) {
                case 0:
                    proxyType = @"-5 -S";
                    break;
                case 1:
                    proxyType = @"-4 -S";
                    break;
                case 2:
                    proxyType = @"-H";
                    break;
            }
            
            if (proxyCommandPort<=0 || proxyCommandPort>65535) {
                proxyCommandPort = 1080;
            }
            
            proxyCommandStr = [NSString stringWithFormat:@"-oProxyCommand=\"%@\" -d -w 8 %@ %@:%d %@", connectPath, proxyType, proxyCommandHost, proxyCommandPort, @"%h %p"];
        }
    }
    
    return proxyCommandStr;
}

+ (NSInteger) getActivatedServerIndex
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray* servers = [prefs arrayForKey:@"servers"];
    NSInteger index = [prefs integerForKey:@"activated_server"];
    
    if (index<0 || index>=servers.count) {
        index = 0;
    }
    
    return index;
}

+ (NSDictionary*) getActivatedServer
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray* servers = [prefs arrayForKey:@"servers"];
    
    if ( [servers count]<=0 ){
        return nil;
    }
    
    NSInteger index = [SSHHelper getActivatedServerIndex];
    return servers[index];
}

+ (void) setActivatedServer:(int) index
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:index forKey:@"activated_server"];
    [prefs synchronize];
}

@end
