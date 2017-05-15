.SUFFIXES:.c .o
CC = gcc
SRCS = httpclient.c
OBJS = $(SRCS:.c=.o)
EXEC = httpclient
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread
.c.o:
	$(CC) -o $@ -c $<
clean:
	rm -f $(OBJS)

