Build Gnuradio's gr-pager for armhf under Ubuntu Xenial
=======================================================

```sh
sudo apt install qemu-user-static docker-engine
sudo mkdir /etc/systemd/system/docker.service.d
sudo sh -c 'cat > /etc/systemd/system/docker.service.d/docker.conf' <<EOF 
[Service]
ExecStart=
ExecStart=/usr/bin/docker daemon --dns 8.8.8.8 -H fd://
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
docker build -t xenial-armhf-gr-pager .
```
