.SUFFIXES:.c .o
CC = gcc
SRCS = webserver.c\
    pub.c\
    xmlparser.c\
    http_parser.c\
    thread_work.c
OBJS = $(SRCS:.c=.o)
EXEC = webserver
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread
.c.o:
	$(CC) -o $@ -c $<
clean:
	rm -f $(OBJS) $(EXEC)

