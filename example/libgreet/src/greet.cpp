#include "greet_private.h"

string greet::do_greet(string_view name) noexcept
{
    ostringstream oss;
    oss << "Hello " << name << endl;
    return oss.str();
}

