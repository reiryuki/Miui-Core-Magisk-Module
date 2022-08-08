# debug
magiskpolicy --live "dontaudit system_server system_file file write"
magiskpolicy --live "allow     system_server system_file file write"

# context
magiskpolicy --live "type system_lib_file"
magiskpolicy --live "type vendor_file"
magiskpolicy --live "type vendor_configs_file"
magiskpolicy --live "dontaudit { system_lib_file vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "allow     { system_lib_file vendor_file vendor_configs_file } labeledfs filesystem associate"
magiskpolicy --live "dontaudit init { system_lib_file vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "allow     init { system_lib_file vendor_file vendor_configs_file } dir relabelfrom"
magiskpolicy --live "dontaudit init { system_lib_file vendor_file vendor_configs_file } file relabelfrom"
magiskpolicy --live "allow     init { system_lib_file vendor_file vendor_configs_file } file relabelfrom"

# file
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { vendor_audio_prop vendor_display_prop } file { read open getattr map }"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } { vendor_audio_prop vendor_display_prop } file { read open getattr map }"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_displayfeature_prop file read"
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } vendor_displayfeature_prop file read"
magiskpolicy --live "dontaudit { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } cgroup file write
magiskpolicy --live "allow     { system_app priv_app platform_app untrusted_app_29 untrusted_app_27 untrusted_app } cgroup file write


