#!/bin/bash

get_size_gb() {
  echo "scale=1; $1 / 1024" | bc
}

architecture=$(uname -a)
physical_cpu=$(grep -c ^processor /proc/cpuinfo)
virtual_cpu=$(nproc)
total_memory=$(free -m | awk '/Mem:/ {print $2}')
used_memory=$(free -m | awk '/Mem:/ {print $3}')
memory_usage=$(free | awk '/Mem:/ {printf "%.2f", $3/$2*100}')
total_disk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{sum += $2} END {print sum}')
used_disk=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{sum += $3} END {print sum}')
disk_usage=$(df -BG | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3; ft += $2} END {printf "%d", ut/ft*100}')
cpu_load=$(top -bn1 | grep '^%Cpu' | awk '{printf "%.1f%%", $2 + $4}')
last_boot=$(who -b | awk '{print $3 " " $4}')
lvm_use=$(lsblk | grep -q "lvm" && echo "yes" || echo "no")
tcp_connections=$(ss -t | grep ESTAB | wc -l)
logged_users=$(who | wc -l)
ip_address=$(hostname -I | awk '{print $1}')
mac_address=$(ip link show | awk '/ether/ {print $2; exit}')
sudo_commands=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

total_memory_gb=$(get_size_gb $total_memory)
used_memory_gb=$(get_size_gb $used_memory)

echo "
#Architecture: $architecture
#CPU physical: $physical_cpu
#vCPU: $virtual_cpu
#Memory Usage: ${used_memory_gb}/${total_memory_gb}GB ($memory_usage%)
#Disk Usage: ${used_disk}/${total_disk}GB ($disk_usage%)
#CPU load: $cpu_load
#Last boot: $last_boot
#LVM use: $lvm_use
#TCP Connections: $tcp_connections ESTABLISHED
#Users logged: $logged_users
#Network: IP $ip_address ($mac_address)
#Sudo commands: $sudo_commands
"