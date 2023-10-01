#include <string>
#include <string_view>

#ifdef _WIN32
#  if defined(GREET_EXPORT)
#    define GREET_DECLSPEC __declspec(dllexport)
#  elif defined(GREET_IMPORT)
#    define GREET_DECLSPEC __declspec(dllimport)
#  else
#    define GREET_DECLSPEC
#  endif
#else
#  define GREET_DECLSPEC
#endif

namespace libgreet
{
    class GREET_DECLSPEC greet {
        public:
            static std::string do_greet(std::string_view name) noexcept;
    };
}

