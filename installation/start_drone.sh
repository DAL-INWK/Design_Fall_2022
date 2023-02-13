CLIENT_ID=4dd929d30a77aaa699d0
GITHUB_SECRET=2ed4b8e801e64c88057f81fe704b6316fe7a494f
RPC_SECRET=88808d97d501e651b0bf148d61c2b89d
# Address must be specified
HOST="129.173.143.143"

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
