#define PW_LOG_MODULE_NAME "main"

#include "pw_log/log.h"
#include "pw_system/init.h"

namespace pw::system {
void UserAppInit() {}
}  // namespace pw::system

int main() {
  pw::system::Init();
  PW_LOG_INFO("Hello ZiG-2025!");
  return 0;
}
