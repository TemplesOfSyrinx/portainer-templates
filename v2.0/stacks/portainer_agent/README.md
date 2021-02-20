# Run Portainer Agent via docker-compose on Linux
- Install docker and docker-compose:
```
sudo apt update
sudo apt install docker.io docker-compose
```

- Add your user into `docker` group and then re-login to your account:
```
sudo usermod -aG docker <your_user>
```

# TLDR; Simple Copy/Paste
- Run the following command to deploy the Portainer Agent in your Docker host.

```
docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
```

# Customized using a script
- Run Portainer Agent:

```
bash deploy.sh up [<AGENT_PUBLISHED_PORT> [<AGENT_PORT> [<AGENT_HOST> [<AGENT_SECRET> [<TZ>]]]]]
```
where:
- "AGENT_PUBLISHED_PORT"-"Port Agent will be accessible on. (Defaults to 9001)",
- "AGENT_PORT"-"Port Agent will run on within the container. (Defaults to 9001)",
- "AGENT_HOST"-"Host Agent will listen on within the container. (Defaults to 0.0.0.0)",
- "AGENT_SECRET"-"Agent Secret used by Portainer to connect to Agent from multiple sources."
- "TZ"-"Timezone Portainer will run in."

for example:

```
bash deploy.sh up 9001
```

- Stop Portainer Agent:
```
bash deploy.sh down
```

# Note: Portainer Agent via docker-compose on RancherOS
- Docker is already installed on RancherOS but lacks **docker-compose** with a basic installation, this script will use a utility container instead:
  - docker/compose

- RancherOS also lacks **curl** with a basic installation, use a utility container to download files instead:
  - curlimages/curl

Once logged in as "rancher" user:
- To Run Portainer Agent:

```
docker run --rm curlimages/curl -L -v https://templesofsyrinx.github.io/portainer-templates/v2.0/stacks/portainer_agent/docker-compose.yml > docker-compose.yml

docker run --rm curlimages/curl -L -v https://templesofsyrinx.github.io/portainer-templates/v2.0/stacks/portainer_agent/deploy.sh > deploy.sh
```
then:
```
bash deploy.sh up <optional parameters>
```
# Note: Portainer Agent via docker-compose on Synology
- Install the **Docker** Package using **Package Center**

- The Synology **Docker** Package places the volumes in a custom location, **/volume1/@docker/volumes**
- Use a different compose file to deploy on Synology

Once logged in as "root" user:
- To Run Portainer Agent:

```
curl -L https://templesofsyrinx.github.io/portainer-templates/v2.0/stacks/portainer_agent/docker-compose-syno.yml -o docker-compose.yml

curl -L https://templesofsyrinx.github.io/portainer-templates/v2.0/stacks/portainer_agent/deploy.sh -o deploy.sh
```
then:
```
bash deploy.sh up <optional parameters>
```
