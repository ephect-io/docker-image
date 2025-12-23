#!/bin/bash
if [ -f "$HOME/.rorc" ]
then
	. "$HOME/.rorc"
else
    echo "❌ Error: Missing rocker configuration file at $HOME/.rorc"
    echo "Move rorc.dist to $HOME/.rorc and edit it to fit your needs."
    echo ""
    echo "export ROCKER_HOST=localhost"
    echo "export ROCKER_PORT=5000"
    echo ""
    exit 1
fi

COMMANDS="create|destroy|start|stop"
CMD=$(echo $1|grep -E "^($COMMANDS)$")

if [ -z "$CMD" ]
then
	echo "${0} $COMMANDS"
	exit 1
fi

if [ -z "$ROCKER_PORT" ]
then
    ROCKER_PORT=5000
	echo "ROCKER_PORT is not set, setting to $ROCKER_PORT"
	exit 1
fi

if [ -z "$ROCKER_HOST" ]
then
    ROCKER_HOST=localhost
	echo "ROCKER_HOST is not set, setting to $ROCKER_HOST"
	exit 1
fi

if [ "$CMD" = "create" ]
then
    echo "Creating local Docker registry on $ROCKER_HOST:$ROCKER_PORT"
    # Check if registry container already exists
    if docker ps -a --format "table {{.Names}}" | grep -q "^registry$"; then
        echo "Registry container already exists. Use 'start' to start it or 'destroy' to remove it first."
        exit 1
    fi
	docker run -d -p $ROCKER_PORT:5000 --name registry registry:latest
fi

if [ "$CMD" = "destroy" ]
then
    echo "Removing local Docker registry on $ROCKER_HOST:$ROCKER_PORT"
    # Stop the container first if it's running
    docker container stop registry 2>/dev/null || true
    # Remove the container
	docker container rm -v registry
fi

if [ "$CMD" = "start" ]
then
    echo "Sarting local Docker registry on $ROCKER_HOST:$ROCKER_PORT"
	docker container start registry
fi

if [ "$CMD" = "stop" ]
then
    echo "Stopping local Docker registry on $ROCKER_HOST:$ROCKER_PORT"
	docker container stop registry
fi
