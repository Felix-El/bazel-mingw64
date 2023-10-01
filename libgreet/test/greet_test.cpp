#include <gtest/gtest.h>
#include <greet/greet.h>

TEST(GreetTest, DoGreet) {
  const std::string result = libgreet::greet::do_greet("Felix");
  EXPECT_EQ(result, "Hello Felix\n");
}

