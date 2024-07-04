```bash {"id":"01J1Z6XRZS4ZDYQK8HWDTJ2YAC"}
curl -fsSL https://raw.githubusercontent.com/jakkreerat2540/B-SCRIPTS/main/zsh.sh | bash

```

```bash {"id":"01J1Z6YNAP8HJS5XPX0KDFHS3P"}
curl -fsSL https://raw.githubusercontent.com/jakkreerat2540/B-SCRIPTS/main/generate_certificate.sh -o generate_certificate.sh
```

Run the script with the necessary options. For example:

```bash {"id":"01J1Z70DC3JA8XK40DDCDYZF8R"}
sudo ./generate_certificate.sh -m ca -h example.com -t /your/target/dir --ca-subj "/C=XX/ST=State/L=City/O=Org/OU=Unit/CN=example.com/emailAddress=email@example.com"
```

Create a CA without a password:

```bash {"id":"01J1Z71J8JHVM2RE3C2S8M99P2"}
sudo ./generate_certificate.sh -m ca -h example.com -t /your/target/dir
```

Create a Client Certificate without a password:

```bash {"id":"01J1Z728AZFA72SNRWG47AFD8E"}
sudo ./generate_certificate.sh -m client -h client_name -t /your/target/dir
```

You can include this Markdown section in your documentation to guide users on how to use the script.