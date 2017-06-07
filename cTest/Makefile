.SUFFIXES:.c .o
INCLUDE=-I./ -I$HOME/include `xml2config --cflags`
LIBRARY=-L./ -L$HOME/lib `xml2config --libs`

CC = gcc
SRCS = main.c\
    test.c
OBJS = $(SRCS:.c=.o)
EXEC = test
start:$(OBJS)
	$(CC) -o $(EXEC) $(OBJS) -lpthread -lxml2 -g
.c.o:
	$(CC) -o $@ -c $< -I/usr/include/libxml2/ -g
clean:
	rm -f $(OBJS) $(EXEC)

