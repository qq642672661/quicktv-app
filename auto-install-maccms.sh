#!/bin/bash

echo "等待 MySQL 启动..."
sleep 10

echo "检查数据库连接..."
until docker exec quicktv-mysql mysql -uroot -proot -e "SELECT 1;" > /dev/null 2>&1; do
  echo "等待 MySQL 准备就绪..."
  sleep 2
done

echo "MySQL 已就绪！"

echo "检查数据库是否已初始化..."
TABLE_COUNT=$(docker exec quicktv-mysql mysql -uroot -proot maccms10 -e "SHOW TABLES;" 2>/dev/null | wc -l)

if [ "$TABLE_COUNT" -gt 1 ]; then
  echo "数据库已经初始化，跳过..."
else
  echo "初始化数据库..."
  docker exec -i quicktv-mysql mysql -uroot -proot maccms10 < maccms-official/application/install/sql/install.sql
  echo "数据库初始化完成！"
fi

echo "创建管理员账号..."
ADMIN_PASSWORD_MD5=$(echo -n "admin123" | md5sum | cut -d' ' -f1)

docker exec quicktv-mysql mysql -uroot -proot maccms10 -e "
INSERT INTO mac_admin (admin_id, admin_name, admin_pwd, admin_random, admin_status, admin_auth, admin_login_time, admin_login_ip, admin_login_num) 
VALUES (1, 'admin', '${ADMIN_PASSWORD_MD5}', '', 1, '', UNIX_TIMESTAMP(), '', 0)
ON DUPLICATE KEY UPDATE admin_pwd='${ADMIN_PASSWORD_MD5}';
"

echo "配置系统设置..."
docker exec quicktv-mysql mysql -uroot -proot maccms10 -e "
INSERT INTO mac_website (website_id, website_name, website_title, website_url, website_logo, website_status) 
VALUES (1, 'QuickTV', 'QuickTV视频管理系统', 'http://localhost:8080', '', 1)
ON DUPLICATE KEY UPDATE website_name='QuickTV';
"

echo "删除安装锁定文件..."
docker exec quicktv-maccms rm -f /var/www/html/application/data/install/install.lock

echo ""
echo "=========================================="
echo "MacCMS 自动安装完成！"
echo "=========================================="
echo ""
echo "访问地址："
echo "  前台: http://localhost:8080/"
echo "  后台: http://localhost:8080/admin.php"
echo ""
echo "管理员账号："
echo "  用户名: admin"
echo "  密码: admin123"
echo ""
echo "数据库信息："
echo "  主机: mysql"
echo "  数据库: maccms10"
echo "  用户: root"
echo "  密码: root"
echo "=========================================="
