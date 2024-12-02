#!/bin/bash

# Script pour supprimer complètement Docker et tous ses éléments associés

echo "=== Arrêt de tous les conteneurs en cours d'exécution ==="
docker stop $(docker ps -aq) 2>/dev/null

echo "=== Suppression de tous les conteneurs ==="
docker rm $(docker ps -aq) 2>/dev/null

echo "=== Suppression de toutes les images ==="
docker rmi $(docker images -q) 2>/dev/null

echo "=== Suppression de tous les volumes ==="
docker volume rm $(docker volume ls -q) 2>/dev/null

echo "=== Suppression de tous les réseaux ==="
docker network rm $(docker network ls -q) 2>/dev/null

echo "=== Désinstallation de Docker et de ses dépendances ==="
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== Nettoyage des paquets et des dépendances ==="
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "=== Suppression des fichiers de configuration de Docker ==="
sudo rm -rf /var/lib/docker
sudo rm -rf /etc/docker
sudo rm -rf /var/run/docker.sock
sudo rm -rf ~/.docker

echo "=== Docker a été complètement supprimé du système. ==="
