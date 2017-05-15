.SUFFIXES:.c .o
CC = gcc
SRCS = main.c\
    xmlparser.c
OBJS = $(SRCS:.c=.o)
EXEC = test
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread
.c.o:
	$(CC) -o $@ -c $<
clean:
	rm -f $(OBJS)

