source ../.config/kafka.prod.conf

function create_topic() {
    local topic=$1
    broker=$2
    echo "Creating topic $topic on $broker"
    echo "broker: $broker"
    local truststore=$(eval echo \$${broker}_TRUSTSTORE)
    local truststore_password=$(eval echo \$${broker}_TRUSTSTORE_PASSWORD)
    local keystore=$(eval echo \$${broker}_KEYSTORE)
    local keystore_password=$(eval echo \$${broker}_KEYSTORE_PASSWORD)
    local broker_name=$(eval echo \$${broker})
    local broker_host=$(eval echo \$${broker}_HOST)

    cp ../.config/ssl.client.conf ./ssl.client.conf

    if [  $? -eq 0 ]; then
      echo 'Copy completed.'
    fi

    echo 'replace variable'

    sed -i.bak -e "s/\$truststore/$truststore/g" \
           -e "s/\$ts_password/$truststore_password/g" \
           -e "s/\$keystore/$keystore/g" \
           -e "s/\$ks_password/$keystore_password/g" \
           ./ssl.client.conf

    cat ./ssl.client.conf

    KR_BROKER_CN=$(docker ps -a -q --filter "name=$broker_name")
    echo "Container id for $broker : $KR_BROKER_CN"

    $(docker cp ./ssl.client.conf $KR_BROKER_CN:/etc/kafka/secrets/ssl.client.conf)

    if [  $? -eq 0 ]; then
      echo 'Copy completed.'
    fi

    echo $broker_host

    docker exec -it $KR_BROKER_CN bash -c "kafka-topics --bootstrap-server $broker_host --command-config /etc/kafka/secrets/ssl.client.conf --list | grep -i $topic"

    # kafka-topics.sh --bootstrap-server $KR_BROKER --command-config ./ssl.client.conf --list | grep -i $topic

    # if [  $? -eq 0 ]; then
    #     echo "topic :$topic exists."
    # else
    #   kafka-topics.sh --bootstrap-server $KR_BROKER --topic $topic --create --partitions 3 ./ssl.client.conf
    # fi
  
}

function remove_conf(){
    if [ -f ./ssl.client.conf ]; then
      rm ./ssl.client.conf
      rm ./ssl.client.conf.bak
    fi
}


if [ -n "$KR_TOPICS" ]; then
	echo "Topic creation started: $KR_TOPICS"
  kr_broker_keys="KR_BROKER1,KR_BROKER2"
	for topic in $(echo $KR_TOPICS | tr ',' '\n'); do
    for brokerkey in $(echo $kr_broker_keys | tr ',' '\n'); do
      echo "Processing broker key: $brokerkey"
      create_topic $topic $brokerkey
      remove_conf
    done

	done
	echo "All topics created."
fi