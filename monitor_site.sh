#!/bin/bash

SITE_URL="http://localhost"
LOG_FILE="/var/log/monitoramento.log"
DISCORD_WEBHOOK="URL_DO_SEU_WEBHOOK_DISCORD"

# Função para log e notificação
log_and_alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
    if [[ $1 == *"OFFLINE"* ]]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"⚠️ **SITE OFFLINE**: $SITE_URL não está respondendo!\"}" "$DISCORD_WEBHOOK"
    fi
}

# Verifica se o site está online
if curl --output /dev/null --silent --head --fail --max-time 5 "$SITE_URL"; then
    log_and_alert "✅ ONLINE: $SITE_URL está respondendo."
else
    log_and_alert "❌ OFFLINE: $SITE_URL não está acessível!"
fi
