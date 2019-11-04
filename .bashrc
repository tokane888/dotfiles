# personal setting
cat /etc/os-release | grep -Po 'PRETTY_NAME="\K.*(?=")'
cd

# ctrl+s, ctrl+q無効化
if [[ -t 0 ]]; then
  stty stop undef
  stty start undef
fi
