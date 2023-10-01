#include "util.h"

using namespace greeter;

int main(int argc, char* argv[])
{
    print_greeting((argc > 1) ? argv[1] : "Anonymous");
    return 0;
}

