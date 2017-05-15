#include "http_parser.h"

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void try_parse(int type, int expect, char *data) {
  int len = strlen(data);
  char buffer[len + 1];
  memset(buffer, 0, len + 1);
  memcpy(buffer, data, len);
  struct http_message message;
  int result = http_parser(buffer, &message, type);
  if (expect != result) {
    fprintf(stderr, "Expected %d, got %d for message:\n%s\n", expect, result, data);
  }
  else
  {
    printf("result %d buffer 0x%x\n",result,buffer);
    printf("message: 0x%x\n%s\n",message.body,message.body);
  }
}

int main(void) {
#if 0
  try_parse(HTTP_REQUEST, 400, "test");
  try_parse(HTTP_REQUEST, 400, "GE");
  try_parse(HTTP_REQUEST, 400, "GET");
  try_parse(HTTP_REQUEST, 414, "GET ");
  try_parse(HTTP_REQUEST, 414, "GET /");
  try_parse(HTTP_REQUEST, 400, "GET / ");
  try_parse(HTTP_REQUEST, 413, "GET / \r\n");
  try_parse(HTTP_REQUEST, 413, "GET / \n");
  try_parse(HTTP_REQUEST, 400, "GET / HTTP/");
  try_parse(HTTP_REQUEST, 400, "GET / HTTP/1.1");
  try_parse(HTTP_REQUEST, 413, "GET / HTTP/1.1\r\n");
  try_parse(HTTP_REQUEST, 413, "GET / HTTP/1.1\r\nHost: test.com");
  try_parse(HTTP_REQUEST, 413, "GET / HTTP/1.1\r\nHost: test.com\r\n");
  try_parse(HTTP_REQUEST, 0, "GET / HTTP/1.1\r\nHost: test.com\r\n\r\n");
  try_parse(HTTP_REQUEST, 0, "GET / HTTP/1.1\r\nHost: test.com\r\nHeader:\t \r    \n     \t    Value\r\n\r\n");

  try_parse(HTTP_RESPONSE, 400, "test");
  try_parse(HTTP_RESPONSE, 400, "HT");
  try_parse(HTTP_RESPONSE, 400, "HTTP/1.1");
  try_parse(HTTP_RESPONSE, 414, "HTTP/1.1 ");
  try_parse(HTTP_RESPONSE, 414, "HTTP/1.1 \n");
  try_parse(HTTP_RESPONSE, 414, "HTTP/1.1 \r\n");
  try_parse(HTTP_RESPONSE, 414, "HTTP/1.1 200");
  try_parse(HTTP_RESPONSE, 0, "HTTP/1.1 200 OK\r\n\r\n");
  #endif

  char testReq[]= "POST / HTTP/1.1\n\
Host: 172.18.16.9:1234\n\
Connection: keep-alive\n\
Content-Length: 14\n\
Cache-Control: max-age=0\
Origin: http://172.18.16.9:1234\n\
Upgrade-Insecure-Requests: 1\n\
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36\n\
Content-Type: application/x-www-form-urlencoded\n\
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\n\
DNT: 1\n\
Referer: http://172.18.16.9:1234/\n\
Accept-Encoding: gzip, deflate\n\
Accept-Language: zh-CN,zh;q=0.8,en-US;q=0.6,en;q=0.4\n\
\n\
xcodeopt=Start";

  try_parse(HTTP_REQUEST, 0, testReq);

  return 0;
}
