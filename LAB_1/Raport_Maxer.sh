#!/bin/bash

REPORT="system_report_Date_$(date +%Y-%m-%d)_Time_$(date +%H-%M-%S).txt"

echo "===================================================" > $REPORT
echo " INFORMATION GATHERING REPORT" >> $REPORT
echo "===================================================" >> $REPORT
echo "Generation date: $(date)" >> $REPORT
echo "Hostname: $(hostname)" >> $REPORT
echo "===================================================" >> $REPORT

echo -e "\n[+] 1. PROCESSES" >> $REPORT
echo "--- 'kali' user processes ---" >> $REPORT
ps -u kali >> $REPORT 2>&1
echo -e "--- Processes consuming the most RAM ---" >> $REPORT
ps aux --sort=-%mem | head -n 10 >> $REPORT 2>&1
echo -e "--- 'root' processes (top 10) ---" >> $REPORT
ps -u root >> $REPORT 2>&1
echo -e "--- Process tree (systemd children) ---" >> $REPORT
pstree -p 1 >> $REPORT 2>&1

echo -e "\n[+] 2. APPLICATIONS" >> $REPORT
read -p "Do you want to list ALL installed packages [y] or just 50 [N]? [y/N]: " LIST_ALL

if [[ "$LIST_ALL" =~ ^[Yy]$ ]]; then
    dpkg -l >> $REPORT 2>&1
else
    dpkg -l | head -n 55 >> $REPORT 2>&1
fi
echo "--- openssh-server version ---" >> $REPORT
dpkg -l | grep openssh-server >> $REPORT 2>&1
echo "--- vsftpd installation date ---" >> $REPORT
zgrep " install " /var/log/dpkg.log* | grep vsftpd >> $REPORT 2>&1
echo -e "--- Packages installed in the last 7 days (from dpkg logs) ---" >> $REPORT
grep " install " /var/log/dpkg.log* | grep "$(date -d '7 days ago' +'%Y-%m')" | head -n 10 >> $REPORT 2>&1

echo -e "\n[+] 3. OPEN PORTS" >> $REPORT
echo "\n--- Starting SSH & apache2 ---" >> $REPORT
systemctl start ssh apache2 >> $REPORT 2>&1
echo "--- All listening ports ---" >> $REPORT
netstat -tuln >> $REPORT 2>&1
echo -e "--- Services accessible externally (0.0.0.0) ---" >> $REPORT
ss -tulnp | grep 0.0.0.0 >> $REPORT 2>&1
echo -e "--- Defining what Process is listening on port 22 ---" >> $REPORT
nmap -sV -p 22 localhost >> $REPORT 2>&1
echo -e "--- Defining versions of running processes on remote host (localhost in laboratory) ---" >> $REPORT
nmap -sV localhost | grep :22 >> $REPORT 2>&1

echo -e "\n[+] 4. SERVICES" >> $REPORT
echo "--- ssh and apache2 status ---" >> $REPORT
systemctl status ssh apache2 | grep -E "Active:|Loaded:|apache2.service|ssh.service" >> $REPORT 2>&1
echo "--- All Services currenty runinng in system ---" >> $REPORT
systemctl list-units --type=service --state=running >> $REPORT 2>&1
echo -e "--- Services enabled at startup ---" >> $REPORT
systemctl list-unit-files --type=service --state=enabled >> $REPORT 2>&1

echo -e "\n[+] 5. USERS" >> $REPORT
echo "--- List of all users ---" >> $REPORT
cut -d: -f1 /etc/passwd >> $REPORT 2>&1
echo -e "--- Users with Bash/SH/ZSH access ---" >> $REPORT
grep -E '/bin/(bash|sh|zsh)' /etc/passwd | cut -d: -f1 >> $REPORT 2>&1
echo -e "--- Sudo group ---" >> $REPORT
getent group sudo >> $REPORT 2>&1

echo -e "\n[+] 6. FILES" >> $REPORT
echo "--- Files modified in /etc (last 7 days) ---" >> $REPORT
find /etc -type f -mtime -7 | head -n 10 >> $REPORT 2>&1
echo -e "--- Files > 1GB in root directory ---" >> $REPORT
find / -type f -size +1G 2>/dev/null >> $REPORT

echo -e "\n[+] 7. COMMANDS AND CRON" >> $REPORT
echo "--- root history (zsh) ---" >> $REPORT
cat /root/.zsh_history >> $REPORT 2>&1
echo -e "--- root crontab ---" >> $REPORT
crontab -lu root >> $REPORT 2>&1

echo -e "\n[+] 8. LOGS" >> $REPORT
echo "--- vsftpd logs ---" >> $REPORT
cat /var/log/vsftpd.log >> $REPORT 2>&1
echo "--- SSH logins (Accepted) ---" >> $REPORT
journalctl -u ssh | grep "Accepted" >> $REPORT 2>&1

echo -e "\n[+] 9. KERNEL AND PARAMETERS" >> $REPORT
echo "--- Kernel version ---" >> $REPORT
uname -r >> $REPORT 2>&1
echo "--- Uptime ---" >> $REPORT
uptime -p >> $REPORT 2>&1
echo "--- RAM Memory ---" >> $REPORT
free -h >> $REPORT 2>&1
echo "--- CPU parameters ---" >> $REPORT
lscpu | grep -E "Model name|CPU\(s\):|CPU MHz" >> $REPORT 2>&1
echo "--- Disk space ---" >> $REPORT
df -h | grep "^/dev" >> $REPORT 2>&1

echo -e "\n[+] 10. NETWORK SETTINGS" >> $REPORT
echo "--- IP Addressing ---" >> $REPORT
ip a >> $REPORT 2>&1
echo "--- DNS Servers ---" >> $REPORT
cat /etc/resolv.conf | grep nameserver >> $REPORT 2>&1
echo "--- Translation table ---" >> $REPORT
ip neigh >> $REPORT 2>&1
echo "--- Routing table ---" >> $REPORT
ip route >> $REPORT 2>&1
echo "--- Default gateway address ---" >> $REPORT
ip route | grep default >> $REPORT 2>&1
echo "--- Network Interfaces ---" >> $REPORT
ip link show >> $REPORT 2>&1

echo -e "\n[+] 11. SECURITY" >> $REPORT
echo "--- iptables rules ---" >> $REPORT
iptables -L >> $REPORT 2>&1
echo "--- SELinux status ---" >> $REPORT
sestatus >> $REPORT 2>&1
echo "--- AppArmor status ---" >> $REPORT
aa-status >> $REPORT 2>&1

echo -e "\n===================================================" >> $REPORT
echo " REPORT COMPLETED" >> $REPORT
echo "===================================================" >> $REPORT
