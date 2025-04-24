#!/bin/sh

cat <<EOF >> /etc/prometheus/prometheus.yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - timeout: 10s
    - static_configs:
        - targets: ['${ALERTMANAGER_TARGET:-alertmanager:9093}']

rule_files:
  - /etc/prometheus/rules/*.yaml

scrape_configs:
  - job_name: aptos
    static_configs:
      - targets:
          [
            # Validator
            "${TESTNET_VALIDATOR_IP}:${TESTNET_VALIDATOR_PORT}",

            # VFN
            "${TESTNET_VFN_IP}:${TESTNET_VFN_PORT}",
          ]
        labels:
          chain: testnet

      - targets:
          [
            # Validator
            "${MAINNET_VALIDATOR_IP}:${MAINNET_VALIDATOR_PORT}",

            # VFN
            "${MAINNET_VFN_IP}:${MAINNET_VFN_PORT}",
          ]
        labels:
          chain: mainnet
EOF

# Start Prometheus with the generated configuration
exec prometheus --config.file=/etc/prometheus/${PROM_CONFIG_FILE:-prometheus.yaml} "$@"
