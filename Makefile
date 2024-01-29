.PHONY: launch
launch:
	docker build -t docker-mysql-8 .
	docker run --name mysql-8 -d -v $(PWD)/db:/var/lib/mysql -p 13306:3306 docker-mysql-8
	docker exec -it mysql-8 bash
