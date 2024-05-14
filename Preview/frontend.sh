# docker install
# Add ubuntu user to docker group
# docker run- frontend,backend1 and backend2

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

#Install docker
sudo apt-get install docker-ce 

#Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

#Add docker login
#sudo docker login -u jayapriya054 -p Jayamano@95

#Run docker container
sudo docker run -d --name my_container -p 80:80 jayapriya054/demo-frontend:latest
