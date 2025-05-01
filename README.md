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

![image](https://github.com/user-attachments/assets/0606b989-931d-486e-b586-f9a4ce66d374)

- Cique em "Obter" ou "Instalar".
- Aguarde o download e a instalação.
- Abra o Powershell ou o Prompt de Comando no modo administrador e execute o seguinte comando.
```
wsl --install
```
- Para mais informações sobre a instalação: https://learn.microsoft.com/pt-br/windows/wsl/install
# Etapa 1: Instalação do Nginx
1. Instalar o Nginx
```
   sudo apt update && sudo apt install nginx -y
```

2. Inicie e ative o serviço
```
sudo systemctl start nginx # ou sudo service nginx start
sudo systemctl enable nginx
```

3. Verifique se está rodando
```
sudo systemctl status nginx # ou sudo service nginx restart
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

## Exemplo:
```
<!DOCTYPE html>
<html>
<head>
    <title>Meu Site</title>
</head>
<body>
    <h1>Site Funcionando!</h1>
    <p>Este é um teste de servidor Nginx.</p>
</body>
</html>
```
## Customização do meu site:
![image](https://github.com/user-attachments/assets/3554e9e7-de63-4e68-92f2-e002f259b77b)

3. Configure o Nginx para servir o site
## Edite o arquivo de configuração:
```
sudo nano /etc/nginx/sites-available/meusite
```

## Conteúdo:
```
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
sudo systemctl restart nginx # ou sudo service nginx restart
```

5. Acesse o site
1. Abra no navegador:
http://localhost

✅ Se aparecer a página HTML, o servidor está configurado!

# Etapa 3: Script de Monitoramento

1. Crie o script
```
sudo nano /usr/local/bin/monitor_site.sh
```

## Conteúdo:
```
#!/bin/bash

SITE_URL="http://localhost"
LOG_FILE="/var/log/monitoramento.log"
DISCORD_WEBHOOK="URL_DO_SEU_WEBHOOK_DISCORD"
CHECK_INTERVAL=60 # Verifica a cada 1 minuto

# Função para log e notificação
log_and_alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
    if [[ $1 == *"OFFLINE"* ]]; then
        curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"⚠️ **SITE OFFLINE**: $SITE_URL não está respondendo!\"}" "$DISCORD_WEBHOOK"
    fi
}

# Loop infinito
while true; do
# Verifica se o site está online
if curl --output /dev/null --silent --head --fail --max-time 5 "$SITE_URL"; then
    log_and_alert "✅ ONLINE: $SITE_URL está respondendo."
else
    log_and_alert "❌ OFFLINE: $SITE_URL não está acessível!"
fi

    sleep "$CHECK_INTERVAL"  # Espera 1 minuto agora
done
```
### Comandos usados:
```#!/bin/bash``` → Indica que o script deve ser executado usando o interpretador Bash.

```SITE_URL="http://localhost"``` → Armazena a URL do site que será monitorado.

```LOG_FILE="/var/log/monitoramento.log"``` → Define o caminho do arquivo de log onde as mensagens de monitoramento serão salvas (/var/log/monitoramento.log).

``` DISCORD_WEBHOOK="URL_DO_SEU_WEBHOOK_DISCORD"``` → Armazena a URL do webhook do Discord para enviar notificações.

``` [[ $1 == *"OFFLINE"* ]]``` → Verifica se a mensagem ($1) contém a palavra "OFFLINE". Se verdadeiro, usa curl para enviar uma mensagem ao Discord via webhook:

```H "Content-Type``` → Define o cabeçalho HTTP para indicar que o conteúdo é JSON.

```X POST``` → Especifica o método HTTP POST.

```d "{\"content\":\"...\"}"``` → Corpo da requisição (mensagem formatada em JSON).

```$DISCORD_WEBHOOK```→ URL do webhook onde a mensagem será enviada.

7. Colar o URL no script de monitoramento.
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
## Como Criar um webhook no Discord
1. Acessar as configurações do seu servidor no Discord. 
2. Clicar na aba "Integrações". 
3. Clique em "Criar Webhook" ou "Novo Webhook". 
4. Personalize o webhook e colocar em algum canal no seu servidor.

6. Copie a URL do webhook e substituia URL_DO_SEU_WEBHOOK_DISCORD no script de monitoramento.

# Etapa 4: Testes e Validação
1. Simule uma falha

## Pare o Nginx:
```
sudo systemctl stop nginx # ou sudo service nginx stop
```

## Verifique se o script detecta e envia alerta:
```
tail -f /var/log/monitoramento.log
```

## No terminal:

![image](https://github.com/user-attachments/assets/276d6609-9ad7-4dc5-88d9-a23ccb60f2c0)

### Mensagem no Discord:

![image](https://github.com/user-attachments/assets/5c7ca1f0-ada1-4ae8-9280-bfc6d693399f)

2. Reinicie o Nginx
```
sudo systemctl start nginx # ou sudo service nginx start
```

3. Verifique se o log registra o site online novamente
```
tail -f /var/log/monitoramento.log
```
## No terminal:

![image](https://github.com/user-attachments/assets/abc1d681-1213-4199-919c-97fa5b049c81)
