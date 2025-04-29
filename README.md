# Projeto-Linux-Compass
Este guia fornece os passos para configurar um servidor Nginx, criar uma página HTML personalizada, e implementar um script de monitoramento com logs e notificações no Discord.

# Como instalar o Ubuntu
1. Ativar o WSL no Windows
## Abra o PowerShell como Administrador e execute:
```
wsl --install
```

2. Instalar Ubuntu pela Microsoft Store
- Abra a Microsoft Store.

![image](https://github.com/user-attachments/assets/f1358ec1-fadc-4ced-8b22-88e2e6a18f85)
- Cique em "Obter" ou "Instalar".
- Aguarde o download e a instalação.

# Etapa 1: Instalação do Nginx
1. Instalar o Nginx
```
   sudo apt update && sudo apt install nginx -y
```

2. Inicie e ative o serviço
```
sudo systemctl start nginx
sudo systemctl enable nginx
```

3. Verifique se está rodando
```
sudo systemctl status nginx
```
✅ Se aparecer active (running), o Nginx está funcionando.

# Etapa 2: Configuração do Site
1. Crie uma pasta para o site
```
sudo mkdir -p /var/www/meusite
```

2. Crie uma página HTML simples
```
sudo nano /var/www/meusite/index.html
```

## Conteúdo:
```
html
<!DOCTYPE html>
<html>
<head>
    <title>Meu Site</title>
</head>
<body>
    <h1>🚀 Site Funcionando!</h1>
    <p>Este é um teste de servidor Nginx.</p>
</body>
</html>
```

3. Configure o Nginx para servir o site
## Edite o arquivo de configuração:
```
sudo nano /etc/nginx/sites-available/meusite
```

## Conteúdo:
```
nginx
server {
    listen 80;
    server_name localhost;

    root /var/www/meusite;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

4. Ative o site e reinicie o Nginx
```
sudo ln -s /etc/nginx/sites-available/meusite /etc/nginx/sites-enabled/
sudo nginx -t  # Teste a configuração
sudo systemctl restart nginx
```

5. Acesse o site
1. Abra no navegador:
http://localhost

✅ Se aparecer a página HTML, o servidor está configurado!

# Etapa 3: Script de Monitoramento

1. Crie o script
```sudo nano /usr/local/bin/monitor_site.sh
```

## Conteúdo:
```
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
```

2. Dê permissão de execução
```
sudo chmod +x /usr/local/bin/monitor_site.sh
```

3. Crie o arquivo de log
```
sudo touch /var/log/monitoramento.log
sudo chmod 666 /var/log/monitoramento.log  # Permissão para escrita
```

4. Configure o CRON para executar a cada 1 minuto
```
sudo crontab -e
```

## Adicione a linha:
```
* * * * * /usr/local/bin/monitor_site.sh
```

5. Teste o script
```
sudo /usr/local/bin/monitor_site.sh
```

## Verifique os logs:
```
tail -f /var/log/monitoramento.log
```

# Etapa 4: Testes e Validação
1. Simule uma falha

## Pare o Nginx:
```
sudo systemctl stop nginx
```
## Verifique se o script detecta e envia alerta:
```
tail -f /var/log/monitoramento.log
```

2. Reinicie o Nginx
```
sudo systemctl start nginx
```

3. Verifique se o log registra o site online novamente
```
tail -f /var/log/monitoramento.log
```
