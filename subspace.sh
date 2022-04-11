#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/exfeddix17/cryptohodl/main/cryptohodl.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq git -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash
}

function read_nodename {
  echo -e "Enter your node name(random name for telemetry)"
  line_1
  read SUBSPACE_NODENAME
}

function read_wallet {
  echo -e "Enter your polkadot.js extension address"
  line_1
  read WALLET_ADDRESS
}

# function source_git {
#   git clone https://github.com/subspace/subspace
#   cd $HOME/subspace
#   git fetch
#   git checkout snapshot-2022-mar-09
# }
#
# function build_image_node {
#   cd $HOME/subspace
#   docker build -t subspacelabs/subspace-node:snapshot-2022-mar-09 -f $HOME/subspace/Dockerfile-node .
# }
#
# function build_image_farmer {
#   cd $HOME/subspace
#   docker build -t subspacelabs/subspace-farmer:snapshot-2022-mar-09 -f $HOME/subspace/Dockerfile-farmer .
# }

function eof_docker_compose {
  mkdir -p $HOME/subspace_docker/
  sudo tee <<EOF >/dev/null $HOME/subspace_docker/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: ghcr.io/subspace/node:snapshot-2022-mar-09
      networks:
        - default
        - subspace
      volumes:
        - source: subspace-node
          target: /var/subspace
          type: volume
      command: [
        "--chain", "testnet",
        "--wasm-execution", "compiled",
        "--execution", "wasm",
        "--base-path", "/var/subspace",
        "--ws-external",
        "--rpc-methods", "unsafe",
        "--rpc-cors", "all",
        "--bootnodes", "/dns/farm-rpc.subspace.network/tcp/30333/p2p/12D3KooWPjMZuSYj35ehced2MTJFf95upwpHKgKUrFRfHwohzJXr",
        "--validator",
        "--name", "$SUBSPACE_NODENAME",
        "--telemetry-url", "wss://telemetry.subspace.network/submit 0",
        "--telemetry-url", "wss://telemetry.postcapitalist.io/submit 0"
      ]
    farmer:
      image: ghcr.io/subspace/farmer:snapshot-2022-mar-09
      networks:
        - default
      volumes:
        - source: subspace-farmer
          target: /var/subspace
          type: volume
      restart: always
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--reward-address", "$WALLET_ADDRESS"
      ]

  networks:
    subspace:
      name: subspace

  volumes:
    subspace-node:
    subspace-farmer:
EOF
}

function docker_compose_up {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart node \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml restart farmer \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 node \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов фармера выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace_docker/docker-compose.yml logs -f --tail=100 farmer \n ${NORMAL}"
}

function delete_old {
  docker-compose -f $HOME/subspace_docker/docker-compose.yml down &>/dev/null
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node &>/dev/null
}

colors
line_1
logo
line_2
read_nodename
line_2
read_wallet
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
delete_old
line_1
# echo -e "Скачиваем репозиторий"
# source_git
# line_1
# echo -e "Билдим образ ноды"
# build_image_node
# line_1
# echo -e "Билдим образ фармера"
# build_image_farmer
# line_1
echo -e "Создаем docker-compose файл"
line_1
eof_docker_compose
line_1
echo -e "Запускаем docker контейнеры для node and farmer Subspace"
line_1
docker_compose_up
line_2
echo_info
line_2
