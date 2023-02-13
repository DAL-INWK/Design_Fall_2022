CLIENT_ID=<number>
GITHUB_SECRET=<number>
RPC_SECRET=<number>
# Address must be specified
HOST=<IP address>

docker run \
  --volume=/var/lib/drone:/data \
  --env=DRONE_GITHUB_CLIENT_ID=$CLIENT_ID \
  --env=DRONE_GITHUB_CLIENT_SECRET=$GITHUB_SECRET \
  --env=DRONE_RPC_SECRET=$RPC_SECRET \
  --env=DRONE_SERVER_HOST=$HOST \
  --env=DRONE_SERVER_PROTO=http \
  --env=DRONE_USER_CREATE=username:martimy,admin:true \
  --env=DRONE_USER_FILTER=martimy \
  --publish=80:80 \
  --publish=443:443 \
  --restart=always \
  --detach=true \
  --name=drone \
  drone/drone:2
