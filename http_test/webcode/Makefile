.SUFFIXES:.c .o
CC = gcc
SRCS = webserver.c\
    xmlparser.c\
    http_parser.c
OBJS = $(SRCS:.c=.o)
EXEC = webserver
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread
.c.o:
	$(CC) -o $@ -c $<
clean:
	rm -f $(OBJS) $(EXEC)

