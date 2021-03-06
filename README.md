# telegram-publications-downloader
Download scientific publications from Telegram

Original project is [auino/telegram-publications-downloader](https://github.com/auino/telegram-publications-downloader).

This program allows you to set up a Telegram bot to download PDF files of scientific academic research publications from HTML URLs passed as input.

### Program information ###

This program is written in bash scripting language.

The program is a fork of [topkecleon/telegram-bot-bash](https://github.com/topkecleon/telegram-bot-bash), making use of [dominictarr/JSON.sh](https://github.com/dominictarr/JSON.sh).

The bot is able to interpret only messages sent during the execution of the program.
If a message is sent while the program is not running, it is ignored by the bot, hence lost.

### Installation ###

 1. Create a new Telegram bot by contacting [@BotFather](http://telegram.me/botfather) and following [official Telegram instructions](https://core.telegram.org/bots#botfather)
 2. Clone the repository on your server:

    ```
    git clone https://github.com/auino/telegram-publications-downloader.git
    ```

 3. Enter the just created directory:

    ```
    cd telegram-publications-downloader
    ```

 4. Configure the `publicationsbot.sh` file accordingly to your needs (see [Configuration section](https://github.com/auino/telegram-publications-downloader#configuration) for more information)
 5. Run the bot:

    ```
    bash publicationsbot.sh
    ```

### Configuration ###

First of all, if you're not familiar with it, consult [official Telegram Bot API](https://core.telegram.org/bots).

The `publicationsbot.sh` program supports configuration of the following parameters:
 * `TOKEN` identifies the Telegram token of your bot
 * `OPENBOT` identifies if the bot is able to reply to anyone (`OPENBOT=1`) or not (`OPENBOT=0`, default and suggested feature, see [Disclaimer section](https://github.com/auino/telegram-publications-downloader#dislaimer))
 * `ALLOWED_CHATIDS` identifies the array of chat identifiers of allowed clients (ignored if `OPENBOT=1`); a good value is for instance `ALLOWED_CHATIDS=("01234" "12345")`

### Supported services ###

Currently, supported services are the following ones:
 * [ScienceDirect](http://sciencedirect.com)
 * [IEEExplore](http://ieeexplore.ieee.org)

Note that in order to get resources, the program has to run on a host with access to the documents.

### Accepted commands ###

The bot accepts the following commands:
 * `/start`, used when a new chat is instantiated
 * `/help`, returning help information
 * `/id`, returning the chat identifier of the user sending the message
 * `/get <html_url>` to get the PDF file from a given HTML address (this is the only command applying the specified filters described in [Configuration section](https://github.com/auino/telegram-publications-downloader#configuration), if any)

### Available Bots ###

An [apposite wiki page](https://github.com/auino/telegram-publications-downloader/wiki/Available-Bots) enlisting all available bots is available.
[Contact me](https://github.com/auino/telegram-publications-downloader#contacts) to insert your bot into the wiki.

### Dislaimer ###

Using `OPENBOT=1` is not recommended, since it would make anyone able to access copyrighted content.
Instead, it is suggested to limit this access and make the bot able to reply to a specific (and very limited) number of users.
Also, terms of service of the involved services should be analyzed to evaluate the possibility to use the bot on that services.

I'm not responsible of any illecit use of the program, released for educational purposes.

### Contacts ###

You can find me on Twitter as [@auino](https://twitter.com/auino).
