# blað example site

An example site powered by [blað](https://github.com/radekstepan/blad) CMS.

## Getting started

Make sure the [MongoDB](http://www.mongodb.org/display/DOCS/Quickstart) database has been installed and is started.

```bash
$ sudo apt-get install mongodb
$ sudo mongod
```

Install the dependencies of this "app" which is `blad` and then whatever packages you will be using in your site code; use `package.json` to define those then run:

```bash
$ npm install -d
```

Define the config for your site:

```json
{
    "mongodb": "mongodb://localhost:27017/documents",
    "browserid": {
        "provider": "https://browserid.org/verify",
        "salt":     "Q?RAf!CAkus?ejuCruKu",
        "users": [
            "radek.stepan@gmail.com",
            "jelena121@gmail.com",
            "g.micklem@gen.cam.ac.uk"
        ]
    }
}
```

<dl>
    <dt>`mongodb`</dt>
    <dd>Ipsum</dd>
</dl>