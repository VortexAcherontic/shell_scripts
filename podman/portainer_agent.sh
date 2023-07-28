podman run -d \
  -p 9001:9001 \
  --name portainer_agent \
  --restart=always \
  -v /run/podman/podman.sock:/var/run/docker.sock:Z \
  -v /var/lib/containers/storage/volumes:/var/lib/docker/volumes \
  portainer/agent:2.18.4
