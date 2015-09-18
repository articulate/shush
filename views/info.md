# WHAT IS SHUSH?

Shush is the easiest way to send sensitive information over the internet securely.

Shush encrypts your message, and the message self-destructs once it’s read. It’s like SnapchatTM for plain-text data.

Use Shush to share passwords, keys, tokens, and other private data.

## HOW TO SEND SECURE MESSAGES

1. Type your message.

2. Choose when it’ll self-destruct—either when it’s first viewed or at a specific time.
![Destruct](/images/demo1.png)

3. Mark the notification box if you want to receive an email when your message is read.
![Notify](/images/demo2.png)

4. Click Save to create a secure link.

5. Send the secure link to the recipient.
![Share](/images/demo3.png)

## HOW SHUSH ENCRYPTS AND DESTROYS MESSAGES

Your message is [RSA-encrypted](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29) during transmission to our servers with [SHA-1](https://en.wikipedia.org/wiki/SHA-1) over [HTTPS/TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security).

When your message reaches our servers, it’s re-encrypted with [XSalsa20](https://en.wikipedia.org/wiki/Salsa20)[Poly1305](https://en.wikipedia.org/wiki/Poly1305-AES) from the [NaCl](http://nacl.cr.yp.to/valid.html) cryptography library.

Your message is stored as a short-lived item in a database and is permanently purged when it’s first read or at the time you specified. (An unread message will be automatically destroyed after one week.)

We don’t log your secret message on our servers.

As an added security precaution, you can sign your message with [PGP encryption](https://en.wikipedia.org/wiki/Pretty_Good_Privacy). We like PGP because [keybase.io](https://keybase.io/) makes it so easy to verify. For even stronger security, you can also encrypt your message before you Shush it.

## MEET THE AUTHORS

- [Adam Ochonicki](https://github.com/fromonesrc)
- [Luke van der Hoeven](https://github.com/plukevdh)

