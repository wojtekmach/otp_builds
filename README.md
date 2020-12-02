A proof-of-concept that uses GitHub Actions to respond to release events, pre-compile OTP, and attach it to the given release.

See example release: <https://github.com/wojtekmach/otp_builds/releases/tag/OTP-23.1.4>.

## Notes

* To test it on macOS, run:

      curl -LO https://github.com/wojtekmach/otp_builds/releases/download/OTP-23.1.4/OTP-23.1.4-macOS.tar.gz && \
        tar xzf OTP-23.1.4-macOS.tar.gz && \
        cd OTP-23.1.4 && ./Install -sasl $PWD && ./bin/erl -version

  It's important to download the archive via the command line and not through browser because othwerwise the archive is put onder quarantine (see `xattr -l PATH`) and the extracted bianries won't be executable because they're not signed.

* When creating a new release, make sure the tag matches the one from https://github.com/erlang/otp, so create e.g.: <https://github.com/wojtekmach/otp_builds/releases/new?tag=OTP-23.1.3>.

* macOS ships with libressl but without header files and it's recommended to bring your own SSL library anyway so we statically link it. See: <https://rentzsch.tumblr.com/post/33696323211/wherein-i-write-apples-technote-about-openssl-on>.

* The [workflow file](.github/workflows/main.yaml) can be easily customized to run on more macOS versions or even Linux. On the latter, remember to change the workflow file to use `/usr` as the SSL directory instead of homebrew one.

* GitHub Actions `macos-10.15` is currently using old OpenSSL but it will be switched to 1.1.1 on 2020-12-14, see: <https://github.com/actions/virtual-environments/issues/2089>.

* Currently files look like `OTP-23.1.4-macOS.tar.gz`, should they be like: `OTP-23.1.4-darwin-x86_64.tar.gz`?
