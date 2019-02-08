FROM atlassian/default-image:2

RUN apt-get update
RUN apt-get install -y curl python-pip
RUN pip install awscli --upgrade --user
