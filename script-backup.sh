#!/bin/bash

#Parâmetros MySQL
DB_NAME='teste'
DB_USER='root'
DB_PASSWD='root'

#Verificando se existe o arquivo .my.cnf, caso não exista, é criado
#com os seguintes parâmetros:
#[client]
#password = root
if [ ! -e ".my.cnf" ]
then
    echo "[client]\npassword ="$DB_PASSWD > ".my.cnf"
fi

#Parâmetros Sistema
DATE=`date +%Y-%m-%d-%T`
BACKUP_DIR=/home/ntm
BACKUP_NAME=$DATE-$DB_NAME.sql
BACKUP_ZIP=$DATE-$DB_NAME.zip
DIR_ID_GDRIVE=1HXZnUyvabusqilvAWiyTIyqNTr4hFHLZ
DAYS_BEFORE=7

#Gerando arquivo .sql
mysqldump $DB_NAME -u $DB_USER > $BACKUP_DIR/$BACKUP_NAME

#Verifique se a distribuição possui o zip e unzip instalados, 
#caso não, utilize o gerenciador de pacotes:
#sudo apt-get install zip unzip
#O comando acima serve para distribuições baseadas em Debian, 
#caso esteja utilizando outra, utilize o gerenciador da sua versão
#Compactando em zip
zip $BACKUP_ZIP $BACKUP_NAME

#Apagando Backups antigos
/usr/bin/find $BACKUP_DIR -type f -name '*.sql' -mtime +$DAYS_BEFORE -exec rm {} \;
/usr/bin/find $BACKUP_DIR -type f -name '*.zip' -mtime +$DAYS_BEFORE -exec rm {} \;

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

./gdrive-linux-x64 upload --parent $DIR_ID_GDRIVE $BACKUP_ZIP
