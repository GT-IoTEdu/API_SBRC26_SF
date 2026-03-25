#!/bin/bash

 
 
gnome-terminal --tab --title="backend" --command="bash -c ' cd backend/; docker-compose down; docker compose up --build; $SHELL'" --tab --title="frontend" --command="bash -c 'cd frontend/; docker-compose down; docker compose up --build;$SHELL'"

 
