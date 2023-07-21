#!/bin/bash

# 克隆的目录文件夹路径
clone_path=""

echo "歡迎使用 GitHub 倉庫上傳腳本"
echo ""

# 主菜单
main_menu() {
  PS3="請選擇一個選項: "
  options=("介紹" "檢查環境" "配置 id.rsa" "git clone" "配置腳本自動化" "定時任務" "退出")
  select option in "${options[@]}"; do
    case $option in
      "介紹")
        show_introduction
        ;;
      "檢查環境")
        check_environment
        ;;
      "配置 id.rsa")
        configure_id_rsa
        ;;
      "git clone")
        git_clone
        ;;
      "配置腳本自動化")
        configure_automation
        ;;
      "定時任務")
        schedule_task
        ;;
      "退出")
        echo "感謝使用！再見！"
        break
        ;;
      *)
        echo "無效的選項"
        ;;
    esac
    echo ""
  done
}

# 顯示介紹
show_introduction() {
  echo "這是一個腳本示例，用於配置 id.rsa 文件。"
  echo "透過生成或手動更改 id.rsa，你可以設置 SSH 密鑰以供使用。"
  echo "你可以選擇自動配置 id.rsa 或手動替換現有的 id.rsa。"
  echo ""
}

# 檢查環境
check_environment() {
  check_install_packages  # 检查并安装软件包
  echo "環境檢查已完成。"
  echo ""
  read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
}

# 配置 id.rsa
configure_id_rsa() {
  while true; do
    PS3="請選擇一個選項: "
    options=("自動配置 id.rsa（生成或覆蓋）" "手動替換 id.rsa" "返回主菜單")
    select option in "${options[@]}"; do
      case $option in
        "自動配置 id.rsa（生成或覆蓋）")
          generate_or_replace_id_rsa
          break
          ;;
        "手動替換 id.rsa")
          manual_replace_id_rsa
          break
          ;;
        "返回主菜單")
          echo ""
          return
          ;;
        *)
          echo "無效的選項"
          ;;
      esac
    done
    echo ""
  done
}

# 生成或替換 id.rsa
generate_or_replace_id_rsa() {
  if [[ -f "/root/.ssh/id_rsa" ]]; then
    echo "/root/.ssh/id_rsa 已經存在。"
    read -p "是否要生成新的 id.rsa 並覆蓋舊的配置？(y/n): " overwrite_choice
    if [[ $overwrite_choice == "y" ]]; then
      generate_id_rsa
    else
      echo "你未對 id.rsa 進行更改。"
      echo ""
      return
    fi
  else
    generate_id_rsa
  fi
}

# 生成新的 id.rsa
generate_id_rsa() {
  ssh-keygen -t rsa -f /root/.ssh/id_rsa
  echo ""
  echo "已完成 SSH 密鑰的創建。"
  echo ""
  read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
}

# 手動替換 id.rsa
manual_replace_id_rsa() {
  read -p "按 Enter 鍵以打開vim編輯器編輯 /root/.ssh/id_rsa 文件..."
  vim /root/.ssh/id_rsa  # 打開vim編輯器編輯文件

  chmod 600 /root/.ssh/id_rsa
  echo ""
  echo "已手動完成對 id.rsa 的更改。"
  echo ""
  read -p "是否返回主菜單？(y/n): " return_choice
  if [[ $return_choice == "y" ]]; then
    echo ""
    return
  else
    echo "感謝使用！再見！"
    exit 0
  fi
}

# 检查并安装软件包
check_install_packages() {
  required_packages=("vim" "git" "cron")
  missing_packages=()

  for package in "${required_packages[@]}"; do
    if ! command -v $package >/dev/null 2>&1; then
      missing_packages+=($package)
    fi
  done

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "缺少以下软件包：${missing_packages[*]}"
    read -p "是否要安装缺少的软件包？(y/n): " install_choice
    if [[ $install_choice == "y" ]]; then
      echo "正在安装软件包..."
      apt-get update
      apt-get install -y "${missing_packages[@]}"
      echo "软件包安装完成。"
    else
      echo "未安装缺少的软件包。"
    fi
  else
    echo "所有需要的软件包已安装。"
  fi
}


# git clone
git_clone() {
  read -p "請輸入 git clone 的連結: " clone_link
  read -p "請輸入 git clone 後的文件夾路徑: " clone_directory

  echo "正在執行 git clone..."
  git clone $clone_link $clone_directory
  echo "git clone 完成。"
  echo ""

  # 将 clone_directory 设为全局变量
  export clone_directory

  read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
}

# 配置脚本自动化
configure_automation() {
  if [[ -z $clone_directory ]]; then
    echo "請先執行 git clone 以設置克隆的目錄文件夾路徑。"
    echo ""
    read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
    return
  fi

  cd $clone_directory

  read -p "請配置 GitHub 全局帳戶名稱: " github_username
  read -p "請配置 GitHub 全局郵箱地址: " github_email

  echo "正在創建 upload_script.sh 腳本..."
  cat <<EOF > upload_script.sh
#!/bin/bash

# 刷新為最新的 clone
cd $clone_directory

# 拉取最新的更改
git pull origin main

# 配置 GitHub 全局帳戶名稱和郵箱地址
git config --global user.name "$github_username"
git config --global user.email "$github_email"

# 复制文件到克隆的仓库
cp -r /etc/bird $clone_directory
cp -r /etc/wireguard $clone_directory
cp -r /etc/network/interfaces $clone_directory

# 进入仓库目录
cd $clone_directory

  while true; do
    read -p "是否是第一次創建分支？(Y/N): " create_branch_choice
    case $create_branch_choice in
      [Yy]*)
        echo "正在創建新分支..."
        git branch main
        break
        ;;
      [Nn]*)
        echo "跳過分支創建。"
        break
        ;;
      *)
        echo "無效的選擇，請輸入 Y 或 N。"
        ;;
    esac
  done
  
# 切換分支
git checkout main

# 添加更改到 Git
git add .

# 提交更改
read -p "請輸入提交的訊息: " commit_message
git commit -m "\$commit_message"

# 推送到 GitHub
git push origin main
EOF

  echo "腳本配置完成。"
  echo ""
  read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
}

# 定時任務
schedule_task() {
  if [[ -z $clone_directory ]]; then
    echo "請先執行 git clone 以設置克隆的目錄文件夾路徑。"
    echo ""
    read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
    return
  fi

  read -p "請輸入定時任務的時間表達式(例如：'0 0 * * *' 表示每天零時): " schedule_expression

  # 建立定時任務
  cron_command="/bin/bash $clone_directory/upload_script.sh"
  (crontab -l 2>/dev/null; echo "$schedule_expression $cron_command") | crontab -

  echo "已建立定時任務。"
  echo ""
  read -p "是否返回主菜單？(按 Enter 鍵返回主菜單): "
}

# 开始运行主菜单
main_menu
