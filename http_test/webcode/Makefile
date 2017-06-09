.SUFFIXES:.c .o
CC = gcc
SRCS = webserver.c\
    xmlparser.c\
    http_parser.c
OBJS = $(SRCS:.c=.o)
EXEC = webserver
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread -lxml2
.c.o:
	$(CC) -o $@ -c $< -I/usr/include/libxml2/
clean:
	rm -f $(OBJS) $(EXEC)

