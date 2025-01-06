# tools
Some useful tools and examples &lt;3
## 1. warp-cli (by CloudFlare) installer:
   - Run warp-cli install script:
     ```
     curl -L https://raw.githubusercontent.com/Skrepysh/tools/refs/heads/main/install-warp-cli.sh > install-warp-cli.sh && sudo chmod +x install-warp-cli.sh && sudo ./install-warp-cli.sh
     ```
   - You can change warp-cli settings using this command:
     ```
     warp-cli
     ```
   - Enjoy!
## 2. Caddyfile example for Xray (VLESS+Reality) and Marzban panel:
   - Run this command to place example Caddyfile in its place:
     ```
     sudo wget https://raw.githubusercontent.com/Skrepysh/tools/refs/heads/main/Caddyfile -qO /etc/caddy/Caddyfile && sudo nano /etc/caddy/Caddyfile
     ```
   - Caddyfile will open using nano
   - You must fill all fields marked with "🚨" with your values (and also delete comments marked with the same symbol)
   - After that you have to just restart caddy:
     ```
     sudo systemctl restart caddy
     ```
