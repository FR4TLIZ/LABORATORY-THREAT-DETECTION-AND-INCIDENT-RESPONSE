# Lab 1: Information Gathering

This repository contains the bash script and report for Laboratory 1 of the "Threat Detection and Incident Response" course at Wroclaw University of Science and Technology.

The provided script (`Raport_Maxer.sh`) automates the collection of system configuration, network settings, running processes, and security policies on a Kali Linux machine.

## Features

* Automatically gathers extensive system information.
* Interactive Prompt: During execution, the script will ask if you want to list all installed packages or just the first 50. This prevents the final report from becoming unnecessarily long.
* Report Generation: All collected data is saved into a clearly named text file (e.g., system_report_Date_2026-03-14_Time_15-06-05.txt) in the same directory.

## How to run

1. Make the script executable:
   ```bash
   chmod +x Raport_Maxer.sh.sh
2. Execute the script with root privileges:
   ```bash
   sudo ./Raport_Maxer.sh.sh

Security Note: We run the script using "sudo" directly from the terminal rather than hardcoding "sudo" commands inside the script itself. Hardcoding privileges inside scripts is considered a bad security practice.
