apply-echoserver:
	kubectl apply -f manifests/

install: apply-echoserver

delete-echoserver:
	kubectl delete -f manifests/

apply-all: apply-echoserver

debug:
	echo '[run] apt-get update; apt-get install -y curl zsh htop nmap net-tools'
