# Create Kafka users dynamically
cat <<EOF > /etc/kafka/secrets/broker_jaas.conf
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="kr_adm"
    password="\$hell.Kr.walc"
    user_kr_adm="\$hell.Kr.walc";
};
EOF

# Start Kafka normally
exec /etc/confluent/docker/run