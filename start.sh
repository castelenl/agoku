#!/bin/sh

# Global variables
DIR_CONFIG="/etc/config"

# configs
mkdir -p /etc/caddy/ /usr/share/caddy /etc/config && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/xray.json

# Config & Run argo tunnel
if [ "${ArgoCERT}" = "CERT" ]; then
    echo skip 
else
    wget -O ${DIR_CONFIG}/cert.pem $ArgoCERT
    echo $ArgoJSON > ${DIR_CONFIG}/argo.json
    ARGOID="$(jq .TunnelID ${DIR_CONFIG}/argo.json | sed 's/\"//g')"
    cat << EOF > ${DIR_CONFIG}/argo.yaml
    tunnel: ${ARGOID}
    credentials-file: ${DIR_CONFIG}/argo.json
    ingress:
      - hostname: ${ArgoDOMAIN}
        service: http://localhost:$PORT
      - service: http_status:404
EOF
wget --no-check-certificate -O argo https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod 755 argo 
./argo --loglevel info --origincert ${DIR_CONFIG}/cert.pem tunnel -config ${DIR_CONFIG}/argo.yaml run ${ARGOID} &
fi

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/xray -config /xray.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
