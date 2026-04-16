#include "utils.h"

#include <flutter/encodable_value.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <iostream>
#include <string>
#include <vector>

std::vector<std::string> GetCommandLineArguments() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return {};
  }

  std::vector<std::string> command_line_arguments;

  // Skip the first argument (executable path)
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(flutter::WideStringToUtf8(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}
