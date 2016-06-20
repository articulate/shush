# Shush

## Secure, self-destructing, note-sharing service

https://blogs.articulate.com/life/shush-a-new-approach-to-secret-sharing/

![](http://cl.ly/image/2R2v3e0k142f/seacrests.jpg)

_Your Seacrests are safe with us_

## To Run

1. Create a `.env` file at the root level of the app containing, at a minimum,

```
SESSION_SECRET=supersecrest
PORT=9393
RACK_ENV=development
```

Before deploying to production, you'll also want to set

```
SHUSH_HOST=<the fqdn the app is running from>
NOTIFY_FROM=<the email address read notifications will come from>
REDIS_URL

# IF not relying on IAM roles for SES
AWS_ACCESS_KEY_ID
AWS_REGION
AWS_SECRET_ACCESS_KEY
```

2. Using [Docker Compose](https://www.docker.com/products/docker-compose), run: `docker-compose build`

3. Once this is built, you can run locally with `docker-compose up` (add the `-d` flag to run daemonized).

4. (Optional) Run `docker-machine ip <your docker machine name here>` to get the IP of your running app. Alias this in your `/etc/hosts` file to `docker`. Otherwise, you will want to set the `SHUSH_HOST` env var to match your docker machine IP.

5. (Optional) Set the `NOTIFY_FROM` env var to set the reply-to address for notification emails.

5. Hit the app in your browser and :boom: enjoy!

## About

This is a thing to help send your seacrests about the interwebs without fear of being discovered. It's like Snapchat, but for plaintext data.

Shush is great for quickly and securely sharing passwords, keys, tokens, or any other bits of sensitive data you want to share with someone. The notes you create here will automatically self destruct when viewed or at a time you specify when creating the note (10 minutes, 1 hour, 1 day, 1 week). We think it's pretty handy and hope you do too.

## Details

We [SHA-2](https://en.wikipedia.org/wiki/SHA-2) [RSA encrypt](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29) all data transmitted to our servers over HTTPS/TLS. Once your secret securely reaches our servers, it is re-encrypted with [XSalsa20](https://en.wikipedia.org/wiki/Salsa20)[Poly1305](https://en.wikipedia.org/wiki/Poly1305-AES) from the [NaCl](http://nacl.cr.yp.to/valid.html) cryptography library. The note is stored as a short-lived item in an [in-memory database](http://redis.io/), being permanently purged on first read or at the time you specified when creating the note. We do not log your secret data on the server. As an added security precaution we recommend signing your messages using PGP or another mechanism (we like PGP because [keybase.io](https://keybase.io) makes it so easy to verify). For even stronger security we recommend encrypting your message before you give it to us. But that's entirely up to you. All unread notes will be automatically destroyed after one week.

## Authors

- [Adam Ochonicki](https://github.com/fromonesrc)
- [Luke van der Hoeven](https://github.com/plukevdh)
