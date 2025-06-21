# PS4-lua-loader

> [!NOTE]  
> This project is largely based on the [automatic-lua-loader](https://github.com/BenNoxXD/automatic-lua-loader) project which is the PS5's equivalent.
<br>

This is an installer script that loads the PS4 Lapse Exploit and the bin_loader from the Lua savegame automatically whenever the game is ready. You can install it natively (eg. on a Raspberry Pi) or in a Docker container. You can find the Lua exploit right here: [Remote Lua Loader](https://github.com/shahrilnet/remote_lua_loader).

How it works:
1. Your device checks if port 9026 is open to determine whether the game is ready.
2. It sends the Lapse exploit followed by the bin_loader.
3. (Optional) sends a Killgame Payload. All of the Lua games should be supported.
4. It waits until the FTP server (port 2121) is closed to start the process all over again OR your server will shut down. 

> [!IMPORTANT]  
> Activate GoldHEN's FTP server so that it can track the status better.

## Configuration options
### Required:
1. `-ps4_ip=10.0.0.2`
- Define your PS4 IP.

### Optional:
2. `-killgame=on|off`<br/>
- default = off
- When enabled: The server automatically sends a Payload to the PS4 after the elfldr is loaded, which kills the game process. <br/>

3. `-continue=shutdown|ping`
- default = ping
- Here you can decide what your server will do after the exploit is loaded. You can choose between shutdown and ping. When ping is selected your server will wait until the GoldHEN's FTP server isn't running anymore and then start the jailbreak process again. 

## Native installation
You can just copy and paste the following command into your terminal (eg., via SSH). You can also use this command to update the Lapse & bin_loader payloads. It should be compatible with all Debian-based OSs; it was tested on Ubuntu and on the Raspberry Pi OS. <br>
Here is the command syntax, [] = optional: 

`./install.sh -ps4_ip=YOURPS4IP [-killgame=on|off] [-continue=shutdown|ping]`

And here is an example install command: 
<br>

```sh
sudo apt update
sudo apt install -y bash git wget python3
wget https://raw.githubusercontent.com/BenNoxXD/PS4-lua-loader/refs/heads/main/install.sh
sudo chmod +x install.sh
sudo ./install.sh -ps4_ip=10.0.0.2 -killgame=on -continue=ping
```

### Usage
If you are using a Raspberry Pi, it's recommended to connect it to one of the PS4's USB power ports. Now the Raspberry Pi will automatically turn on whenever your PS4 boots up. 
<br>

### Uninstall:
```sh
systemctl stop ps4lualoader
systemctl disable ps4lualoader
rm /etc/systemd/system/ps4lualoader.service
rm -r /opt/PS4-lua-loader
```

## Docker installation
Make sure you have [Docker](https://docs.docker.com/engine/install/) installed. You can check it like this: `docker -v`.
Now you can download this Dockerfile:
<br>

```sh
wget https://raw.githubusercontent.com/BenNoxXD/PS4-lua-loader/refs/heads/main/Dockerfile
```

<br>

Then run the following commands to build the image and deploy the container.
<br>

```sh
docker build \
--build-arg ps4_ip=10.0.0.2 \
--build-arg killgame=on \
--build-arg continue=ping \
-t ps4-lua-loader .

docker run -d -t --name PS4-Lua-Loader --restart always ps4-lua-loader
```
