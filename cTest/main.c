#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int
main(int argc, char **argv)
{
  int n, i;
  int minload = 10;
  int maxload = 20;
  int range = maxload - minload;

  (void)sleep(1);
  printf("\n");
  /* Seed random number generator. */
  unsigned seed = (unsigned)time(NULL);
  seed = 100;
  srandom(seed);
  printf("%d\n",seed);
  /* Generate string. */
  for (i = 0; i < 20; i++) {
    n = random();
    printf("%d,", n%range + minload);
  }
  printf("\n");
  return 0;
}
