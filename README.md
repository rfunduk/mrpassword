# Mr. Password

Mr. Password is a
[1PasswordAnywhere](http://learn.agilebits.com/1Password4/iOS/Tutorials/ios-1pa.html)-like
password vault that uses only the
[Dropbox API](https://www.dropbox.com/developers) as a backend.

Encryption and decryption is handled by
[SJCL](http://bitwiseshiftleft.github.io/sjcl/) and only encrypted data is
ever stored on Dropbox.


## Try It

Here's one hosted on my Dropbox:

[https://tinyurl.com/mrpassword](https://tinyurl.com/mrpassword)

Here's one running on AWS CloudFront:

[https://d3g5t5f7zdns67.cloudfront.net](https://d3g5t5f7zdns67.cloudfront.net)

Hosted on my Dropbox...? With minified assets? Did your eyes just bulge?
Well, the files are hosted on my Dropbox/CloudFront, but you login using Dropbox
OAuth and your data is stored on YOUR Dropbox. Also the app also has a
purge data function you can use if you decide to run away :)

If you're really paranoid though...


## Run your own

Since this project is open-source, you can clone/fork it and look at the code
for yourself and decide if this is a good idea or not. If you do so and decide
it's a good idea, you can run your own version locally or wherever you want (well,
almost, Dropbox requires SSL for OAuth apps except for `localhost`... but you can
self-sign if necessary).

_Running your own and it's broken?_ ->
[Dropbox Datastore API is being deprecated](#migration-from-dropbox-datastore-api)

### Requirements

- Node.js 0.8+ and NPM
- Grunt (`npm install -g grunt-cli`)
- Bower 1.3+ (`npm install -g bower`)
- A Dropbox 'App Folder' [app](https://www.dropbox.com/developers/apps)
- [s3cmd](https://github.com/s3tools/s3cmd) +
  Ruby +
  [aws-sdk](https://github.com/aws/aws-sdk-ruby)
  if deploying to CloudFront


### Setup

Get the repo and run:

    npm install
    bower install

Setup your Dropbox application with `http://localhost:9000/` as a
OAuth2 redirect URI. Make sure it has the 'App Folder' permission.
Also take note of your 'App key'.

### Running the App

    grunt serve --dropboxApiKey APP_KEY

The app should hopefully be running `localhost:9000` momentarily.

You can also put the app key into a file named `.dropboxApiKey` in the
root of the app (alongside this README) and it will be picked up without
the command line option.

### Running the Tests

Run the tests with:

    grunt test

Both `serve` and `test` stay running watching for changes.

### Release Build/Deployment

Finally,

    grunt build --dropboxApiKey APP_KEY

This dumps the final packaged up app into `./dist`. There are
2 deploy scripts in the `deploy` directory.

- `deploy/dropbox` copies the files to
  `~/Dropbox/Public/MrPassword` (which you can then get a public link to)
- `deploy/cloudfront -b BUCKET` uploads the files with `s3cmd` to a bucket you specify
  (and which you'll want a CloudFront distribution pointing at). Expect to wait about
  10 minutes for the new version to be served.


## Migration from Dropbox Datastore API

Early 2015 Dropbox decided to
[deprecate the Datastore API](https://blogs.dropbox.com/developers/2015/04/deprecating-the-sync-and-datastore-apis/)
and that has made this project a bit of a mess temporarily.

If you're just _using_ my
[hosted Mr. Password](https://tinyurl.com/mrpassword), then there
is a migration feature. Otherwise you'll need to check out
[this migrator service](app/scripts/services/migrator.coffee) for some
explanation of how to perform a migration yourself.

Email me if you have trouble :/
