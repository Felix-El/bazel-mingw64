#include "util.h"

#include <greet/greet.h>

#include <iostream>

using namespace std;
using namespace libgreet;

namespace greeter
{

    void print_greeting(string_view whom) noexcept
    {
        cout << greet::do_greet(whom);
    }

}

