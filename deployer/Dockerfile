FROM ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install python3 ansible ssh -y
RUN mkdir /app
COPY roles /app/roles
COPY main.yml /app
COPY hosts /app
COPY key /app
CMD cd /app && ansible-playbook -vvv -i hosts main.yml 
