# hosts
Update windows hosts by command

![hostsClipchamp-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/ea4b116e-4d76-497c-9ff1-349de9f58afc)

### Добавление связного shell скрипта в удобном месте (в примере имя файла будет hosts.sh)

```bash
#!/bin/bash

conf_ip="127.0.0.1" # default IP address
conf_path="C:\\path_to_hosts.ps1"

function call_powershell {
    local action=$1
    local hostname=$2
    local ip_address=$3
    local other=$2

    # default IP
    if [ -z "$ip_address" ]; then
        ip_address=$conf_ip
    fi

    if [ "$action" == "add" ] && [ -n "$hostname" ]; then
        powershell -File $conf_path"hosts.ps1" -Action "$action" -Hostname "$hostname" -IPAddress "$ip_address"
    elif [ "$action" == "remove" ] && [ -n "$hostname" ]; then
        powershell -File $conf_path"hosts.ps1" -Action "$action" -Hostname "$hostname"
    elif [ "$action" == "show" ]; then
        powershell -File $conf_path"hosts.ps1" -Action "$action" -Other "$other"
    else
        echo "Unsupported action. Available actions: add, remove, show."
    fi
}

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 {add|remove|show} hostname [ip_address] [other]"
    exit 1
fi

call_powershell $1 $2 $3
```

### Добавление новой записи
./hosts.sh add hostname[.local/.docker.local] [ip optional, default 127.0.0.1]

### Удаление записи
./hosts.sh remove hostname

### Просмотр списка локальных
./hosts.sh show

Просмотра списка всех
./hosts.sh show 1
