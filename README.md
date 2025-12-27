# RCMLTB - Rclone Mirror Leech Telegram Bot

An Rclone Mirror-Leech Telegram Bot to transfer to and from many clouds. Based on [mirror-leech-telegram-bot](https://github.com/anasty17/mirror-leech-telegram-bot) with rclone support added, and other features and changes from base code.

This is a fork of [Sam-Max/rcmltb](https://github.com/Sam-Max/rcmltb) with additional improvements and bug fixes.

**NOTE**: Base repository added recently its own rclone implementation.

---

## Table of Contents

- [Fork Improvements & Changelog](#-fork-improvements--changelog)
- [Private Channel Batch Operations](#-how-to-use-private-channel-batch-operations)
- [Features](#features)
- [Commands List](#commands-for-botset-through-botfather)
- [Command Usage Guide](#command-usage-guide-with-examples)
  - [Mirror Commands](#mirror-commands)
  - [Leech Commands](#leech-commands)
  - [YT-DLP Commands](#yt-dlp-commands-youtube-tiktok-instagram-etc)
  - [Rclone Commands](#rclone-commands)
  - [Google Drive Commands](#google-drive-commands)
  - [Torrent Commands](#torrent-commands)
  - [Debrid Commands](#debrid-commands)
  - [RSS Commands](#rss-commands)
  - [TMDB Commands](#tmdb-commands)
  - [Settings Commands](#settings-commands)
  - [Bot Management Commands](#bot-management-commands)
- [Common Options Summary](#common-options-summary)
- [Deployment Guide](#how-to-deploy)
- [Database Setup](#generate-database)
- [Rclone Config](#how-to-create-rclone-config-file)
- [Google Drive Setup](#getting-google-oauth-api-credential-file-and-tokenpickle)
- [Service Accounts](#using-service-accounts-to-avoid-user-rate-limit-for-google-drive-remotes)
- [Authentication (.netrc)](#yt-dlp-and-aria2c-authentication-using-netrc-file)

---

## 🆕 Fork Improvements & Changelog

This fork includes the following enhancements over the original repository:

### v1.1.0 - Private Channel Batch Fix (2024-12-24)

#### 🐛 Bug Fixes
- **Fixed "Peer id invalid" error for private channel batch operations**: The original bot would fail with `BAD_REQUEST: Peer id invalid` error when using `/mb` (mirror batch) or `/lb` (leech batch) commands with private/restricted channel links.
  - **Root Cause**: Pyrogram requires the peer (channel) to be in its internal cache before it can fetch messages. For private channels, this cache wasn't being populated.
  - **Solution**: The fix now iterates through user dialogs to find and cache the channel peer before attempting to fetch messages from private channels.

#### 🔧 Enhanced Error Handling
- **Improved error messages for batch commands**: When batch operations fail on private channels, the bot now provides more descriptive error messages including the actual exception, making it easier to diagnose issues.
- **Added channel validation**: The bot now checks if the channel exists in user's dialogs and provides a clear message if the channel is not found.

#### 📝 Documentation
- Added comprehensive guide for generating User Session String
- Added step-by-step instructions for private channel batch operations
- Updated README with fork improvements and changelog

---

## 📱 How to Use Private Channel Batch Operations

To download/mirror files from **private or restricted Telegram channels**, you need to set up a User Session String. This allows the bot to access channels that your Telegram account has joined.

### Step 1: Generate User Session String

1. **Install requirements** (if not already installed):
   ```bash
   pip3 install pyrogram
   ```

2. **Run the session generator script**:
   ```bash
   python3 session_generator.py
   ```

3. **Enter your credentials when prompted**:
   - `API_ID`: Get from https://my.telegram.org
   - `API_HASH`: Get from https://my.telegram.org
   - You will receive a verification code on your Telegram app - enter it when prompted

4. **Copy the generated session string**: The script will output a long string starting with `BQ...` - this is your session string.

### Step 2: Configure the Bot

Add your session string to `config.env`:
```env
USER_SESSION_STRING = "your_session_string_here"
```

### Step 3: Join the Private Channel

Make sure the Telegram account (whose session string you generated) has **joined the private channel** you want to download from.

### Step 4: Use Batch Commands

Now you can use batch commands with private channel links:

```
/mb https://t.me/c/1234567890/100 https://t.me/c/1234567890/150
```

This will mirror all files from message 100 to 150 from the private channel.

**Commands:**
- `/mb` or `/mirror_batch` - Mirror files from private channel to cloud
- `/lb` or `/leech_batch` - Leech files from private channel to Telegram

---

## Features:

### Rclone
- Copy file/folder from cloud to cloud
- Leech file/folder from cloud to Telegram
- Mirror Link/Torrent/Magnets/Mega/Telegram-Files to cloud
- Mirror from Telegram to multiple clouds at the same time
- Telegram Navigation Button Menus to interact with cloud
- File Manager: size, mkdir, delete, dedupe and rename
- Service Accounts support with automatic switching
- Create cloud index as http or webdav webserver
- Sync between clouds (not folders)
- Search files on cloud
- Clean cloud trash
- View cloud storage info 

### Others
- Send rclone config file from bot
- Renaming menu for Telegram files
- Index support (rclone index for all remotes)
- Search tmdb titles
- Mirror and Leech files in batch from Telegram private/restricted channels
- Mirror and Leech links in batch from .txt file
- Extract and zip link/file from Telegram to cloud
- Extract and zip folder/file from cloud to Telegram
- Mirror to local host (no cloud upload)
- Queue system for all Tasks.
- Debrid Manager (only real debrid support)
- Refactor of the whole code to use only pyrogram with asyncio
- Docker based image based on ubuntu
- Compatible with linux `amd64, arm64/v8, arm/v7`

## Commands for bot(set through @BotFather)

```
mirror - or /m Mirror to selected cloud
mirror_batch - or /mb Mirror Telegram files/links in batch to cloud
mirror_select - or /ms Select a fixed cloud/folder for mirror
leech - or /l Leech from cloud/link to Telegram
leech_batch - or /lb Leech Telegram files/links in batch to Telegram
ytdl - or /y Mirror ytdlp supported link
ytdl_leech - or /yl Leech yt-dlp supported link
setcookies - Set cookies for yt-dlp (TikTok, Instagram, etc.)
files - or /bf Bot configuration files
debrid - Debrid Manager
rcfm - Rclone File Manager
copy - Copy from cloud to cloud
clone - Clone gdrive link file/folder
count - count file/folder fom gdrive link
user_setting - User settings
own_setting - Owner settings
rss - Rss feed
tmdb - Search titles
cleanup - Clean cloud trash
cancel_all - Cancel all tasks
storage - Cloud details
serve - Serve cloud as web index
sync - Sync two clouds
torrsch - Search for torrents
status - Status message of tasks
stats - Bot stats
shell - Run cmds in shell
log - Bot log
ip - show ip
ping - Ping bot
restart - Restart bot
```

---

## Command Usage Guide with Examples

<details>
<summary><b>Mirror Commands</b> (click to expand)</summary>

### Mirror Commands

#### `/mirror` or `/m` - Mirror files to cloud storage

**Basic Usage:**
```
/mirror https://example.com/file.zip
```

**With custom name:**
```
/mirror https://example.com/file.zip -n MyCustomName.zip
```

**Extract archive after download:**
```
/mirror https://example.com/file.rar -e
/mirror https://example.com/file.rar -e password123
```

**Compress to zip:**
```
/mirror https://example.com/folder -z
/mirror https://example.com/folder -z password123
```

**Reply to Telegram file:**
```
Reply to any file with: /mirror
Reply to any file with: /mirror -n NewName.mp4
```

**Direct link with authentication:**
```
/mirror https://example.com/file.zip -au username -ap password
```

**Torrent with seeding:**
```
/mirror magnet:?xt=urn:btih:xxx -d 1.0:60
```
Note: `-d ratio:time` where time is in minutes

**Torrent file selection:**
```
/mirror magnet:?xt=urn:btih:xxx -s
```

**Multi-link download (reply to first link):**
```
/mirror -i 5
```

**Multi-link to same folder:**
```
/mirror -i 5 -m FolderName
```

**Generate screenshots:**
```
/mirror https://example.com/video.mp4 -ss 6
```

---

#### `/mirror_batch` or `/mb` - Mirror multiple files in batch

**From Telegram channel (public):**
```
/mb
```
Then send: `https://t.me/channel_name/100 https://t.me/channel_name/150`

**From private channel:**
```
/mb
```
Then send: `https://t.me/c/1234567890/100 https://t.me/c/1234567890/150`

**From multiple URLs:**
```
/mb
```
Then send:
```
https://example.com/file1.zip
https://example.com/file2.zip
https://example.com/file3.zip
```

**From .txt file:**
```
/mb
```
Then upload a .txt file with links (one per line)

---

#### `/mirror_select` or `/ms` - Set default cloud remote

```
/ms
```
Then select your preferred cloud storage from the menu.

</details>

<details>
<summary><b>Leech Commands</b> (click to expand)</summary>

### Leech Commands

#### `/leech` or `/l` - Download and send to Telegram

**Basic Usage:**
```
/leech https://example.com/file.zip
```

**Reply to cloud file:**
```
Reply to rclone file message with: /leech
```

**With custom name:**
```
/leech https://example.com/file.zip -n MyFile.zip
```

**Extract and leech:**
```
/leech https://example.com/archive.rar -e
```

---

#### `/leech_batch` or `/lb` - Leech multiple files to Telegram

Same as `/mb` but sends files to Telegram instead of cloud.

```
/lb
```
Then send Telegram links or URLs.

</details>

<details>
<summary><b>YT-DLP Commands</b> - YouTube, TikTok, Instagram, etc. (click to expand)</summary>

### YT-DLP Commands (YouTube, TikTok, Instagram, etc.)

#### `/ytdl` or `/y` - Download and mirror to cloud

**YouTube video:**
```
/ytdl https://www.youtube.com/watch?v=VIDEO_ID
```

**YouTube playlist:**
```
/ytdl https://www.youtube.com/playlist?list=PLAYLIST_ID
```

**TikTok account (all videos):**
```
/ytdl https://www.tiktok.com/@username
```

**TikTok single video:**
```
/ytdl https://www.tiktok.com/@user/video/1234567890
```

**Instagram post/reel:**
```
/ytdl https://www.instagram.com/p/POST_ID/
/ytdl https://www.instagram.com/reel/REEL_ID/
```

**With quality selection:**
```
/ytdl https://www.youtube.com/watch?v=VIDEO_ID -s
```

**With custom name:**
```
/ytdl https://www.youtube.com/watch?v=VIDEO_ID -n MyVideo
```

**With yt-dlp options:**
```
/ytdl link -opt playliststart:^1|playlistend:^10
/ytdl link -opt format:bestaudio
/ytdl link -opt writesubtitles:true|subtitleslangs:en
```

---

#### `/ytdl_leech` or `/yl` - Download and send to Telegram

Same as `/ytdl` but sends to Telegram instead of cloud.

```
/yl https://www.youtube.com/watch?v=VIDEO_ID
/yl https://www.tiktok.com/@username -s
```

---

#### `/setcookies` - Set cookies for authenticated downloads

**For TikTok, Instagram, YouTube (age-restricted), etc.:**

1. Export cookies from browser using a cookie extension
2. Send command with cookie data:
```
/setcookies
```
Then paste your cookies in Netscape format:
```
.tiktok.com	TRUE	/	TRUE	0	sessionid	YOUR_SESSION_ID
.tiktok.com	TRUE	/	TRUE	0	tt_webid	YOUR_WEBID
```

**TikTok Login (Alternative - WebApp):**
When downloading TikTok without cookies, the bot will show a login button. Click it to login via Telegram's in-app browser.

</details>

<details>
<summary><b>Rclone Commands</b> (click to expand)</summary>

### Rclone Commands

#### `/copy` - Copy between cloud storages

```
/copy
```
Then follow the interactive menu to select source and destination.

---

#### `/rcfm` - Rclone File Manager

```
/rcfm
```
Features:
- Browse files
- Create folders
- Delete files/folders
- Rename files
- Check file sizes
- Dedupe files

---

#### `/storage` - View cloud storage info

```
/storage
```
Shows available space on configured remotes.

---

#### `/cleanup` - Clean cloud trash

```
/cleanup
```
Then select the remote to clean.

---

#### `/sync` - Sync between clouds

```
/sync
```
Syncs files between two cloud remotes.

---

#### `/serve` - Serve cloud as web index

```
/serve
```
Creates HTTP/WebDAV index for your cloud files.

</details>

<details>
<summary><b>Google Drive Commands</b> (click to expand)</summary>

### Google Drive Commands

#### `/clone` - Clone Google Drive links

```
/clone https://drive.google.com/file/d/FILE_ID/view
/clone https://drive.google.com/drive/folders/FOLDER_ID
```

**Multi-clone:**
```
Reply to first link with: /clone -i 5
```

---

#### `/count` - Count files in Google Drive

```
/count https://drive.google.com/drive/folders/FOLDER_ID
```

</details>

<details>
<summary><b>Torrent, Debrid, RSS, TMDB Commands</b> (click to expand)</summary>

### Torrent Commands

#### `/torrsch` - Search for torrents

```
/torrsch movie name
/torrsch ubuntu 22.04
```

---

### Debrid Commands

#### `/debrid` - Real-Debrid Manager

```
/debrid
```
Manage Real-Debrid account and unrestrict links.

---

### RSS Commands

#### `/rss` - RSS Feed Manager

```
/rss
```
Add, remove, and manage RSS feeds for auto-downloading.

**Adding RSS feed:**
```
Title https://rss-feed-url.com c: mirror inf: 1080p exf: CAM
```

---

### TMDB Commands

#### `/tmdb` - Search movie/TV titles

```
/tmdb Inception
/tmdb Breaking Bad
```

</details>

<details>
<summary><b>Settings Commands</b> (click to expand)</summary>

### Settings Commands

#### `/user_setting` - User settings

```
/user_setting
```
Configure:
- Default upload remote
- Thumbnail
- Leech settings
- And more...

---

#### `/own_setting` - Owner settings (Admin only)

```
/own_setting
```
Configure bot-wide settings.

</details>

<details>
<summary><b>Bot Management Commands</b> (click to expand)</summary>

### Bot Management Commands

#### `/files` or `/bf` - Bot configuration files

```
/files
```
Upload/download bot config files (rclone.conf, token.pickle, etc.)

---

#### `/status` - View active tasks

```
/status
```

---

#### `/stats` - Bot statistics

```
/stats
```
Shows CPU, RAM, disk usage, and uptime.

---

#### `/cancel` - Cancel a task

```
Reply to task message with: /cancel
```

---

#### `/cancel_all` - Cancel all tasks

```
/cancel_all
```

---

#### `/shell` - Run shell commands (Admin only)

```
/shell ls -la
/shell df -h
```

---

#### `/log` - View bot logs (Admin only)

```
/log
```

---

#### `/restart` - Restart bot (Admin only)

```
/restart
```

---

#### `/ping` - Check bot response

```
/ping
```

---

#### `/ip` - Show server IP

```
/ip
```

</details>

---

## Common Options Summary

| Option | Description | Example |
|--------|-------------|---------|
| `-n` | Custom name | `/mirror link -n NewName.zip` |
| `-e` | Extract archive | `/mirror link -e` |
| `-e pass` | Extract with password | `/mirror link -e mypassword` |
| `-z` | Compress to zip | `/mirror link -z` |
| `-z pass` | Zip with password | `/mirror link -z mypassword` |
| `-s` | Selection mode | `/mirror torrent -s` |
| `-d` | Seed ratio:time | `/mirror torrent -d 1.0:60` |
| `-i N` | Multi-link (N files) | `/mirror -i 5` |
| `-m folder` | Same directory | `/mirror -i 5 -m MyFolder` |
| `-au` | Auth username | `/mirror link -au user` |
| `-ap` | Auth password | `/mirror link -ap pass` |
| `-ss` | Screenshots | `/mirror video -ss 10` |
| `-opt` | YT-DLP options | `/ytdl link -opt format:best` |

---

<details>
<summary><b>How to deploy?</b> (click to expand)</summary>

## How to deploy?

1. **Installing requirements**

- Clone repo:

```
git clone https://github.com/Sam-Max/rcmltb rcmltb/ && cd rcmltb
```

- For Debian based distros
```
sudo apt install python3 python3-pip
```

Install Docker by following the [official Docker docs](https://docs.docker.com/engine/install/debian/)

- For Arch and it's derivatives:

```
sudo pacman -S docker python
```

- Install dependencies for running setup scripts:

```
pip3 install -r requirements-cli.txt
```

2. **Set up config file**

- cp config_sample.env config.env 

- Fill up the fields on the config.env: **NOTE**: All values must be filled between quotes, even if it's `Int`, `Bool` or `List`.

**1. Mandatory Fields**

  - `API_ID`: get this from https://my.telegram.org. `Int`
  - `API_HASH`: get this from https://my.telegram.org. `Str`
  - `BOT_TOKEN`: The Telegram Bot Token (get from @BotFather). `Str`
  - `OWNER_ID`: your Telegram User ID (not username) of the owner of the bot. `Int`

**2. Optional Fields**

  - `DOWNLOAD_DIR`: The path to the local folder where the downloads will go. `Str`
  - `SUDO_USERS`: Fill user_id of users whom you want to give sudo permission separated by spaces. `Str`
  - `ALLOWED_CHATS`: list of IDs of allowed chats who can use this bot separated by spaces `Str`
  - `AUTO_MIRROR`: For auto mirroring files sent to the bot. **NOTE**: If you add bot to group(not channel), you can also use this feature. Default is `False`. `Bool`
  - `DATABASE_URL`: Your Mongo Database URL (Connection string). Data will be saved in Database (auth and sudo users, owner and user setting, etc). **NOTE**: You can always edit all settings saved in database from mongodb site -> (browse collections). `Str`
  - `CMD_INDEX`: index number that will be added at the end of all commands. `Str`
  - `GD_INDEX_URL`: Refer to https://gitlab.com/ParveenBhadooOfficial/Google-Drive-Index. `Str`
  - `VIEW_LINK`: View Link button to open file Google Drive Index Link in browser instead of direct download link, you can figure out if it's compatible with your Index code or not, open any video from you Index and check if its URL ends with `?a=view`. Compatible with [BhadooIndex](https://gitlab.com/ParveenBhadooOfficial/Google-Drive-Index) Code. Default is `False`. `Bool`
  - `STATUS_LIMIT`: No. of tasks shown in status message with buttons.`Int`
  - `LOCAL_MIRROR`= set to `True` for enabling files to remain on host. Default to False.
  - `TORRENT_TIMEOUT`: Timeout of dead torrents downloading with qBittorrent
  - `AUTO_DELETE_MESSAGE_DURATION`: Interval of time (in seconds), after which the bot deletes it's message and command message. Set to `-1` to disable auto message deletion. `Int`
  - `TMDB_API_KEY`: your tmdb API key. [Click here](https://www.themoviedb.org/settings/api) 
  - `TMDB_LANGUAGE`: tmdb search language. Default `en`.
  - `PARALLEL_TASKS`: Number of parallel tasks for queue system. `Int`

  ### Update

  - `UPSTREAM_REPO`: Your github repository link. If your repo is private, add your github repo link with format: `https://username:{githubtoken}@github.com/{username}/{reponame}`: get token from [Github settings](https://github.com/settings/tokens). `Str`. With this field you can update your bot from public/private repository on each restart. 
  - `UPSTREAM_BRANCH`: Upstream branch for update. Default is `master`. `Str`
  **NOTE**: If any change in docker or requirements you will need to deploy/build again with updated repo for changes to apply. DON'T delete .gitignore file.

  ### Rclone
  
  - `DEFAULT_OWNER_REMOTE`: to set default remote from your rclone config for mirroring. (only for owner). `Str`
  - `DEFAULT_GLOBAL_REMOTE`: to set default remote from global rclone config for mirroring. Use this when `MULTI_RCLONE_CONFIG` is `False`. `Str`
  - `MULTI_RCLONE_CONFIG`: set to `True` for allowing each user to use their own rclone config. Default to False. `Bool` 
  - `REMOTE_SELECTION`: set to `True` to activate selection of cloud server each time using mirror command. Default to `False`. `Bool`
  - `MULTI_REMOTE_UP`= set to `True` for allowing upload to multiple clouds servers at the same time. `Bool`. (only for owner)
  - `USE_SERVICE_ACCOUNTS`: set to `True` for enabling SA for rclone copy. Default to False. `Bool`.
  - `SERVICE_ACCOUNTS_REMOTE`= name of the shared drive remote from your rclone config file. `Str`. **Note**: remote must have `team_drive` field with `id` in order to work. `Str`
  - `SERVER_SIDE`= set to `True` for enabling rclone server side copy. Default to False. **NOTE**: if you get errors while copy set this to `False`. `Bool`
  - `RCLONE_COPY_FLAGS` = key:value,key. All Flags: [RcloneFlags](https://rclone.org/flags/).`Str`
  - `RCLONE_UPLOAD_FLAGS` = key:value,key. `Str`
  - `RCLONE_DOWNLOAD_FLAGS` = key:value,key.`Str`
  - `RC_INDEX_URL`: Public IP/domain where bot is running. Format of URL must be: http://myip, where myip is the Public IP/Domain. `Str`
  - `RC_INDEX_PORT`: Port to use. Default to `8080`. `Str`
  - `RC_INDEX_USER`: Custom user. Default to `admin`. `Str`
  - `RC_INDEX_PASS`: Custom password. Default to `admin`. `Str`

  ### GDrive Tools

  - `GDRIVE_FOLDER_ID`: Folder/TeamDrive ID of the Google Drive Folder or `root` to which you want to clone. Required for `Google Drive`. `Int`
  - `IS_TEAM_DRIVE`: Set `True` if TeamDrive. Default is `False`. `Bool`
  - `EXTENSION_FILTER`: File extensions that won't clone. Separate them by space. `Str`
  **Notes**: Must add **token.pickle** file directly to root for cloning to work. You can use /files command to add from bot.
   
  ### Leech

  - `LEECH_SPLIT_SIZE`: Telegram upload limit in bytes, to automatically slice the file bigger that this size into small parts to upload to Telegram. Default is `2GB` for non premium account or `4GB` if your account is premium. `Int`
  - `EQUAL_SPLITS`: Split files larger than **LEECH_SPLIT_SIZE** into equal parts size (not working with zip cmd). Default is `False`. `Bool`
  - `USER_SESSION_STRING`: Pyrogram session string for batch commands and for telegram premium upload. To generate string session use this command `python3 session_generator.py` on command line on your pc from repository folder. **NOTE**: When using string session, you have to use with `LEECH_LOG`. You can also use batch commands without string session, but you can't save messages from private/restricted telegram channels. `Str`
  - `LEECH_LOG`: Chat ID. Upload files to specific chat/chats. Add chats separated by spaces. `Str` **NOTE**: Only available for superGroup/channel. Add `-100` before channel/supergroup id. Add bot in that channel/group as admin if using without string session.
  - `BOT_PM`: set to `True` if you want to send leeched files in user's PM. Default to False. `Bool`

  ### MEGA

  - `MEGA_EMAIL`: E-Mail used to sign up on mega.nz for using premium account.`Str`
  - `MEGA_PASSWORD`: Password for mega.nz account.`Str`

  ### RSS

  - `RSS_DELAY`: Time in seconds for rss refresh interval. Default is `900` in sec. `Int`
  - `RSS_CHAT_ID`: Chat ID where rss links will be sent. If you want message to be sent to the channel then add channel id. Add `-100` before channel id. `Int`
  - **RSS NOTE**: `RSS_CHAT_ID` is required, otherwise monitor will not work. You must use `USER_STRING_SESSION` --OR-- *CHANNEL*. If using channel then bot should be added in both channel and group(linked to channel) and `RSS_CHAT_ID` is the channel id, so messages sent by the bot to channel will be forwarded to group. Otherwise with `USER_STRING_SESSION` add group id for `RSS_CHAT_ID`. If `DATABASE_URL` not added you will miss the feeds while bot offline.    

  ### qBittorrent/Aria2c

  - `QB_BASE_URL`: Valid BASE URL where the bot is deployed to use qbittorrent web selection and local mirror. Format of URL should be http://myip, where myip is the Public IP/Domain. If you have chosen port other than 80, write it in this format http://myip:port (http and not https).`Str`
  - `QB_SERVER_PORT`: Port. Default to `80`. `Int`
  - `WEB_PINCODE`: If empty or False means no pincode required while torrent file web selection. Bool
  Qbittorrent NOTE: If your facing ram exceeded issue then set limit for MaxConnecs, decrease AsyncIOThreadsCount in qbittorrent config and set limit of DiskWriteCacheSize to 32.`Int`

  ### Torrent Search

  - `SEARCH_API_LINK`: Search api app link. Get your api from deploying this [repository](https://github.com/Ryuk-me/Torrent-Api-py). `Str`
  - `SEARCH_LIMIT`: Search limit for search api, limit for each site. Default is zero. `Int`
  - `SEARCH_PLUGINS`: List of qBittorrent search plugins (github raw links). Add/Delete plugins as you wish. Main Source: [qBittorrent Search Plugins (Official/Unofficial)](https://github.com/qbittorrent/search-plugins/wiki/Unofficial-search-plugins).`List`

3. **Deploying with Docker**

- Build Docker image:

```
sudo docker build . -t rcmltb 
```

- Run the image:

```
sudo docker run -p 80:80 -p 8080:8080 rcmltb
```

- To stop the container:

```
  sudo docker ps
```

```
  sudo docker stop id
```
- To clear the container:

```
  sudo docker container prune
```

- To delete the images:

```
  sudo docker image prune -a
```

4. **Deploying using docker-compose**

**NOTE**: If you want to use port other than 80 (torrent file selection) or 8080 (rclone serve), change it in docker-compose.yml

- Install docker-compose

```
sudo apt install docker-compose
```

- Build and run Docker image:
```
sudo docker-compose up
```

- After editing files with nano for example (nano start.sh):
```
sudo docker-compose up --build
```

- To stop the image:
```
sudo docker-compose stop
```

- To run the image:
```
sudo docker-compose start

```

</details>

<details>
<summary><b>Generate Database</b> (click to expand)</summary>

## Generate Database

1. Go to `https://mongodb.com/` and sign-up.
2. Create Shared Cluster (Free).
4. Add `username` and `password` for your db and click on `Add my current IP Address`.
6. Click on `Connect`, and then press on `Connect your application`.
7. Choose `Driver` **python** and `version` **3.6 or later**.
8. Copy your `connection string` and replace `<password>` with the password of your user, then press close.
9. Go to `Network Access` tab, click on edit button and finally click `Allow access from anywhere` and confirm.

</details>

<details>
<summary><b>How to create rclone config file</b> (click to expand)</summary>

## How to create rclone config file

**Check this youtube video (not mine, credits to author):** 
<p><a href="https://www.youtube.com/watch?v=Sp9lG_BYlSg"> <img src="https://img.shields.io/badge/See%20Video-black?style=for-the-badge&logo=YouTube" width="160""/></a></p>

**Notes**:
- When you create rclone.conf file add at least two accounts if you want to copy from cloud to cloud. 
- For those on android phone, you can use [RCX app](https://play.google.com/store/apps/details?id=io.github.x0b.rcx&hl=en_IN&gl=US) app to create rclone.conf file. Use "Export rclone config" option in app menu to get config file.
- Rclone supported providers:
  > 1Fichier, Amazon Drive, Amazon S3, Backblaze B2, Box, Ceph, DigitalOcean Spaces, Dreamhost, **Dropbox**,   Enterprise File Fabric, FTP, GetSky, Google Cloud Storage, **Google Drive**, Google Photos, HDFS, HTTP, Hubic, IBM COS S3, Koofr, Mail.ru Cloud, **Mega**, Microsoft Azure Blob Storage, **Microsoft OneDrive**, **Nextcloud**, OVH, OpenDrive, Oracle Cloud Storage, ownCloud, pCloud, premiumize.me, put.io, Scaleway, Seafile, SFTP, **WebDAV**, Yandex Disk, etc. **Check all providers on official site**: [Click here](https://rclone.org/#providers).

</details>

<details>
<summary><b>Getting Google OAuth API credential file and token.pickle</b> (click to expand)</summary>

## Getting Google OAuth API credential file and token.pickle

**NOTES**
- You need OS with a browser.
- Windows users should install python3 and pip. You can find how to install and use them from google.
- You can ONLY open the generated link from `generate_drive_token.py` in local browser.

1. Visit the [Google Cloud Console](https://console.developers.google.com/apis/credentials)
2. Go to the OAuth Consent tab, fill it, and save.
3. Go to the Credentials tab and click Create Credentials -> OAuth Client ID
4. Choose Desktop and Create.
5. Publish your OAuth consent screen App to prevent **token.pickle** from expire
6. Use the download button to download your credentials.
7. Move that file to the root of rclone-tg-bot, and rename it to **credentials.json**
8. Visit [Google API page](https://console.developers.google.com/apis/library)
9. Search for Google Drive Api and enable it
10. Finally, run the script to generate **token.pickle** file for Google Drive:
```
pip3 install google-api-python-client google-auth-httplib2 google-auth-oauthlib
python3 generate_drive_token.py
```

</details>

<details>
<summary><b>Bittorrent Seed & qBittorrent</b> (click to expand)</summary>

## Bittorrent Seed

- Using `-d` argument alone will lead to use global options for aria2c or qbittorrent.

## Qbittorrent

- Global options: `GlobalMaxRatio` and `GlobalMaxSeedingMinutes` in qbittorrent.conf, `-1` means no limit, but you can cancel manually.
  - **NOTE**: Don't change `MaxRatioAction`.

</details>

<details>
<summary><b>Using Service Accounts to avoid user rate limit [For Google Drive Remotes]</b> (click to expand)</summary>

## Using Service Accounts to avoid user rate limit [For Google Drive Remotes]

> For Service Account to work, you must set `USE_SERVICE_ACCOUNTS`= "True" in config file or environment variables.
>**NOTE**: Using Service Accounts is only recommended for Team Drive.

### 1. Generate Service Accounts. [What is Service Account?](https://cloud.google.com/iam/docs/service-accounts)

**Warning**: Abuse of this feature is not the aim of this project and we do **NOT** recommend that you make a lot of projects, just one project and 100 SAs allow you plenty of use, its also possible that over abuse might get your projects banned by Google.

>**NOTE**: If you have created SAs in past from this script, you can also just re download the keys by running:
```
python3 gen_sa_accounts.py --download-keys $PROJECTID
```
>**NOTE:** 1 Service Account can copy around 750 GB a day, 1 project can make 100 Service Accounts so you can copy 75 TB a day.

#### Two methods to create service accounts
Choose one of these methods

##### 1. Create Service Accounts in existed Project (Recommended Method)

- List your projects ids

```
python3 gen_sa_accounts.py --list-projects
```

- Enable services automatically by this command

```
python3 gen_sa_accounts.py --enable-services $PROJECTID
```

- Create Sevice Accounts to current project

```
python3 gen_sa_accounts.py --create-sas $PROJECTID
```

- Download Sevice Accounts as accounts folder

```
python3 gen_sa_accounts.py --download-keys $PROJECTID
```
##### 2. Create Service Accounts in New Project
```
python3 gen_sa_accounts.py --quick-setup 1 --new-only
```
A folder named accounts will be created which will contain keys for the Service Accounts.

### 2. Add Service Accounts

#### Two methods to add service accounts
Choose one of these methods

##### 1. Add Them To Google Group then to Team Drive (Recommended)
- Mount accounts folder

```
cd accounts
```

- Grab emails form all accounts to emails.txt file that would be created in accounts folder
- `For Windows using PowerShell`

```
$emails = Get-ChildItem .\**.json |Get-Content -Raw |ConvertFrom-Json |Select -ExpandProperty client_email >>emails.txt
```

- `For Linux`

```
grep -oPh '"client_email": "\K[^"]+' *.json > emails.txt
```

- Unmount acounts folder

```
cd ..
```
Then add emails from emails.txt to Google Group, after that add this Google Group to your Shared Drive and promote it to manager and delete email.txt file from accounts folder

##### 2. Add Them To Team Drive Directly
- Run:

```
python3 add_to_team_drive.py -d SharedTeamDriveSrcID
```

</details>

<details>
<summary><b>Yt-dlp and Aria2c Authentication Using .netrc File</b> (click to expand)</summary>

## Yt-dlp and Aria2c Authentication Using .netrc File
For using your premium accounts in yt-dlp or for protected Index Links, create .netrc and not netrc, this file will be hidden, so view hidden files to edit it after creation. Use following format on file: 

Format:

```
machine host login username password my_password
```

Example:

```
machine instagram login user.name password mypassword
```

**Instagram Note**: You must login even if you want to download public posts and after first try you must confirm that this was you logged in from different ip(you can confirm from phone app).

**Youtube Note**: For `youtube` authentication use [cookies.txt](https://github.com/ytdl-org/youtube-dl#how-do-i-pass-cookies-to-youtube-dl) file.

Using Aria2c you can also use built in feature from bot with or without username. Here example for index link without username.

```
machine example.workers.dev password index_password
```

Where host is the name of extractor (eg. instagram, Twitch). Multiple accounts of different hosts can be added each separated by a new line.

</details>

---
-----

## Bot Screenshot: 

<img src="./screenshot.png" alt="button menu example">

-----
