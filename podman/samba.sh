container_name="samba"
service="container-${container_name}"
systemctl stop ${service}
podman rm ${container_name}

podman run --name ${container_name} \
	-p 139:139 \
	-p 445:445 \
	-p 137:137/udp \
	-p 138:138/udp \
	-v "/my/external/data/storage:/share:Z" \
	-e USERID=1000 \
	-e GROUPID=1000 \
	-d dperson/samba \
	-n \
	-s "data;/share;yes;yes;no;all;none;samba_user;Shared files" \
	-u "samba_user;1234IsABadPassword" \
	-p \
	-g "usershare allow guests = yes" \
	-g "map to guest = bad user" \
	-g "load printers = no" \
	-g "printcap cache time = 0" \
	-g "printing = bsd" \
	-g "printcap name = /dev/null" \
	-g "disable spoolss = yes" \
	-w "WORKGROUP"

#mkdir -p $user_service_dir
service_file="/etc/systemd/system/${service}.service"
podman generate systemd -n "${container_name}" > "${service_file}"
systemctl enable ${service}
systemctl start ${service}
