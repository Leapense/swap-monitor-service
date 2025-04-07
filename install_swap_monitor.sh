#!/bin/bash

# Zenity 설치 여부 확인
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Please install Zenity first."
    exit 1
fi

# 설치 모드 선택 (사용자 설치 또는 시스템 전체 설치)
install_mode=$(zenity --list \
    --title="Swap Monitor Installer" \
    --text="Select Install option:" \
    --column="Mode" --column="Install Type" \
    "1" "User Install (Home Directory)" \
    "2" "System Install (System Directory)")
if [ -z "$install_mode" ]; then
    zenity --error --text="Installer got canceled"
    exit 1
fi

SOURCE_SCRIPT="swapMemMonitoring.sh"
if [ ! -f "$SOURCE_SCRIPT" ]; then
    zenity --error --text="Source script cannot be found."
    exit 1
fi

if [ "$install_mode" = "1" ]; then
    # 사용자 설치: 파일은 ~/.local/bin 에 복사
    install_dir="$HOME/.local/bin"
    mkdir -p "$install_dir"
    if cp "$SOURCE_SCRIPT" "$install_dir/swapMemMonitoring.sh"; then
        chmod +x "$install_dir/swapMemMonitoring.sh"
        
        # 사용자 단위 systemd 서비스 파일 생성 (~/.config/systemd/user)
        service_dir="$HOME/.config/systemd/user"
        mkdir -p "$service_dir"
        service_file="$service_dir/swap_monitor.service"
        cat <<EOF > "$service_file"
[Unit]
Description=Swap Monitor Service
After=graphical.target

[Service]
ExecStart=$install_dir/swapMemMonitoring.sh
Restart=always

[Install]
WantedBy=default.target
EOF
        # systemd 사용자 서비스 데몬 리로드 및 서비스 활성화/시작
        systemctl --user daemon-reload
        systemctl --user enable swap_monitor.service
        systemctl --user start swap_monitor.service
        zenity --info --text="Installation completed! Swap Monitor Service has been enabled and started for the current user."
    else
        zenity --error --text="Installation failed."
        exit 1
    fi
else
    # 시스템 전체 설치: 파일은 /usr/local/bin 에 복사 (sudo 필요)
    install_dir="/usr/local/bin"
    if sudo cp "$SOURCE_SCRIPT" "$install_dir/swapMemMonitoring.sh"; then
        sudo chmod +x "$install_dir/swapMemMonitoring.sh"
        
        # 시스템 전체 서비스 파일 생성 (/etc/systemd/system)
        service_file="/etc/systemd/system/swap_monitor.service"
        sudo bash -c "cat <<EOF > $service_file
[Unit]
Description=Swap Monitor Service
After=graphical.target

[Service]
ExecStart=$install_dir/swapMemMonitoring.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF"
        sudo systemctl daemon-reload
        sudo systemctl enable swap_monitor.service
        sudo systemctl start swap_monitor.service
        zenity --info --text="Installation completed! Swap Monitor Service has been enabled and started system-wide."
    else
        zenity --error --text="Installation failed."
        exit 1
    fi
fi

