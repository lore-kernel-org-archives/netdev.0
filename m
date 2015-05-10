From: Eric Leblond <eric@regit.org>
Subject: [ANNOUNCE] ulogd 2.0.5 release
Date: Sun, 10 May 2015 21:40:35 +0200
Message-ID: <1431286835.21627.3.camel@regit.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-j3PVfRiGTQbNzXmJyRnT"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: Netfilter Devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-j3PVfRiGTQbNzXmJyRnT
Content-Type: multipart/mixed; boundary="=-cee/EmCTJ/vU7XRMMarL"


--=-cee/EmCTJ/vU7XRMMarL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi!

The Netfilter project proudly presents:

	ulogd 2.0.5

This release fixes build on recent systems where Linux headers don't
contain anymore ULOG header files. It also fixes JSON output on big
endian system.

A big thanks to Jimmy Jones, Vincent Bernat for their contributions. See
ChangeLog that comes attached to this email for more details.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!
--=20
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/

--=-cee/EmCTJ/vU7XRMMarL
Content-Disposition: attachment; filename="changes-ulogd-2.0.5.txt"
Content-Type: text/plain; name="changes-ulogd-2.0.5.txt"; charset="UTF-8"
Content-Transfer-Encoding: base64

RXJpYyBMZWJsb25kICg0KToKICAgICAgZ2l0aWdub3JlOiBhZGQgbWFucGFnZQogICAgICBTZXQg
cmVsZWFzZSBudW1iZXIgdG8gMi4wLjUuCiAgICAgIEFkZCBmbGFnIHRvIGRpc2FibGUgVUxPRyBp
bnB1dCBwbHVnaW4KICAgICAgQWRkIG1pc3NpbmcgZW5hYmxldmFsIHRvIGNvbmZpZ3VyZQoKSmlt
bXkgSm9uZXMgKDEpOgogICAgICBGaXggSlNPTiBvdXRwdXQgb24gYmlnIGVuZGlhbiBzeXN0ZW1z
CgpQYWJsbyBOZWlyYSBBeXVzbyAoMSk6CiAgICAgIGluY2x1ZGU6IGtlZXAgYSBjb3B5IG9mIGxp
bnV4L25ldGZpbHRlcl9pcHY0L2lwdF9VTE9HLmgKClZpbmNlbnQgQmVybmF0ICgxKToKICAgICAg
Z2l0aWdub3JlOiBpZ25vcmUgZ2VuZXJhdGVkIGRvY3VtZW50YXRpb24KCg==


--=-cee/EmCTJ/vU7XRMMarL--

--=-j3PVfRiGTQbNzXmJyRnT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlVPtDgACgkQnxA7CdMWjzJF3QCcCXab7R7495m2aDNKwcTtGr2u
7BEAnR2l8irddUK20I/eMKYEMm7Hleox
=d1Pp
-----END PGP SIGNATURE-----

--=-j3PVfRiGTQbNzXmJyRnT--

