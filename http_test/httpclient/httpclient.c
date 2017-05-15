#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <netdb.h>
#include <unistd.h>
#define BUFFSIZE 4096
#define TEXT_BUFFSIZE 1024
#define PORT 1234

void geturl(char *url) {
	char myurl[BUFFSIZE], host[BUFFSIZE], 
		GET[BUFFSIZE], request[BUFFSIZE],
		text[BUFFSIZE], *phost = 0;
	int socketid, connectid, res, recvid, flag = 1;
	struct hostent *purl = NULL;
	struct sockaddr_in sockinfo;

	memset(myurl, 0, BUFFSIZE);
	memset(host, 0, BUFFSIZE);
	memset(GET, 0, BUFFSIZE);
	strcpy(myurl, url);
    printf("%d myurl: %s\n",__LINE__,myurl);

	// Get path
	for (phost = myurl; *phost != '/' && *phost != '\0'; ++phost);
    printf("%d myurl: %s\n",__LINE__,myurl);

	if ((int) (phost - myurl) == strlen(myurl)) {
		//path is root
		strcpy(GET, "/");
	} else {
		// save path to GET
		strcpy(GET, phost);
	}

    printf("%d myurl: %s\n",__LINE__,myurl);

	*phost = '\0';
    printf("%d myurl: %s\n",__LINE__,myurl);
	strcpy(host, myurl);

	socketid = socket(AF_INET, SOCK_STREAM, 0);
	if (socketid == -1) {
		printf("Error:Fail to create socket!\n");
		exit(1);
	}
	printf("-> Create socket successfully\n");

	// Function: gethostbyname()  will return a hostent struct as following 
	// {
	//     char *h_name;           /* Host name*/
	//     char **h_aliases;       
	//     int h_addrtype;          
	//     int h_length;             
	//     char **h_addr_list;   
	// };
	// return: Success: pointer to struct hostent; Fail: NULL
	purl = gethostbyname(host);
    if(purl == NULL)
    {
        printf("Error:Fail to get host: %s, error: %d!\n",host, purl);
		exit(1);
    }

	//Set connection info
	memset(&sockinfo, 0, sizeof(struct sockaddr_in));
	sockinfo.sin_family = AF_INET;
	sockinfo.sin_addr.s_addr = *((unsigned long *)purl->h_addr_list[0]);
	sockinfo.sin_port = htons(PORT);

	// Make a request
	//request header
	memset(request, 0, BUFFSIZE);
	strcat(request, "GET ");
	strcat(request, GET);
	strcat(request, " HTTP/1.1\r\n");
	//
	strcat(request, "HOST: ");
	strcat(request, host);
	strcat(request, "\r\n");
	strcat(request, "User-Agent: ");
	strcat(request, "2333 Browser");
	strcat(request, "\r\n");
	strcat(request, "Author: ");
	strcat(request, "By Jiavan&Keeln&LZY");
	strcat(request, "\r\n");
	strcat(request,"Cache-Control: no-cache\r\n\r\n");

	// Connect to remote server
	connectid = connect(socketid, (struct sockaddr*)&sockinfo, sizeof(sockinfo));
	if (connectid == -1) {
		printf("Error:Fail to connect to server!\n");
		exit(1);
	}
	printf("-> Connecto to server success!\n");

	// Send Get request to server
	res = send(socketid, request, strlen(request), 0);
	if (res == -1) {
		printf("Error:Send request fail!\n");
		exit(1);
	}
	printf("-> Send GET success, total %d bytes\n", res);
	printf("-> HTTP Request--------\n%s\n", request);
	//printf("-> HTTP response is saved to file: index.html\n");

	// Receive the reponse
	//if (freopen("index.html", "w", stdout) == NULL) {
	//	printf("Error: Fail to redirect to file\n");
	//	exit(1);
	//} else 
	{
		while (flag) {
			memset(text, 0, TEXT_BUFFSIZE);
			int bufflen = recv(socketid, text, TEXT_BUFFSIZE, 0);
			
			if (bufflen < 0) {
				printf("Error in receive data!\n");
				fclose(stdout);
				close(socketid);
				exit(1);
			}
			if (bufflen > 0) {
				printf("%s\n", text);
			} else {
				flag = 0;
			}
		}
	}
	fclose(stdout);
	close(socketid);
}

int main(int argc, char *argv[])
{
	if (argc < 2) {
		printf("Pleae input proper URL paramter\n");
		exit(1);
	}
    printf("url: %s\n",argv[1]);
	geturl(argv[1]);
	return 0;
}
