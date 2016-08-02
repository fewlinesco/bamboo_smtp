# CHANGELOG

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
