#!/bin/bash

#Parâmetros MySQL
DB_NAME='sapes'
DB_USER=''
DB_PASSWD=''

#Parâmetros Sistema
BACKUP_DIR_HOST=~/dev/backup
BACKUP_DIR_GUEST=/var/backups
LARADOCK=~/dev/sapes-api/laradock
DIR_ID_GDRIVE=1Zi0YdJCIS9seqlUm-SB1TUDOnUUCzpWQ
DATE=`date +%Y-%m-%d-%T`
BACKUP_NAME=$DATE-$DB_NAME.sql
BACKUP_ZIP=$DATE-$DB_NAME.zip
DAYS_BEFORE=7

#Gerando arquivo .sql
cd $LARADOCK

/usr/local/bin/docker-compose exec -d mysql sh -c "/usr/bin/mysqldump -u $DB_USER --password=$DB_PASSWD $DB_NAME > $BACKUP_DIR_GUEST/$BACKUP_NAME"
sleep 30
docker cp "$(/usr/local/bin/docker-compose ps -q mysql)":$BACKUP_DIR_GUEST/$BACKUP_NAME $BACKUP_DIR_HOST/


#Verifique se a distribuição possui o zip e unzip instalados,
#caso não, utilize o gerenciador de pacotes:
#sudo apt-get install zip unzip
#O comando acima serve para distribuições baseadas em Debian,
#caso esteja utilizando outra, utilize o gerenciador da sua versão
#Compactando em zip
zip $BACKUP_DIR_HOST/$BACKUP_ZIP $BACKUP_DIR_HOST/$BACKUP_NAME

#Apagando Backups antigos
/usr/bin/find $BACKUP_DIR_HOST -type f -name '*.sql' -mtime +$DAYS_BEFORE -exec rm {} \;
/usr/bin/find $BACKUP_DIR_HOST -type f -name '*.zip' -mtime +$DAYS_BEFORE -exec rm {} \;

#Enviando arquivo zip para o Google Drive
#Para o envio de arquivos para o Drive funcionar, é necessária a instalação de um software de terceiro
#disponível no GitHub: https://github.com/prasmussen/gdrive.
#Baixe a versão para sua distribuição e execute a primeira vez, para autorizar o envio para conta desejada
#com o comando ./gdrive-linux-* about (substitua o * pela sua versão linux utilizada).
#Acesse o link no seu browser, clique em "Allow" e cole o código de verificação no terminal.
#Documentação disponível no próprio repositório.
#A variável $DIR_ID_GDRIVE recebe como parâmetro o ID do diretório que você deseja enviar o arquivo, se desejar
#deixar na raiz remova o parâmetro --parent $DIR_ID_GDRIVE
#Para visualizar o ID dos diretórios disponíveis, execute o comando a seguir: ./gdrive-linux-* list
#Lembre-se de deixar o gdrive no mesmo diretório desse Script
/usr/local/bin/docker-compose exec -d mysql sh -c "cd /var/backups && ls"
docker-compose exec -d mysql sh -c "cd /var/backups && rm *.sql"

$BACKUP_DIR_HOST/gdrive upload --parent $DIR_ID_GDRIVE $BACKUP_DIR_HOST/$BACKUP_ZIP
