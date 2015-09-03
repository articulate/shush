## We made a thing

This is a thing to help send your secrests about the interwebs without fear of being discovered. It's like Snapchat, but for plaintext data.

![secrest](https://camo.githubusercontent.com/ad1159fe56dc2ff04791f2716d21abfa8a7a03c9/687474703a2f2f636c2e6c792f696d6167652f325232763365306b313432662f7365616372657374732e6a7067)

Shush is great for quickly and securely sharing passwords, keys, tokens, or any other bits of sensitive data you want to share with someone. The notes you create here will automatically self destruct when viewed or at a time you specify when creating the note (10 minutes, 1 hour, 1 day, 1 week). Anyway, we think it's pretty handy and hope you do too.

### Details

We [SHA-1](https://en.wikipedia.org/wiki/SHA-1) [RSA encrypt](https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29) all data transmitted to our servers over [HTTPS/TLS](https://en.wikipedia.org/wiki/Transport_Layer_Security). Once your secret securely reaches our servers, it is re-encrypted with [XSalsa20](https://en.wikipedia.org/wiki/Salsa20)[Poly1305](https://en.wikipedia.org/wiki/Poly1305-AES) from the [NaCl](http://nacl.cr.yp.to/valid.html) cryptography library. The note is stored as a short-lived item in a database, being permanently purged on first read or at the time you specified when creating the note. We do not log your secret data on the server. As an added security precaution we recommend signing your messages using PGP or another mechanism (we like PGP because [keybase.io](https://keybase.io) makes it so easy to verify). For even stronger security we recommend encrypting your message before you give it to us. But that's entirely up to you. All unread notes will be automatically destroyed after one week.

### Authors

- [Adam Ochonicki](https://github.com/fromonesrc)
- [Luke van der Hoeven](https://github.com/plukevdh)
