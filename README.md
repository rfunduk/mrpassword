# Mr. Password

Mr. Password is a
[1PasswordAnywhere](http://learn.agilebits.com/1Password4/iOS/Tutorials/ios-1pa.html)-like
password vault that uses only the
[Dropbox Datastore API](https://www.dropbox.com/developers/datastore) as a backend.

Encryption and decryption is handled by
[SJCL](http://bitwiseshiftleft.github.io/sjcl/) and only encrypted data is
ever stored on Dropbox.


## Try It

Here's one hosted on my Dropbox:

[https://tinyurl.com/mrpassword](https://tinyurl.com/mrpassword)

Here's one running on AWS CloudFront:

[https://d3g5t5f7zdns67.cloudfront.net](https://d3g5t5f7zdns67.cloudfront.net)

Hosted on my Dropbox...? Did your eyes just bulge? Don't be worried,
the files are hosted on my Dropbox (or in an S3 bucket of mine for the CloudFront link),
but you login using your own Dropbox account and data will be stored there in
your own personal datastore. The app also has a purge data function you can use
if you decide to run away :)


## Run your own

Since this project is open-source, you can clone/fork it and look at the code
for yourself and decide if this is a good idea or not. If you do so and decide
it's a good idea, you can run your own version locally or wherever you want (well,
almost, Dropbox requires SSL for OAuth apps except for `localhost`).

### Requirements

- Node.js 0.8+ and NPM
- Bower 1.3+ (`npm install -g bower`)


### Setup
Get the repo and run:

    npm install
    bower install

### Running the App

    grunt serve

The app should hopefully be running `localhost:9000` momentarily.

### Running the Tests

Run the tests with:

    grunt test

Both `serve` and `test` stay running watching for changes.

### Release Build/Deployment

Finally,

    grunt build

This dumps the final packaged up app into `./dist`. There are
2 deploy scripts in the `deploy` directory.

- `deploy/dropbox` copies the files to
  `~/Dropbox/Public/MrPassword` (which you can then get a public link to)
- `deploy/cloudfront` uploads the files with `s3cmd` to a bucket you specify
  and sets the 'root object' to `index.html`. You might want to edit
  `Gruntfile.js` and enable the `rev:deploy` task so that `index.html` becomes
  `SHA.index.html`, as this will help with cache busting CloudFront
  (if you go this route, expect to wait about 10 minutes for the new version
  to be served).
