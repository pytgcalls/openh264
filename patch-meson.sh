function patch_meson() {
    awk '
      BEGIN { in_windows=0; in_block=0; block_type="" }
      /elif system\s*==\s*'\''windows'\''/ { in_windows=1; print; next }
      /^ *else/ { in_windows=0; print; next }

      in_windows && /if cpu_family\s*==\s*'\''x86'\''/ { in_block=1; block_type="x86"; print; next }
      in_windows && /elif cpu_family\s*==\s*'\''x86_64'\''/ { in_block=1; block_type="x86_64"; print; next }
      # esce dal blocco CPU
      in_block && /^ *elif|^ *else|^ *endif/ { in_block=0; block_type=""; print; next }

      {
        if(in_block && $0 ~ /asm_args\s*\+=/) {
          line=$0
          if(line !~ /-DHAVE_AVX2/) {
            sub(/\] */,", '\''-DHAVE_AVX2'\'']", line)
          }
          print line
          print "    add_project_arguments('\''-DHAVE_AVX2'\'', language: '\''cpp'\'')"
          print "    add_project_arguments('\''-DHAVE_AVX2'\'', '\''-DX86_ASM'\'', language: '\''c'\'')"
        } else {
          print
        }
      }
    ' "meson.build" > "meson.build.tmp" && mv "meson.build.tmp" "meson.build"
}