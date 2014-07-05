#include <ctime>
#include <cstdlib>
#include <cstdio>

int main(int argc, char* argv[]) {
	unsigned short int length = argc > 1 ? atoi(argv[1]) : 16 ;
	if ( length <= 0 || length >= 33 )
		length = 16;
	srand((unsigned int) time(NULL));
	while(length--)
		putchar(rand() % 93 +33);
	printf("\n");

	return 0;
}
