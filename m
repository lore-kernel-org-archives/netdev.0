From: Eric Leblond <eric@regit.org>
Subject: [ANNOUNCE] ulogd 2.0.4 release
Date: Tue, 15 Apr 2014 09:56:30 +0200
Message-ID: <1397548590.18685.2.camel@ice-age2.regit.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-+yV0VtG9BtiV74IsmQeo"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+yV0VtG9BtiV74IsmQeo
Content-Type: multipart/mixed; boundary="=-ctLcdn+BcGosGCuQvMR1"


--=-ctLcdn+BcGosGCuQvMR1
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable

Hi!

The Netfilter project proudly presents:

        ulogd 2.0.4

ulogd is a userspace logging daemon for netfilter/iptables related
logging. This includes per-packet logging of security violations,
per-packet logging for accounting, per-flow logging and flexible
user-defined accounting.

ulogd 2.0.4 features a new JSON output plugin allowing easy integration
with log management systems.

See ChangeLog that comes attached to this email for more details.

Thanks to Gustavo Zacarias and Ken-ichirou Matsuzawa for their
contributions to this release of ulogd.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!
--=20
Eric Leblond <eric@regit.org>


--=-ctLcdn+BcGosGCuQvMR1
Content-Disposition: attachment; filename="changes-ulogd-2.0.4.txt"
Content-Type: text/plain; name="changes-ulogd-2.0.4.txt"; charset="ISO-8859-15"
Content-Transfer-Encoding: base64

RXJpYyBMZWJsb25kICgxMyk6DQogICAgICBuYWNjdDogZml4IGZvcm1hdCB3YXJuaW5nDQogICAg
ICB1dGlsOiBmaXggd2FybmluZyBvbiBmb3JtYXQgc3RyaW5nDQogICAgICBkYjogc2V0IHJpbmcg
ZGVmYXVsdCBzaXplIHRvIDANCiAgICAgIGRiOiBjYW5jZWwgaW5qZWN0aW9uIHRocmVhZCB3aGVu
IHRlcm1pbmF0aW5nDQogICAgICBkYjogZG9uJ3QgbG9vc2Ugb25lIHBhY2tldCBvbiByZWNvbm5l
Y3QNCiAgICAgIHN0b3JlIENvbW1vbiBJbmZvcm1hdGlvbiBNb2RlbCBuYW1lIGluIHVsb2dkIGtl
eQ0KICAgICAganNvbjogaW50cm9kdWNlIG5ldyBKU09OIG91dHB1dCBwbHVnaW4NCiAgICAgIHVs
b2dkOiBhdm9pZCBwb3RlbnRpYWwgZG91YmxlIHByaW50IG9mIG1lc3NhZ2UNCiAgICAgIHVsb2dk
OiBhZGQgY2FycmlhZ2UgcmV0dXJuIGFzIHNlcGFyYXRvcg0KICAgICAgbmZjdDogdXNlIHN0YXJ0
IHRpbWVzdGFtcCBpZiBwcm92aWRlZA0KICAgICAganNvbjogdXNlIHBhY2tldCB0aW1lc3RhbXAg
aWYgYXZhaWxhYmxlDQogICAgICBwcmludHBrdDogb29iLnRpbWUuc2VjIHdhcyBub3QgdXNlZA0K
ICAgICAgU2V0IHJlbGVhc2UgbnVtYmVyIHRvIDIuMC40Lg0KDQpHdXN0YXZvIFphY2FyaWFzICgx
KToNCiAgICAgIHVsb2dkOiB1c2UgQUNfU0VBUkNIX0xJQlMgZm9yIGxpYnB0aHJlYWQNCg0KS2Vu
LWljaGlyb3UgTUFUU1VaQVdBICgxKToNCiAgICAgIHVsb2dkOiBmaXggbG9nbGV2ZWwgaGFuZGxp
bmcNCg0K


--=-ctLcdn+BcGosGCuQvMR1--

--=-+yV0VtG9BtiV74IsmQeo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iD8DBQBTTOYunxA7CdMWjzIRAvQDAJ9p+yOqVwwPu5UjjNdLKEKHfD+iCwCcC2OJ
Os8To3iFFoz5PZAexbDqRVk=
=BPox
-----END PGP SIGNATURE-----

--=-+yV0VtG9BtiV74IsmQeo--

