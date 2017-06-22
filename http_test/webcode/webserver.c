#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include "xmlparser.h"
#include "http_parser.h"


//#include <dxdriver.h>
//#include <dxhostIF.h>

#define     BACKLOG     10
#define     MAXLINE     8192  /* Max text line length */
#define     MAXBUF      8192  /* Max I/O buffer size */

void process_http_get(int fd, char *uri, char *filename);
void process_http_post(int fd, char *uri, char *buff, char *filename);
void *get_in_addr(struct sockaddr *sa);
int parse_uri(char *uri,char *filename);
void get_filetype(char *filename,char *filetype);
void serve_static(int fd,char *filename,int filesize);
void client_error(int fd,char *cause,char *errnum,char *shortmsg,char *longmsg);
void update_config(char *filename, char *buff);

extern int r12c_main(int instance,char * name);

int main( int argc, char *argv[] )
{
    int sockfd, connfd;
    char *port, buf[MAXBUF], method[MAXLINE], uri[MAXLINE], version[MAXLINE];
    char filename[MAXLINE];
    struct addrinfo hints, *servinfo, *p;
    struct sockaddr_storage other_addr;
    socklen_t sin_size;
    int yes = 1;
    char s[INET6_ADDRSTRLEN];
    int rv;

     if(argc != 2){
        fprintf(stderr,"usage:%s <port>\n",argv[0]);
        exit(1);
    }
     
    port = argv[1];
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE;

    if((rv = getaddrinfo(NULL, port, &hints, &servinfo)) != 0){
        fprintf(stderr, "getaddrinfo:%s\n", gai_strerror(rv));
        return 1;
    }

    for(p = servinfo;p != NULL;p = p->ai_next){

        if((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1){
            perror("server: socket");
            continue;
        }
        if(setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)) == -1){
            perror("setsockopt");
            exit(1);
        }
        if(bind(sockfd, p->ai_addr, p->ai_addrlen) == -1){
            close(sockfd);
            perror("server:bind");
            continue;
        }

        break;
    }

    freeaddrinfo(servinfo);

    if(p == NULL){
        fprintf(stderr, "server : failed to bind\n");
        exit(1);
    }

    if(listen(sockfd, BACKLOG) == -1){
        perror("listen");
        exit(1);
    }

    printf("DBG:server:waiting for connections...\n");

    while(1){
        sin_size = sizeof(other_addr);
        connfd = accept(sockfd, (struct sockaddr *)&other_addr, &sin_size);
        if(connfd == -1)
        {
            perror("accept");
            continue;
        }

        inet_ntop(other_addr.ss_family, get_in_addr((struct sockaddr*)&other_addr), s, sizeof(s));
        printf("DBG:server:got connection from %s\n",s);

        if(!fork())
        {
            close(sockfd);                       //fork以后子进程中也会有一个sockfd
            if(recv(connfd, buf, MAXBUF, 0) == -1) 
            {
                perror("receive");
                close(connfd);
                exit(1);
            }
            sscanf(buf,"%s %s %s",method,uri,version);
            printf("DBG:buf: \n%s\n", buf);            
            printf("DBG:method: %s, uri: %s, version: %s\n", method, uri, version);
            if(!strcasecmp(method, "GET"))     //如果是GET请求
                process_http_get(connfd,uri,filename);
            else if(!strcasecmp(method, "POST"))
                process_http_post(connfd,uri, buf,filename);
            else
                client_error(connfd,method,"501","Not Implemented","Webserver does not implement this method");

            close(connfd);
            exit(0);
        }
        close(connfd);
    }

    return 0;
}

void process_http_get(int fd, char *uri, char *filename)
{
    printf("DBG:%s start!\n", __FUNCTION__);
    struct stat buf;
    parse_uri(uri, filename);
    if(stat(filename,&buf)<0)
    {
        client_error(fd,filename,"404","Not found","Webserver couldn't find this file");
    }
    else
    {
        if(!(S_ISREG(buf.st_mode))||!(S_IRUSR & buf.st_mode)){         //判断是否有权限读取
            client_error(fd,filename,"403","forbidden","Webserver couldn't read the file");
        }
        serve_static(fd,filename,buf.st_size);
    }
    
    printf("DBG:%s end!\n", __FUNCTION__);
}

int r12c_run = 0;
#if 0
void process_http_post(int fd, char *uri, char *filename)
{
    printf("DBG:%s start!\n", __FUNCTION__);
    //return;
    filename = "home3.html";
    struct stat buf;
    //parse_uri(uri, filename);
    if(stat(filename,&buf)<0)
        client_error(fd,filename,"404","Not found","Webserver couldn't find this file");
    else
    {
        if(!(S_ISREG(buf.st_mode))||!(S_IRUSR & buf.st_mode))
        {
            //判断是否有权限读取
            client_error(fd,filename,"403","forbidden","Webserver couldn't read the file");
        }
        serve_static(fd,filename,buf.st_size);
    }

#endif
void process_http_post(int fd, char *uri, char *buff, char *filename)
{
    printf("DBG:%s start!\n", __FUNCTION__);
    //return;
    parse_uri(uri, filename);

    update_config("config2.xml", buff);

    filename = "home3.html";
    struct stat buf;
    //parse_uri(uri, filename);
    if(stat(filename,&buf)<0)
        client_error(fd,filename,"404","Not found","Webserver couldn't find this file");
    else
    {
        if(!(S_ISREG(buf.st_mode))||!(S_IRUSR & buf.st_mode))
        {
            //判断是否有权限读取
            client_error(fd,filename,"403","forbidden","Webserver couldn't read the file");
        }
        serve_static(fd,filename,buf.st_size);
    }  

    
#if 0

printf("r12c_run = %d\n", r12c_run);    
if(r12c_run == 0)
{
    r12c_run = 1;
    if(fork() == 0){
        r12c_main(0, "");
    }
}

sleep(3);
//try proAPI
dxErrCode err = DX_SUCCESS;
DX_HANDLE dx; 
DX_HOSTIF_HANDLE hostif;


printf("%s: try to open VD7[0]...\n",__FUNCTION__);
err = DxOpen(0, &dx);
if (DX_SUCCESS != err)
{
    printf("%s:Unable to open VD7[0], err[%d]\n", __FUNCTION__, err);
}
else
{
    printf("%s:opened VD7[0]\n", __FUNCTION__);
    
    err = DxHostIFHostIFOpen(dx, 0, &hostif);
    if (err != DX_SUCCESS)
    {
        printf("%s:Err[%d] occured while opening hostIF on VD7[0]\n",
            __FUNCTION__, err);

        err = DxClose(&dx);
        

    }
    else
    {
        printf("Hostif opened successfully!!!\n");

        //test system struct
        cw_system_st system;
        err = DxHostIFSystemGet(hostif,0, &system);
        if (err != DX_SUCCESS)
            printf("DxHostIFSystemGet failed!!!\n");
        system.config.u32SystemConfigA = 8;
        err = DxHostIFSystemSet(hostif,0,&system);
        if (err != DX_SUCCESS)
            printf("DxHostIFSystemSet failed!!!\n");

        err = DxHostIFWaitForComplete(hostif, 0, 5);
        if(err)
        {
            printf("%s: ERR[%d] system struct set TimeOut\n", __FUNCTION__, err);
        }
        else
            printf("test system struct ok!!!\n");


    }
    

}

//err = DxHostIFHostIFOpen(p->dx, 0, &p->host);
#endif

printf("DBG:%s end!\n", __FUNCTION__);
}

void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET){
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int parse_uri(char *uri,char *filename)
{
    strcpy(filename,".");
    strcat(filename,uri);
    printf("DBG:%s \n",filename);
    if(uri[strlen(uri)-1] == '/')
        strcat(filename,"home.html");
    printf("DBG:%s \n",filename);
    return 1;
}

void get_filetype(char *filename,char *filetype)
{
    if(strstr(filename,".html"))
        strcpy(filetype,"text/html");
    else if (strstr(filename,".gif"))
        strcpy(filetype,"image/gif");
    else if (strstr(filename,".jpg"))
        strcpy(filetype,"image/jpeg");
    else
        strcpy(filetype,"text/plain");
}

void serve_static(int fd,char *filename,int filesize)
{
    int srcfd;
    char *srcp,filetype[MAXLINE],buf[MAXBUF];
    get_filetype(filename,filetype);
    sprintf(buf,"HTTP/1.1 200 OK\r\n");
    sprintf(buf,"%sServer:Web Server\r\n",buf);
    sprintf(buf,"%sContent-length:%d\r\n",buf,filesize);
    sprintf(buf,"%sContent-type:%s\r\n\r\n",buf,filetype);
    send(fd,buf,strlen(buf),0);

    srcfd = open(filename,O_RDONLY,0);
    srcp = mmap(0,filesize,PROT_READ,MAP_PRIVATE,srcfd,0);
    send(fd,srcp,filesize,0);
    //printf("DBG:%s: \n%s\n",__FUNCTION__,srcp);
    close(srcfd);

    munmap(srcp,filesize);
}

void client_error(int fd,char *cause,char *errnum,char *shortmsg,char *longmsg)
{
    printf("DBG:%s start!\n", __FUNCTION__);
    char buf[MAXLINE],body[MAXBUF];

    sprintf(body,"<html><title>Tiny Error</title>");
    sprintf(body,"%s<body bgcolor=""ffffff"">\r\n",body);
    sprintf(body,"%s%s:%s\r\n",body,errnum,shortmsg);
    sprintf(body,"%s<p>%s:%s\r\n",body,longmsg,cause);
    sprintf(body,"%s<hr><em>The Web server</em>\r\n",body);

    sprintf(buf,"HTTP/1.1 %s %s\r\n",errnum,shortmsg);
    send(fd,buf,strlen(buf),0);
    sprintf(buf,"Content-type: text/html\r\n");
    send(fd,buf,strlen(buf),0);
    sprintf(buf,"Content-length: %d\r\n\r\n",(int)strlen(body));
    send(fd,buf,strlen(buf),0);
    send(fd,body,strlen(body),0);
    printf("DBG:%s end!\n", __FUNCTION__);
}

void update_config(char *filename, char *buff)
{
    int cfgfd;

    printf("DBG:%s start!\n", __FUNCTION__);
    struct http_message message;
    int result = http_parser(buff, &message, HTTP_REQUEST);
    if (0 != result) {
      printf("DBG:%s:Error result %d message:\n%s\n",__FUNCTION__,result, buff);
    }
    else
    {
      printf("DBG:message: 0x%x\n%s\n",message.body,message.body);
      parseBuffer(message.body);
    }
    printf("DBG:%s end!\n", __FUNCTION__);
}



#if 0
void WebTask(void)
{
    web_main("1234");
}

int WebTaskInit(void)
{
    char taskname[]="Websvr";
    printf("Web server task: %s\n",taskname);
    
    return taskSpawn(taskname, 10, 0, 16*1024 * 1024, (FUNCPTR)WebTask, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}
#endif



