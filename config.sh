# Change network's name
perl -i -pe 's/fablo_network.*/fishnet_network/g' "./fablo-target/fabric-docker/.env"

# Change image couchdb
perl -i -pe 's/hyperledger\/fabric-couchdb:0.4.18/couchdb:3.1/g' "./fablo-target/fabric-docker/docker-compose.yaml"

# Change apirest's name
perl -i -pe 's/fablo-rest\./api-rest\./g' "./fablo-target/fabric-docker/docker-compose.yaml"
perl -i -pe 's/softwaremill\/fablo-rest:\${FABLO_REST_VERSION}/eacuna\/fabric-rest:1\.2/g' "./fablo-target/fabric-docker/docker-compose.yaml"

# Change peer0 fishers's name
find ./fablo-target -type f -exec perl -i -pe 's/peer0\.fishers/emarpaexpro\.fishers/g' {} \;
perl -i -pe 's/fishers.*\$3.*peer0/fishers" ] && [ "\$3" = "emarpaexpro/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/fishers.*\$4.*peer0/fishers" ] && [ "\$4" = "emarpaexpro/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/fishers.*\$5.*peer0/fishers" ] && [ "\$5" = "emarpaexpro/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/peers\/emarpaexpro/peers\/peer0/g' "./fablo-target/fabric-docker/docker-compose.yaml"

# Change peer0 partners's name
find ./fablo-target -type f -exec perl -i -pe 's/peer0\.partners/utp\.partners/g' {} \;
perl -i -pe 's/partners.*\$3.*peer0/partners" ] && [ "\$3" = "utp/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/partners.*\$4.*peer0/partners" ] && [ "\$4" = "utp/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/partners.*\$5.*peer0/partners" ] && [ "\$5" = "utp/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/peers\/utp/peers\/peer0/g' "./fablo-target/fabric-docker/docker-compose.yaml"

# Change peer1 partners's name
find ./fablo-target -type f -exec perl -i -pe 's/peer1\.partners/pnipa\.partners/g' {} \;
perl -i -pe 's/partners.*\$3.*peer1/partners" ] && [ "\$3" = "pnipa/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/partners.*\$4.*peer1/partners" ] && [ "\$4" = "pnipa/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/partners.*\$5.*peer1/partners" ] && [ "\$5" = "pnipa/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/peers\/pnipa/peers\/peer1/g' "./fablo-target/fabric-docker/docker-compose.yaml"

# Change peer0 public's name
find ./fablo-target -type f -exec perl -i -pe 's/peer0\.public/common\.public/g' {} \;
perl -i -pe 's/public.*\$3.*peer0/public" ] && [ "\$3" = "common/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/public.*\$4.*peer0/public" ] && [ "\$4" = "common/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/public.*\$5.*peer0/public" ] && [ "\$5" = "common/g' "./fablo-target/fabric-docker/channel-query-scripts.sh"
perl -i -pe 's/peers\/common/peers\/peer0/g' "./fablo-target/fabric-docker/docker-compose.yaml"