docker run \
  --volume=batfish-data:/data \
  --publish=8888:8888 \
  --publish=9997:9997 \
  --publish=9996:9996 \
  --restart=always \
  --detach=true \
  --name=batfish \
  batfish/allinone
