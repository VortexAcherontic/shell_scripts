container_name="nextcloud"
service="container-${container_name}"

root_dir="/my/external/data/storage/nextcloud"
data_dir="$root_dir/data/"
html_dir="$root_dir/html/"
apps_dir="$root_dir/apps/"
config_dir="$root_dir/config/"
apache_dir="$root_dir/apache2/"

mkdir -p $data_dir
mkdir -p $html_dir
mkdir -p $apps_dir
mkdir -p $config_dir
mkdir -p $apache_dir

systemctl stop ${service}
podman rm ${container_name}

podman run --name ${container_name} \
	-p 80:80 \
	-p 8080:80 \
	-p 443:443 \
	-v "$html_dir:/var/www/html" \
	-v "$data_dir:/var/www/html/data" \
	-v "$apps_dir:/var/www/html/custom_apps" \
	-v "$config_dir:/var/www/html/config" \
	-v "$apache_dir:/etc/apache2/sites-enabled" \
	-e MYSQL_DATABASE=nextcloud \
	-e MYSQL_USER=nextcloud \
	-e MYSQL_PASSWORD=1234IsABadPassword \
	-e MYSQL_HOST=192.168.178.3:3306 \
	-e NEXTCLOUD_ADMIN_USER=super_duper_user \
	-e NEXTCLOUD_ADMIN_PASSWORD=1234IsABadPassword \
	-d nextcloud:27

service="container-${container_name}"
service_file="/etc/systemd/system/${service}.service"
podman generate systemd --name "${container_name}" >"${service_file}"
systemctl enable ${service}
systemctl start ${service}
