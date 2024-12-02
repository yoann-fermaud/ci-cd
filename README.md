[Official documentation](https://docs.docker.com/reference/dockerfile/)
## Job 1
- Creation of the VM

## Job 2
	=> Tester l’installation de docker avec le conteneur « helloworld » et se
	familiariser avec les commandes.

- Open Docker Engine

- **To get and run the container :** 
```
sudo docker run hello-world
```

## Job 3
	=> Utilisation de « Dockerfile » pour recréer le conteneur « helloworld » depuis une image Debian minimum.

#### Commands : 
- **To build an image :** 
```
docker build [OPTIONS] PATH
```
	Options :
	`-t`, `--tag` : to name the image (format : "name:tag", tag is for the version)


- **To launch the container :**
```
docker run [OPTIONS] [IMAGE-NAME]
```
	Options :
	`--rm` : automatically remove the container and its associated anonymous volumes when it exits

#### In our case :
Dockerfile :
``` Dockerfile
# Create a build stage from a base image
FROM debian:bullseye-slim  

RUN apt-get update && \ 
	apt-get install -yqq --no-install-recommends && \  
	curl \  
	apt-get clean && \  
	rm -rf /var/lib/apt/lists/*  
# Operator && : can pass the next instruction only if the previous succeed
# Operator \ : indicate there is a new line (like an escape)
  
RUN echo '#!/bin/sh\n\necho "Hello from Debian Bullseye Slim!"' >/usr/local/bin/helloworld \  
	&& chmod +x /usr/local/bin/helloworld  
# Echo is usually used to write in terminal, here is used with '>' so the result is redirecting in the corresponding file.

# Specify default executable
ENTRYPOINT ["/usr/local/bin/helloworld"]
```

```
docker build -t helloworld .
```
Note : the point is the path, we build in the folder we are situated.

```
docker run --rm helloworld
```


## Job 4 : 
	=> Utilisation de Dockerfile pour créer une image SSH (compte : root et mot de passe : root123) sans utiliser une image SSH existante , voir redirection des ports (utiliser un autre port que le 22) , créé et lancez le conteneur et se connecter pour vérifier l’accès SSH.


``` Dockerfile
FROM debian:bullseye-slim  
  
RUN apt-get update && \  
	apt-get install -yqq openssh-server && \  
	apt-get clean && \  
	rm -rf /var/lib/apt/lists/*  
  
RUN mkdir /var/run/sshd  
RUN echo 'root:root123' | chpasswd  
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config  
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config  
  
EXPOSE 2222  
  
CMD ["/usr/sbin/sshd", "-D"]
```

```
docker build -t ssh-image .  
docker run -d -p 2222:2222 --name ssh-container ssh-image  
```

```
ssh root@localhost -p 2222 
```

Output : 
``` Shell
root@localhost's password:   
Linux 94031fd94a00 6.10.4-linuxkit #1 SMP Wed Oct  2 16:38:00 UTC 2024 aarch64  
  
The programs included with the Debian GNU/Linux system are free software;  
the exact distribution terms for each program are described in the  
individual files in /usr/share/doc/*/copyright.  
  
Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent  
permitted by applicable law.  
root@94031fd94a00:~#
```

In this case, password is "root123" (cf. Dockerfile)


## Job 5

	=> Tout informaticien étant « flemmard » , il faut faire des alias pour les commandes docker en cli , à mettre dans ~/.bashrc pour manipuler les images / containers.

To open the file  `~/.bashrc` or `~/.zshrc`: 
``` Shell
nano ~/.bashrc
```

Then write in file : 
``` Shell
alias d='docker'
```

To reload the aliases : 
``` Shell
source ~/.bashrc 
source ~/.zshrc 
```

Exemple : 
``` Shell
d images 
d ps -a
```


## Job 6 
	=> Se renseigner sur l’utilisation de volumes entre deux conteneurs et la gestion
	des volumes.

Data Volume Container consists to create a container (which is named) and give it volumes. It will be possible to consume these volumes from other containers (data persistancy).


## Job 7
	=> À l’aide d’un fichier yml , de docker-compose faire deux conteneurs : nginx et FTP liés entre eux. Création d'un volume commun pour accéder au dossier web.
	Créer sur votre pc un fichier index.html , dans ce fichier faites afficher votre nom/prénom). Installer FileZilla sur votre PC , se connecter en FTP sur le conteneur FTP pour envoyer le fichier index.html, et regarder le résultat.
	

``` Dockerfile
version: '3'

services:
  nginx:
    image: nginx:alpine
    container_name: nginx-container
    ports:
      - "8090:80"
    volumes:
      - web-data:/usr/share/nginx/html

  ftp:
    image: stilliard/pure-ftpd
    container_name: ftp-container
    ports:
      - "21:21"
      - "30000-30009:30000-30009"
    volumes:
      - web-data:/home/username/
      - web-data:/etc/pure-ftpd/passwd
    environment:
      PUBLICHOST: "localhost"
      FTP_USER_NAME: username
      FTP_USER_PASS: pass
      FTP_USER_HOME: /home/username
    restart: always

volumes:
  web-data:
```


## Job 8

Dockerfile : 
``` Dockerfile
FROM debian:bullseye-slim  

RUN apt-get update && \  
    apt-get install -yqq nginx && \  
    apt-get clean && \  
    rm -rf /var/lib/apt/lists/*  

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "-daemon off;"]
```

nginx.conf : 
``` nginx.conf
events {
    # configuration of connection processing
}

http {
    # Configuration specific to HTTP and affecting all virtual servers
    server {
        listen 80;
        server_name localhost;
        
		location / {
			root /usr/share/nginx/html;
			index index.html;
		}
    }
}
```

compose.yml : 
``` compose.yml
version: '3'

services:
  nginx:
    build:
      context: .
    container_name: nginx-container
    ports:
      - "8090:80"
    volumes:
      - web-data:/usr/share/nginx/html

volumes:
  web-data:
```


## Job 9 

compose.yml :
``` 
version: '3.8'  
  
services:  
	registry-server:  
		image: registry:2.8.2  
		container_name: registry-server  
		restart: always  
		ports:  
			- "5001:5000"  
		environment:  
			REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin: '[[http://localhost:8080](http://localhost:8080)]'  
			REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods: '[HEAD,GET,OPTIONS,DELETE]'  
			REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials: '[true]'  
			REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers: '[Authorization,Accept,Cache-Control]'  
			REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers: '[Docker-Content-Digest]'  
			REGISTRY_STORAGE_DELETE_ENABLED: 'true'  
		volumes:  
			- registry-data:/var/lib/registry  
  
	registry-ui:  
		image: joxit/docker-registry-ui:main  
		container_name: registry-ui  
		ports:  
			- "8080:80"  
		environment:  
			- SINGLE_REGISTRY=true  
			- REGISTRY_TITLE=Docker Registry UI  
			- DELETE_IMAGES=true  
			- SHOW_CONTENT_DIGEST=true  
			- REGISTRY_URL=[http://localhost:5001](http://localhost:5001)  
			- SHOW_CATALOG_NB_TAGS=true  
			- TAGLIST_PAGE_SIZE=10  
			- REGISTRY_SECURED=false  
			- CATALOG_ELEMENTS_LIMIT=100  
		restart: always  
  
volumes:  
	registry-data:
```

Commands : 
``` Shell
docker pull ubuntu  
docker tag ubuntu localhost:5001/ubuntu  
docker push localhost:5001/ubuntu  
  
docker pull nginx  
docker tag nginx localhost:5001/nginx  
docker push localhost:5001/nginx
```

Then go on : http://localhost:5001/v2/_catalog (API)
http://localhost:8080/
## Job 10 

``` Shell

```


## Project 
Ci files have an `.yml` extension.
By default, ci files with GitHub Actions are in `.github/workflows/`

Créer espace google > Appli et intégration > Webhooks > Ajouter (donner nom, URL facultative (rip yoann)) -> récupérer l'url qui se crée
DAns github > Repo > Security > Secret and variables > Actions > New repository -> mettre un nom et l'url qu'on a récupérée

[Repository for notification on google-chat](https://github.com/marketplace/actions/google-chat-notification-action)


## Notes
- Possible to have multiples images per container but by convention, we always do one image per container 
- 