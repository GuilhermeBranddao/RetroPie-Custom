

Passo 1: Conecte a rede
- Vá em "WiFi" -> "System Options -> Wireless LAN"
	- Escolha o idioma da rede (BR Brasil)
	- Se conecte a rede (Difigando manualmente)
- Vá em "System Options -> Password"
	- Defina a senha de usuario
- Vá em "Interface Options -> SSH"
	- Habilite a SSH 
    - Em seguida "Finish" -> "Yes"




cd ..
sudo git clone https://github.com/GuilhermeBranddao/retropie-custom.git
sudo cd retropie-custom
sudo chmod +x build.sh
sudo ./build.sh

# Realizar testes
sudo chmod +x test.sh
sudo ./test.sh

No seu celular (conectado na mesma rede Wi-Fi que o Raspberry Pi), abra o navegador e acesse: http://<IP_DO_RASPBERRY_PI>:5000


