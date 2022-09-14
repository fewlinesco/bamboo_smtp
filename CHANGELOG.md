# CHANGELOG

## 4.2.2

- Use punycode for unicode characters in domain name to fix encoding errors ([#198])
- Update Elixir/OTP compatibility matrix for tests ([#217])

[#198]: https://github.com/fewlinesco/bamboo_smtp/pull/198
[#217]: https://github.com/fewlinesco/bamboo_smtp/pull/217

## 4.2.1

- Remove explicit ranch dependency ([#208])

[#208]: https://github.com/fewlinesco/bamboo_smtp/pull/208

## 4.2.0

- Drop testing for OTP ~> 20.3 to align with [gen_smtp minimum otp version of 21](https://github.com/gen-smtp/gen_smtp/blob/99fad81cc3aeb33657ff7598c846c4120c3a480e/rebar.config#L2) ([#205])
- Bump elixir to 1.13.4 and erlang to 24.3.4 ([#205])
- Use `Enum.map_join/3` instead of `Enum.map/2 |> Enum.join/2`  ([#205])
- Dependencies update ([#205]):
  - core:
    - gen_smtp, ~> 1.2.0
  - dev/test:
    - credo, ~> 1.6.1

[#205]: https://github.com/fewlinesco/bamboo_smtp/pull/205

## 4.1.0

- Bump elixir to 1.12.0 and erlang to 24.0 ([#191])
- Add more options for TLS ([#193], [#196])
- Dependencies update ([#195]):
  - core:
    - bamboo, ~> 2.2.0

[#191]: https://github.com/fewlinesco/bamboo_smtp/pull/191
[#193]: https://github.com/fewlinesco/bamboo_smtp/pull/193
[#195]: https://github.com/fewlinesco/bamboo_smtp/pull/195
[#196]: https://github.com/fewlinesco/bamboo_smtp/pull/196

## 4.0.1
- Add support for attachment unicode file names by encoding them using format described in [RFC 2231] ([#183]).
- After bumping dependencies, the project requires([#185], [#187]):
   - core:
      - bamboo, ~> 2.1.0
      - gen_smtp, ~> 1.1.1

   By bumping `gen_smtp` we fix the issue of errors being raised when sending emails after a STARTTLS.

[RFC 2231]: https://tools.ietf.org/html/rfc2231
[#183]: https://github.com/fewlinesco/bamboo_smtp/pull/183
[#185]: https://github.com/fewlinesco/bamboo_smtp/pull/185
[#187]: https://github.com/fewlinesco/bamboo_smtp/pull/187

## 4.0.0

- Change the way the adapter handle errors when emails fail to deliver. instead of raising a `SMTPError` we now return an `{:error, %SMTPError{}}` tuple. This is required to accommodate the breaking changes introduced in `bamboo 2.0`([#177]).
- After bumping dependencies, the project requires([#178]):
   - core:
      - bamboo, ~> 2.0.0
   - dev/test:
      - :credo, ~> 1.5.0
      - excoveralls, ~> 0.14.0

[#177]: https://github.com/fewlinesco/bamboo_smtp/pull/177
[#178]: https://github.com/fewlinesco/bamboo_smtp/pull/178

## 3.1.3 - 2021-02-11

- Update `gen_smtp` dependency from 1.0.1 to 1.1.0 ([#171])
    - This project now requires Erlang/OTP+20

## 3.1.2 - 2021-01-29
- Enable Bamboo_smtp to work in ipv6-only environment. Fix issue([#143]).

[#143]: https://github.com/fewlinesco/bamboo_smtp/issues/143
## 3.1.1 - 2021-01-04
- Bring back Base64 encoding on headers. Fix issue [#162]

[#162]: https://github.com/fewlinesco/bamboo_smtp/pull/162
## 3.1.0 - 2020-11-23

- Fix for using custom config with `response: true` by bumping `bamboo` version to `~> 1.6` ([#150])
- Implement our custom test adapter ([#151])
- Fix CI random failure by attaching FakeGenSMTP Server process to Test supervision tree.([#153])
- Add Content-ID header when needed([#154])
- Base 64 encode the headers only when the content contains non-ASCII characters.([#155])
- Handle `:permanent_failure` exception and re-raising it as a `SMTPError`.([#156])
- After bumping the dependencies, the project requires([#149]):
    - credo `~> 1.4.1`
    - bamboo `~> 1.6`
    - excoveralls `~> 0.13.3`
    - gen_smtp  `~> 1.0.1`

[#149]: https://github.com/fewlinesco/bamboo_smtp/pull/149
[#150]: https://github.com/fewlinesco/bamboo_smtp/pull/150
[#151]: https://github.com/fewlinesco/bamboo_smtp/pull/151
[#153]: https://github.com/fewlinesco/bamboo_smtp/pull/153
[#154]: https://github.com/fewlinesco/bamboo_smtp/pull/154
[#155]: https://github.com/fewlinesco/bamboo_smtp/pull/155
[#156]: https://github.com/fewlinesco/bamboo_smtp/pull/156

## 3.0.0 - 2020-09-10

- Fix eml attachment ([#137]).
- Change text/html part to be submitted with base64 encoding to comply to the MIME Format of Internet Message Bodies specification ([#141]).
- After bumping the dependencies, the project requires elixir 1.7 or higher to run ([#139]).

[#137]: https://github.com/fewlinesco/bamboo_smtp/pull/137
[#141]: https://github.com/fewlinesco/bamboo_smtp/pull/141
[#139]: https://github.com/fewlinesco/bamboo_smtp/pull/139

## 2.1.0 - 2019-10-14

- SMTPAdapter now does not append `Bcc` and `Cc` headers to the body if there is not any provided ([#130]).
- Bump `gen_smtp` version to `~> 0.15.0` ([#129]).
- Bump `ex_doc` version for system version at least equal to `1.7` ([#127]).

[#130]: https://github.com/fewlinesco/bamboo_smtp/pull/130
[#129]: https://github.com/fewlinesco/bamboo_smtp/pull/129
[#127]: https://github.com/fewlinesco/bamboo_smtp/pull/127

## 2.0.0 - 2019-08-27

- SMTPAdapter now returns the SMTP server response ([#122])

**UPGRADE NOTES**

In case you were using the `response: true` option, be aware that you'll now get a tuple as a return value in the form of `{:ok, <raw-smtp-response>}` instead of an atom `:ok`.

[#122]: https://github.com/fewlinesco/bamboo_smtp/pull/122

## 1.7.0 - 2019-05-27

- Update Elixir, OTP and all deps to latest versions available ([#115])
- SMTPAdapter now raise an error when credentials are required by configuration but not provided ([#102])

[#115]: https://github.com/fewlinesco/bamboo_smtp/pull/115
[#102]: https://github.com/fewlinesco/bamboo_smtp/pull/102

## 1.6.0 - 2018-09-10

- Relax bamboo version dependency to allow v1.1.x

[#100]: https://github.com/fewlinesco/bamboo_smtp/pull/100

## 1.5.0 - 2018-06-21

- Bump to Bamboo 1.0.0

[#94]: https://github.com/fewlinesco/bamboo_smtp/pull/94

## 1.5.0-rc.4 - 2018-05-28

- Add authentication option ([#89])

[#89]: https://github.com/fewlinesco/bamboo_smtp/pull/89

## 1.5.0-rc.3 - 2018-04-04

- Add no_mx_lookups option to gen_smtp config ([#82])
- relax Elixir version ([#81])
- Fix failing HexDoc redirection ([#79])

[#79]: https://github.com/fewlinesco/bamboo_smtp/pull/79
[#81]: https://github.com/fewlinesco/bamboo_smtp/pull/81
[#82]: https://github.com/fewlinesco/bamboo_smtp/pull/82

## 1.5.0-rc.2 - 2018-01-05

* Add attachment support ([#35])
* Apply rfc822_encode to headers(FROM, BCC, CC, TO) ([#75])
* Make the hostname (FQDN) configurable ([#74])
* Update Elixir, OTP and all deps to latest versions available ([#69])

[#35]: https://github.com/fewlinesco/bamboo_smtp/pull/35
[#75]: https://github.com/fewlinesco/bamboo_smtp/pull/75
[#74]: https://github.com/fewlinesco/bamboo_smtp/pull/74
[#69]: https://github.com/fewlinesco/bamboo_smtp/pull/69

## 1.5.0-rc.1 - 2017-07-07

* Upgrading bamboo to 1.0.0-rc ([#67])
* Add Hex.pm badge with package version ([#66])
* Add a CONTRIBUTING guide ([#65])
* Create CODE_OF_CONDUCT.md ([#64])

[#67]: https://github.com/fewlinesco/bamboo_smtp/pull/67
[#66]: https://github.com/fewlinesco/bamboo_smtp/pull/66
[#65]: https://github.com/fewlinesco/bamboo_smtp/pull/65
[#64]: https://github.com/fewlinesco/bamboo_smtp/pull/64

## 1.4.0 - 2017-06-15

* Add system env to all configs ([#49])
* Add the raw error tuple when we raise an error ([#51])
* Fix email delivery issue when subject is empty ([#60])

[#49]: https://github.com/fewlinesco/bamboo_smtp/pull/49
[#51]: https://github.com/fewlinesco/bamboo_smtp/pull/51
[#60]: https://github.com/fewlinesco/bamboo_smtp/pull/60

## 1.3.0 - 2017-01-12

* Add test targets for Elixir & OTP ([#45])
* Don't need to enforce username/password ([#37])
* Updated dependencies ([#43])
* Fix for emails going to spam with office365 smtp ([#39])
* Fixed parentheses deprecations for elixir 1.4 ([#41])
* Add some doc badge love with inchCI ([#34])

[#45]: https://github.com/fewlinesco/bamboo_smtp/pull/45
[#37]: https://github.com/fewlinesco/bamboo_smtp/pull/37
[#43]: https://github.com/fewlinesco/bamboo_smtp/pull/43
[#39]: https://github.com/fewlinesco/bamboo_smtp/pull/39
[#41]: https://github.com/fewlinesco/bamboo_smtp/pull/41
[#34]: https://github.com/fewlinesco/bamboo_smtp/pull/34

## 1.2.1 - 2016-08-23

* Fix From/To headers passed to gen_smtp not to be formatted that caused an error with some SMTP cloud providers like Amazon SES ([#31])

[#31]: https://github.com/fewlinesco/bamboo_smtp/pull/31

## 1.2.0 - 2016-08-02

* Fix order of name/email in `format_email` function ([#22])
* Allow username and password configs to be loaded from ENV ([#23])
* Remove Content-ID SMTP header from email parts ([#24])
* Bump to Elixir 1.3.2 ([#26])
* Update to bamboo 0.7.0 ([#27])

[#22]: https://github.com/fewlinesco/bamboo_smtp/pull/22
[#23]: https://github.com/fewlinesco/bamboo_smtp/pull/23
[#24]: https://github.com/fewlinesco/bamboo_smtp/pull/24
[#26]: https://github.com/fewlinesco/bamboo_smtp/pull/26
[#27]: https://github.com/fewlinesco/bamboo_smtp/pull/27

## 1.1.0 - 2016-07-18

### New Additions

* Subject is now encoded to conform to RFC822 ([#15])
* Bump `gen_smtp` to `0.11.0` (from `0.10.0`) ([#13])
* Support Elixir `1.3.0` ([#13])
* Support Erlang `19.0` ([#13])

[#15]: https://github.com/fewlinesco/bamboo_smtp/pull/15
[#13]: https://github.com/fewlinesco/bamboo_smtp/pull/13

## 1.0.0 - 2016-06-14

### New Additions

* We're making it clear that we're using the MIT License ([#9])
* We're introducing a CHANGELOG :clap: ([#12])
* Add an extra newline before body. This should fix the display of HTML content with email readers. ([#6])
* Minor improvements to README ([#4])

[#9]: https://github.com/fewlinesco/bamboo_smtp/pull/9
[#12]: https://github.com/fewlinesco/bamboo_smtp/pull/12
[#6]: https://github.com/fewlinesco/bamboo_smtp/pull/6
[#4]: https://github.com/fewlinesco/bamboo_smtp/pull/4
