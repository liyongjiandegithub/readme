.SUFFIXES:.c .o
CC = gcc
SRCS = server.c\
    functions.c\
    headers.c
OBJS = $(SRCS:.c=.o)
EXEC = server
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread
.c.o:
	$(CC) -o $@ -c $<
clean:
	rm -f $(OBJS)

