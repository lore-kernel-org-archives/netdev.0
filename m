From: Eric Leblond <eric@regit.org>
Subject: [ANNOUNCE] ulogd 2.0.2 release
Date: Sun, 03 Mar 2013 23:49:12 +0100
Message-ID: <1362350952.4930.61.camel@tiger2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-AFkOm2ukfHKxiIIkD0CM"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-AFkOm2ukfHKxiIIkD0CM
Content-Type: multipart/mixed; boundary="=-1OZquf5YgPi3OucUbiFM"


--=-1OZquf5YgPi3OucUbiFM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi!

The Netfilter project proudly presents:

        ulogd 2.0.2

ulogd is a userspace logging daemon for netfilter/iptables related
logging. This includes per-packet logging of security violations,
per-packet logging for accounting, per-flow logging and flexible
user-defined accounting.

See ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!
--=20
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/

--=-1OZquf5YgPi3OucUbiFM
Content-Disposition: attachment; filename="changes-ulogd-2.0.2.txt"
Content-Type: text/plain; name="changes-ulogd-2.0.2.txt"; charset="UTF-8"
Content-Transfer-Encoding: base64

Qm9iIEhvY2tuZXkgKDMpOg0KICAgICAgRml4IHBhcnNpbmcgb2YgaXB2NiBmbG93bGFiZWwgYW5k
IHRjIGZpZWxkcw0KICAgICAgSGFuZGxlIHBvc3RncmVzcWwgc2NoZW1hcyBjb3JyZWN0bHkNCiAg
ICAgIEFkZCBhZGRpdGlvbmFsIGlwNiBoZWFkZXIgZmllbGRzIHRvIGRhdGFiYXNlIHNjcmlwdHMN
Cg0KRXJpYyBMZWJsb25kICgzMik6DQogICAgICBjb25maWd1cmU6IGFkZCBmbGFnIHRvIGRpc2Fi
bGUgTkZBQ0NUIGJ1aWxkDQogICAgICBjb25maWd1cmU6IGFkZCBmbGFnIHRvIGRpc2FibGUgTkZD
VCBidWlsZA0KICAgICAgY29uZmlndXJlOiBhZGQgZmxhZyB0byBkaXNhYmxlIE5GTE9HIGJ1aWxk
DQogICAgICBjb25maWd1cmU6IGRpc3BsYXkgaW5mbyBhYm91dCBidWlsZCBwbHVnaW5zDQogICAg
ICBVc2UgUFJJdTY0IHRvIHByaW50IHVuc2lnbmVkIDY0Yml0IGludA0KICAgICAgWE1MOiBhZGQg
bWlzc2luZyBpbmNsdWRlDQogICAgICBBZGQgbWlzc2luZyB1NjQgZnVuY3Rpb24uDQogICAgICBB
ZGQgR1JBUEhJVEUgb3V0cHV0IG1vZHVsZS4NCiAgICAgIG5mY3Q6IGNhbGwgcmVnaXN0ZXIgY2Fs
bGJhY2sgb24gb3BlbmVkIGhhbmRsZXINCiAgICAgIGFkZHI6IGFkZCBmaWxlIGNvbnRhaW5pbmcg
YWRkciB1dGlsaXR5IGZ1bmN0aW9ucy4NCiAgICAgIG5mY3Q6IGltcGxlbWVudCBzcmMgYW5kIGRz
dCBmaWx0ZXINCiAgICAgIG5mY3Q6IGFkZCBwcm90b2NvbCBmaWx0ZXINCiAgICAgIGFkZHI6IGZp
eCBjb21waWxhdGlvbiB3YXJuaW5nDQogICAgICB1bG9nZDogYWRkIC12IG9wdGlvbiB0byBkaXNw
bGF5IG1lc3NhZ2Ugb24gc3RkZXJyLg0KICAgICAgY29uZjogYWRkIGZsYWcgdG8gYWxsb3cgb3B0
aW9uIHNldHVwIHR1bmluZw0KICAgICAgQWRkIC1sIG9wdGlvbiB0byBzZXQgbG9nIGxldmVsIGZy
b20gY29tbWFuZCBsaW5lDQogICAgICBHZXQgcmlkIG9mIFNWTiB0YWcgaW4gY29tbWVudC4NCiAg
ICAgIEZpeCB3YXJuaW5nIG9uIGZvcm1hdA0KICAgICAgYmFzZTogZml4IHdhcm5pbmcgb24gcG9p
bnRlciBoYW5kbGluZw0KICAgICAgZ3JhcGhpdGU6IGZpeCB3YXJuaW5nIGFib3V0IGdudSBleHRl
bnNpb24gdXNhZ2UNCiAgICAgIEFkZCBUQUdTIHRvIC5naXRpZ25vcmUNCiAgICAgIEZpeCBtYWtl
IGRpc3RjaGVjaw0KICAgICAgZ3JhcGhpdGU6IGZpeCBjcmFzaCBvbiBpMzg2DQogICAgICBVcGRh
dGUgVE9ETy4NCiAgICAgIFN1cHByZXNzIGRlYWQgRklYTUUuDQogICAgICBVc2UgYWNjZXNzIHRv
IGVuc3VyZSByZWFkYWJpbGl0eSBvZiBjb25maWcgZ2lsZQ0KICAgICAgRml4IHR5cG8gaW4gY29t
bWVudHMuDQogICAgICBBZGQgaGFuZGxpbmcgb2YgdG9vIGxvbmcgbGluZSBhbmQgYXJndW1lbnRz
Lg0KICAgICAgbG9nZW11OiByZXR1cm4gZXJyb3IgaWYgY29uZmlndXJhdGlvbiBpcyBpbnZhbGlk
Lg0KICAgICAgVXBkYXRlIG1hbiBwYWdlLg0KICAgICAgVXBkYXRlIFJFQURNRQ0KICAgICAgUHJl
cGFyZSByZWxlYXNlIG51bWJlciB0byAyLjAuMg0KDQpHdXN0YXZvIFphY2FyaWFzICgxKToNCiAg
ICAgIGF1dG9jb25mL3Vsb2dkOiBmaXggYnJva2VuIGxpYnBjYXAgQU1fQ09ORElUSU9OQUwNCg0K
SmFuIEVuZ2VsaGFyZHQgKDQpOg0KICAgICAgYnVpbGQ6IHJlc29sdmUgYXV0b21ha2UtMS4xMiB3
YXJuaW5ncw0KICAgICAgYnVpbGQ6IHJlc29sdmUgY29tcGlsZSBlcnJvciBkdWUgdG8gbWlzc2lu
ZyBuZmFjY3QgQ1BQRkxBR1MNCiAgICAgIGJ1aWxkOiBhdm9pZCBwZXItdGFyZ2V0IENGTEFHUw0K
ICAgICAgYnVpbGQ6IG1vdmUgcmVtYWluaW5nIHByZXByb2Nlc3NvciBmbGFncyBpbnRvIENQUEZM
QUdTDQoNCg==


--=-1OZquf5YgPi3OucUbiFM--

--=-AFkOm2ukfHKxiIIkD0CM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEABECAAYFAlEz02gACgkQnxA7CdMWjzJvBQCfZJWF5jzKtGoBdF8NmbiTvuCS
5KEAn3XH1J33pen3wYo0gpbKryzZOwdU
=VV9+
-----END PGP SIGNATURE-----

--=-AFkOm2ukfHKxiIIkD0CM--

