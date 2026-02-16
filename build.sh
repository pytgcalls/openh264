source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)"

require msvc
require xcode
require venv

import patch-meson.sh
import libraries.properties
import meson from python3
if ! is_windows; then
  import ninja from python3
fi

windows_args="/O2 /Ob1 /Oy- /Zi /FS /GF /GS /Gy /DNDEBUG /fp:precise /Zc:wchar_t /Zc:forScope /D_VARIADIC_MAX=10"
build_and_install "openh264" meson-static \
  -Dtests=disabled \
  --windows="-Db_vscrt=mt -Dc_args='$windows_args' -Dcpp_args='$windows_args'" \
  --setup-commands="patch_meson"
copy_libs "openh264" "artifacts"