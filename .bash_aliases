# External IP
alias ipe='curl ipinfo.io/ip'

# Internal IP
alias ipi="ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d'/' -f1"

# Grep the command history
alias gh='history|grep '

# Send file to trash can
alias tcn='gio trash '

# Git Status
alias gst='git status'

# Untar a tar
alias untar='tar -zxvf '

# batcat to bat
alias bat='batcat'

# Autojump
alias j='autojump'
