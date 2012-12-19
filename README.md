# Micklem Lab site

## Getting started

The CMS that powers the site is developed in [Node.js](http://nodejs.org/), download the tarball and install it if not present:

```bash
$ ./configure
$ make
$ sudo make install
```

The CMS uses [MongoDB 2](http://www.mongodb.org/display/DOCS/Quickstart) as a backend database; to install and start it up:

```bash
$ sudo apt-get install mongodb
$ sudo mongod
```

Install the dependencies of this "app" which is `blad` and then whatever packages you will be using in your site code; use `package.json` to define those then run:

```bash
$ npm install -d
```

Define the config for your site in `config.json`:

```json
{
    "mongodb": "use process.env.DATABASE_URL instead",
    "browserid": {
        "provider": "https://browserid.org/verify",
        "salt":     "use process.env.API_SALT instead",
        "users": [
            "radek.stepan@gmail.com",
            "jelena121@gmail.com",
            "g.micklem@gen.cam.ac.uk"
        ]
    }
}
```

<dl>
    <dt>mongodb</dt>
    <dd>A uri to a MongoDB database</dd>
    <dt>browserid.provider</dt>
    <dd>A BrowserID provider, the default is Persona.org by Mozilla</dd>
    <dt>browserid.salt</dt>
    <dd>A salt used to hash credentials so that an API key can be generated and used by the Chaplin admin. Do not leave it to default unless you know what you are doing!</dd>
    <dt>browserid.users</dt>
    <dd>An array of email addresses of people that should have access to the backend admin. If they have not created an account with the BrowserID provider, they will be offered a chance to do so on their first login to the site.</dd>
</dl>

You will have noticed that the `mongodb` and `browserid.salt` values are not provided. If you are deploying to [ukraine](https://github.com/radekstepan/ukraine) cloud, set these as follows (from within this directory):

```bash
$ chernobyl env <ukraine_ip> . DATABASE_URL=<mongo_uri>
$ chernobyl env <ukraine_ip> . API_SALT=<salt>
```

Finally start the service, take note that if you wish to start it on a specific port, pass it in as the `process.env.PORT ` variable:

```bash
$ node start.js
```

If you need to define your custom page types and styles (you do), follow the guide associated with the [blað](https://github.com/radekstepan/blad) CMS project page.

## Database backup

Two helpful functions have been exposed to let you export/import pages of your CMS. Call them like so:

```bash
$ node export.js
$ node import.js
```

**Be aware that the import wipes the database clean first!**