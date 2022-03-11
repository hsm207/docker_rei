install:
	bash rei.sh && \
	# docker network connect kind rasa-x && \
	# MASTER_IP=$$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rasa-control-plane) && \
	# sed -i "s/^    server:.*/    server: https:\/\/$$MASTER_IP:6443/" $$HOME/.kube/config && \
	rasactl start rasa-x \
		--rasa-x-password safe_credential  \
    	--rasa-x-chart-version 4.4.0 \
    	--values-file values.yml && \
	kubectl apply -f custom-ingress.yml

install-rei:
	bash rei.sh

adjust-kubectl:
	docker network connect kind rasa-x && \
	MASTER_IP=$$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rasa-control-plane) && \
	sed -i "s/^    server:.*/    server: https:\/\/$$MASTER_IP:6443/" $$HOME/.kube/config

add-ingress:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml


install-did: install-rei
	-rasactl start rasa-x \
			--project-path $$(pwd)/bot \
			--rasa-x-password safe_credential  \
			--rasa-x-chart-version 4.4.0 \
			--values-file values.yml
	-kubectl apply -f custom-ingress.yml

install-dfd: install-rei adjust-kubectl add-ingress
	rasactl start rasa-x \
			--rasa-x-password safe_credential  \
			--rasa-x-chart-version 4.4.0 \
			--values-file values.yml && \
		kubectl apply -f custom-ingress.yml


build:
	d=`date +%Y%m%d` && \
	docker build . -t hsm207/docker-rei:$$d

run:
	docker run -it \
		--entrypoint bash \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $$(pwd)/bot:/app/bot \
		--name rasa-x \
		--rm \
		--privileged \
		hsm207/docker-rei:20220310	

clean:
	-kind delete clusters rasa
	-docker rm -f $$(docker ps  -f name='rasa*' -q)
	-docker network rm kind
	-docker rm -f $$(docker ps -a -f volume='dind-var-lib-docker' -q)
	-docker volume rm dind-var-lib-docker
	