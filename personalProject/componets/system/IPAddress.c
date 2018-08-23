//
//  IPAddress.c
//  SuningEBuy
//
//  Created by 刘坤 on 11-12-6.
//  Copyright (c) 2011年 Suning. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <net/ethernet.h>

#include "IPAddress.h"

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))
#define BUFFERSIZE   4000

char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];

unsigned long ip_addrs[MAXADDRS];
static   int  nextAddr = 0;

void InitAddresses()
{
    for (int i = 0; i < MAXADDRS; i++)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        
        ip_addrs[i] = 0;
    }
}

void FreeAddresses()
{
    for (int i = 0; i < MAXADDRS; i++)
    {
        if (if_names[i] != 0)   free(if_names[i]);
        
        if (ip_names[i] != 0)   free(ip_names[i]);
        
        if (hw_addrs[i] != 0)   free(hw_addrs[i]);
        
        ip_addrs[i] = 0;    
    }
    InitAddresses();
}

//void GetHWAddresses()
//{
//    struct ifconf ifc;
//    struct ifreq *ifr;
//    int i, sockfd;
//    char buffer[BUFFERSIZE], *cp, *cplim;
//    char temp[80];
//    for (i=0; i<MAXADDRS; ++i)
//    {
//        hw_addrs[i] = NULL;
//    }
//    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
//    if (sockfd < 0)
//    {
//        perror("socket failed");
//        return;
//    }
//    ifc.ifc_len = BUFFERSIZE;
//    ifc.ifc_buf = buffer;
//    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
//    {
//        perror("ioctl error");
//        close(sockfd);
//        return;
//    }
//    //ifr = ifc.ifc_req;
//    cplim = buffer + ifc.ifc_len;
//    for (cp=buffer; cp < cplim; )
//    {
//        ifr = (struct ifreq *)cp;
//        if (ifr->ifr_addr.sa_family == AF_LINK)
//        {
//            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
//            int a,b,c,d,e,f;
//            int i;
//            strcpy(temp, (char *)ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
//
//            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
//            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
//            for (i=0; i<MAXADDRS; ++i)
//            {
//                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
//                {
//                    if (hw_addrs[i] == NULL)
//                    {
//                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);    
//                        strcpy(hw_addrs[i], temp);
//                        break;
//                    }
//                }
//            }
//        }
//        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
//    }
//    close(sockfd);
//}









