#!/data/data/com.termux/files/usr/bin/bash

#修改了tmoe的判断脚本，termux-container的日志脚本 故采用相同的许可证：https://github.com/2moe/tmoe-linux/blob/master/share/old-version/share/app/manager#L158
mkdir -p $PREFIX/etc/apt/sources.list.d/
rm $PREFIX/var/log/msf.log > /dev/null 2>&1
export LOG_FILE="/data/data/com.termux/files/usr/var/log/msf.log"
LOG_HEAD(){
  echo "------------------START----------------------" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 基本信息: $(uname -a)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 系统架构: $(uname -m)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 内核版本: $(uname -r)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 安卓版本: $(getprop ro.build.version.release)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Termux信息: $(termux-info)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 源文件: $(cat $PREFIX/etc/apt/sources.list)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] sources.list.d源: $(cat $PREFIX/etc/apt/sources.list.d/*)" >> ${LOG_FILE}
  echo "[$(date +%Y-%m-%d\ %H:%M:%S)] 已安装包列表: $(pkg list-installed 2>/dev/null)" >> ${LOG_FILE}
}
LOG(){
  echo -e "[$(date +%Y-%m-%d\ %H:%M:%S)] $*" >> ${LOG_FILE}
}
LOG_END(){
  echo "----------------END--------------------" >> ${LOG_FILE}
}

if [ "$(id -u)" = "" ]; then
	whiptail --title "警告" --msgbox "⚠️不能以root身份运行此脚本！" 0 50 0 
	exit 1
fi

LOG_HEAD
LOG "安装必备软件包"
pkg install curl wget git -y > /dev/null 2>&1
[[ -e ${PREFIX}/bin/dialog ]] || apt install -y dialog > /dev/null 2>&1
[[ -e ${PREFIX}/bin/whiptail ]] || apt install -y whiptail > /dev/null 2>&1
LOG "源选择"
mirror=$(whiptail --title "github源选择" --menu "请选择github源" 15 6 4 \
"1" "github" \
"2" "fastgit" \
"3" "91chi" \
"4" "ghproxy" \
3>&1 1>&2 2>&3)

case $mirror in
1) export mirror=https://github.com ;;
2) export mirror=https://hub.fastgit.xyz ;;
3) export mirror=https://github.91chi.fun/https://github.com ;;
4) export mirror=https://ghproxy.com/https://github.com ;;
"") LOG_END && exit  ;;
esac
LOG "EULA"
LICENSE=$(curl -L ${mirror}/UtermuxBlog/termux-metasploit/raw/main/LICENSE) > /dev/null 2>&1
if (whiptail --title "EULA" --yes-button "同意" --no-button "拒绝"  --yesno "${LICENSE}" 0 50 0) then :
else
    LOG_END
    exit 1
fi  

LOG "安装软件包"

{
	pkg upgrade -y > /dev/null 2>&1
        pkg install -y sqlite git cmake binutils autoconf bison clang coreutils curl libandroid-support dnsutils findutils apr apr-util postgresql openssl openssl-1.1 openssl-tool openssl1.1-tool readline libffi libgmp libpcap libsqlite libgrpc libtool libxml2 libxslt ncurses make ncurses-utils ncurses git wget unzip zip tar termux-tools termux-elf-cleaner pkg-config git ruby -o Dpkg::Options::="--force-confnew" > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "安装软件包" --gauge "🚀请耐心等待软件包安装完成..." 0 50 0  
LOG "fix-ruby-bigdecimal"
{
        source <(curl -sL ${mirror}/termux/termux-packages/files/2912002/fix-ruby-bigdecimal.sh.txt) > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "fix-ruby-bigdecimal" --gauge "🔨fix-ruby-bigdecimal..." 0 50 0  
LOG "清除旧文件夹"
{
        rm -rf $PREFIX/opt/metasploit-framework > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "移除旧文件夹" --gauge "🗑️目录为：/data/data/com.termux/files/usr/opt/metasploit-framework" 0 50 0 
LOG "克隆存储库"
{
        git clone --depth=1 ${mirror}/rapid7/metasploit-framework.git $PREFIX/opt/metasploit-framework > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "克隆metasploit存储库" --gauge "🚀请耐心等待，跟你的网速有关。" 0 50 0 

cd $PREFIX/opt/metasploit-framework
LOG "gemfile"

LOG "gem源"
rubymirror=$(whiptail --title "rubygems源选择" --menu "请选择rubygems源" 15 6 4 \
"1" "💎rubychina(国内用户推荐)" \
"2" "💎清华源" \
"3" "💎哈工大源" \
"4" "💎中科大源" \
3>&1 1>&2 2>&3)

case $rubymirror in
1) LOG "rubychina" && gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/ > /dev/null 2>&1 && bundle config mirror.https://rubygems.org https://gems.ruby-china.com > /dev/null 2>&1 ;;
2) LOG "TUNA" && gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/ > /dev/null 2>&1 && bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems > /dev/null 2>&1 ;;
3) LOG "HIT" && gem sources --add https://mirrors.hit.edu.cn/rubygems/ --remove https://rubygems.org/ > /dev/null 2>&1 && bundle config mirror.https://rubygems.org https://mirrors.hit.edu.cn/rubygems/ > /dev/null 2>&1 ;;
4) LOG "ustc" && gem sources --add https://mirrors.ustc.edu.cn/rubygems/ --remove https://rubygems.org/ > /dev/null 2>&1 && bundle config mirror.https://rubygems.org https://mirrors.ustc.edu.cn/rubygems/ > /dev/null 2>&1 ;;
"") LOG_END && exit  ;;
esac
LOG "安装gem"
{
        cd $PREFIX/opt/metasploit-framework
        gem install actionpack 
	gem install bundler > /dev/null
        bundle update activesupport > /dev/null
	bundle config build.nokogiri --use-system-libraries > /dev/null
        bundle update --bundler > /dev/null 2>&1
        bundle install -j$(nproc --all) > /dev/null 2>&1
        gem install net-smtp profiler mini_portile2
        
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "安装Gems" --gauge "🚀这里比较久，请耐心等待..." 0 50 0 

gem uninstall nokogiri -v 1.13.8 --force > /dev/null
LOG "Nokogiri"
pkg i tur-repo -y > /dev/null 2>&1
pkg i gcc-11 -y > /dev/null 2>&1
wget -q https://mirrors.utermux.dev/nokogiri/nokogiri_1.8.0_aarch64_ruby3.gem > /dev/null 2>&1
gem install --local nokogiri_1.8.0_aarch64_ruby3.gem -- --use-system-libraries --with-xml2-config=$PREFIX/bin/xml2-config --with-xslt-config=$PREFIX/bin/xslt-config > /dev/null
pkg rem gcc-11 tur-repo -y > /dev/null 2>&1
LOG "卸载sqlite3"
gem uninstall sqlite3 --all --force > /dev/null

LOG "shebang"
{
        find -type f -executable -exec termux-fix-shebang \{\} \; > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "termux-fix-shebang" --gauge "🔨termux-fix-shebang" 0 50 0 

LOG "修复"
{
        sed -i 's|nokogiri (1.*)|nokogiri (1.8.0)|g' $PREFIX/opt/metasploit-framework/Gemfile.lock
	sed -i 's/.*sqlite3.*//g' $PREFIX/opt/metasploit-framework/Gemfile.lock
	rm /data/data/com.termux/files/usr/opt/metasploit-framework/lib/msf/core/post/windows/packrat.rb
	sed -i 's/.*sqlite3.*//g' $PREFIX/opt/metasploit-framework/metasploit-framework.gemspec
        cp -r "$PREFIX"/lib/openssl-1.1/* "$PREFIX"/lib/
        sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" $PREFIX/opt/metasploit-framework/lib/net/dns/resolver.rb > /dev/null 2>&1
        find $PREFIX/opt/metasploit-framework -type f -executable -print0 | xargs -0 -r termux-fix-shebang
        find $PREFIX/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner
        rm $PREFIX/bin/msfconsole > /dev/null 2>&1
        rm $PREFIX/bin/msfvenom > /dev/null 2>&1
        ln -sf $PREFIX/opt/metasploit-framework/msfconsole /data/data/com.termux/files/usr/bin/ > /dev/null 2>&1
        ln -sf $PREFIX/opt/metasploit-framework/msfvenom /data/data/com.termux/files/usr/bin/  > /dev/null 2>&1
        ln -sf $PREFIX/opt/metasploit-framework/msfdb /data/data/com.termux/files/usr/bin/ > /dev/null 2>&1
        termux-elf-cleaner /data/data/com.termux/files/usr/lib/ruby/gems/*/gems/pg-*/lib/pg_ext.so > /dev/null 2>&1
        sed -i '86 {s/^/#/};96 {s/^/#/}' $PREFIX/lib/ruby/gems/3.1.0/gems/concurrent-ruby-1.0.5/lib/concurrent/atomic/ruby_thread_local_var.rb > /dev/null
        sed -i '13,15 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/encryption_algorithm/functionable.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp256.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp384.rb; sed -i '14 {s/^/#/}' /data/data/com.termux/files/usr/lib/ruby/gems/3.1.0/gems/hrr_rb_ssh-0.4.2/lib/hrr_rb_ssh/transport/server_host_key_algorithm/ecdsa_sha2_nistp521.rb
        cp -r "$PREFIX"/lib/openssl-1.1/* "$PREFIX"/lib/
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "修复" --gauge "🔨进行一些必要的修复..." 0 50 0 
LOG "psql数据库"
{
        mkdir -p "$PREFIX"/opt/metasploit-framework/config > /dev/null 2>&1
        echo production: > "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo adapter: postgresql >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo database: msf_database >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo username: msf >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo password: >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo host: 127.0.0.1 >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo port: 5432 >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo pool: 75 >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
          echo timeout: 5 >> "$PREFIX"/opt/metasploit-framework/config/database.yml > /dev/null 2>&1
        mkdir -p "$PREFIX"/var/lib/postgresql > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "设置PostgreSQL数据库" --gauge "⚙️设置PostgreSQL数据库" 0 50 0 

pg_ctl -D "$PREFIX"/var/lib/postgresql stop > /dev/null 2>&1 || true
if ! pg_ctl -D "$PREFIX"/var/lib/postgresql start --silent; then
        initdb "$PREFIX"/var/lib/postgresql
fi
if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then
        createuser msf
fi
if [ -z "$(psql -l | grep msf_database)" ]; then
        createdb msf_database
fi
pg_ctl -D /data/data/com.termux/files/usr/var/lib/postgresql -l logfile start
LOG "清除缓存"
{
        rm -rf $HOME/.bundle/cache/* > /dev/null 2>&1
        pkg clean > /dev/null 2>&1
        pkg autoclean -y > /dev/null 2>&1
} | whiptail --backtitle "项目地址：github.com/UtermuxBlog/termux-metasploit" --title "清除缓存" --gauge "🧹清除bundle和pkg的缓存..." 0 50 0 

LOG "安装完成"
whiptail --title "Metasploit Framework" --msgbox "🎉msf安装完成,输入:msfconsole启动,如果有任何问题请到issues反馈:     github.com/UtermuxBlog/termux-metasploit/issues/new🥂" 0 50 0 
LOG_END&&exit 
