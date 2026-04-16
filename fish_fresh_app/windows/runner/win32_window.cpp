#include "win32_window.h"

#include <dwmapi.h>
#include <flutter/flutter_view_controller.h>
#include <wrl/client.h>

#include "resource.h"

namespace {
constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
constexpr const wchar_t kGetMessageNameW[] =
    L"WM_APP_CLOSE_ALL_WINDOWS_REQUESTED";

UINT WM_APP_CLOSE_ALL_WINDOWS_REQUESTED = 0;
}  // namespace

Win32Window::Win32Window() {
  WM_APP_CLOSE_ALL_WINDOWS_REQUESTED =
      RegisterWindowMessage(kGetMessageNameW);
}

Win32Window::~Win32Window() {
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                          const Point& origin,
                          const Size& size) {
  WNDCLASS window_class = RegisterWindowClass();
  if (window_handle_ != nullptr || window_class.lpszClassName == nullptr) {
    return false;
  }
  RECT rect{origin.x, origin.y,
            static_cast<LONG>(origin.x + size.width),
            static_cast<LONG>(origin.y + size.height)};
  AdjustWindowRect(&rect, WS_OVERLAPPEDWINDOW, FALSE);

  window_handle_ = CreateWindow(
      window_class.lpszClassName, title.c_str(),
      WS_OVERLAPPEDWINDOW | WS_VISIBLE,
      rect.left, rect.top,
      rect.right - rect.left, rect.bottom - rect.top,
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window_handle_) {
    return false;
  }

  UpdateTheme(window_handle_);
  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

bool Win32Window::OnCreate() {
  return true;
}

void Win32Window::OnDestroy() {}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();
  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);
  SetFocus(child_content_);
}

LRESULT Win32Window::MessageHandler(HWND hwnd,
                                     UINT const message,
                                     WPARAM const wparam,
                                     LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;
      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                   newHeight, SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }
    case WM_SIZE: {
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      return 0;
    }
    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;
    case WM_DWMCOLORIZATIONCOLORCHANGED:
      UpdateTheme(hwnd);
      return 0;
  }
  if (message == WM_APP_CLOSE_ALL_WINDOWS_REQUESTED) {
    Destroy();
    return 0;
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

WNDCLASS Win32Window::RegisterWindowClass() {
  WNDCLASS window_class{};
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = kWindowClassName;
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon = LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
  window_class.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
  window_class.lpszMenuName = nullptr;
  window_class.lpfnWndProc = WndProc;
  RegisterClass(&window_class);
  return window_class;
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                       UINT const message,
                                       WPARAM const wparam,
                                       LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    return OnNCCreate(window, wparam, lparam);
  } else if (auto* that = reinterpret_cast<Win32Window*>(
                 GetWindowLongPtr(window, GWLP_USERDATA))) {
    return that->MessageHandler(window, message, wparam, lparam);
  }
  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT Win32Window::OnNCCreate(HWND const window,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept {
  auto* const create_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
  SetWindowLongPtr(window, GWLP_USERDATA,
                   reinterpret_cast<LONG_PTR>(create_struct->lpCreateParams));
  return DefWindowProc(window, WM_NCCREATE, wparam, lparam);
}

void Win32Window::UpdateTheme(HWND const window) {
  BOOL is_dark_mode = FALSE;
  auto* dwm = L"DwmSetWindowAttribute";
  auto dwm_lib = LoadLibraryEx(L"dwmapi.dll", nullptr, LOAD_LIBRARY_AS_DATAFILE);
  if (dwm_lib) {
    FreeLibrary(dwm_lib);
    BOOL dark = TRUE;
    DwmSetWindowAttribute(window, 20, &dark, sizeof(dark));
  }
}
