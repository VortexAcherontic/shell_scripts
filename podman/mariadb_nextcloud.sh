container_name="mariadb"
service="container-${container_name}"
db_dir="/my/external/data/storage"

mkdir -p $db_dir

systemctl stop ${service}
podman rm ${container_name}

podman run --name ${container_name} \
	-v $db_dir:/var/lib/mysql \
	-p 3306:3306 \
	-e MARIADB_USER=nextcloud \
	-e MARIADB_PASSWORD=1234IsABadPassword \
	-e MARIADB_ROOT_PASSWORD=1234IsABadPassword \
	-e MARIADB_DATABASE=nextcloud \
	-d mariadb:latest

service_file="/etc/systemd/system/${service}.service"
podman generate systemd --name "${container_name}" >"${service_file}"
systemctl enable ${service}
systemctl start ${service}
