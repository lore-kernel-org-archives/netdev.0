From: Eric Leblond <eric@regit.org>
Subject: [ANNOUNCE] ulogd 2.0.3 release
Date: Fri, 22 Nov 2013 14:04:20 +0100
Message-ID: <1385125460.5297.132.camel@tiger2>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-weiKAKPefre4hNoE1v2g"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-weiKAKPefre4hNoE1v2g
Content-Type: multipart/mixed; boundary="=-B8Deui24OajgKTqJD+wr"


--=-B8Deui24OajgKTqJD+wr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi!

The Netfilter project proudly presents:

        ulogd 2.0.3

ulogd is a userspace logging daemon for netfilter/iptables related
logging. This includes per-packet logging of security violations,
per-packet logging for accounting, per-flow logging and flexible
user-defined accounting.

ulogd 2.0.3 features major improvements in the database output:
      * Optional backlog system to avoid event loss in case of database
        downtime
      * Optional running mode where acquisition is made in one thread
        and queries to databases are made in separate threads=20

See ChangeLog that comes attached to this email for more details.

Thanks to Chris Boot, Ilya Tumaykin, Ulrich Weber and Victor Julien for
their contributions to this release of ulogd.

You can download it from:

http://www.netfilter.org/projects/ulogd/downloads.html
ftp://ftp.netfilter.org/pub/ulogd/

Have fun!
--=20
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/

--=-B8Deui24OajgKTqJD+wr
Content-Disposition: attachment; filename="changes-ulogd-2.0.3.txt"
Content-Type: text/plain; name="changes-ulogd-2.0.3.txt"; charset="UTF-8"
Content-Transfer-Encoding: base64

Q2hyaXMgQm9vdCAoMyk6DQogICAgICB1bG9nZDogUGVyZm9ybSBuaWNlKCkgYmVmb3JlIGdpdmlu
ZyB1cCByb290DQogICAgICB1bG9nZDogSW1wbGVtZW50IFBJRCBmaWxlIHdyaXRpbmcNCiAgICAg
IHVsb2dkOiB1bG9nZF9pbnBwa3RfTkZMT0c6IGNsb3NlIG5mbG9nIGhhbmRsZSBhZnRlciB1bmJp
bmRpbmcNCg0KRXJpYyBMZWJsb25kICgxNyk6DQogICAgICBuZmN0OiB1c2UgdGltZXN0YW1wIG9m
IGNvbm50cmFjayBvYmplY3QuDQogICAgICB1bG9nZDogY2hhbmdlIHZlcmJvc2l0eSBvZiBhIG1l
c3NhZ2UNCiAgICAgIHVsb2dkOiBkaXNwbGF5IHN0YWNrIGR1cmluZyBjb25maWd1cmF0aW9uDQog
ICAgICBwb3N0Z3Jlc3FsOiBhZGQgc2FuaXR5IGNoZWNraW5nDQogICAgICBteXNxbDogYWRkIHNh
bml0eSBjaGVja2luZw0KICAgICAgc3FsaXRlMzogYWRkIHNhbml0eSBjaGVja2luZw0KICAgICAg
ZGI6IHN0b3JlIGRhdGEgaW4gbWVtb3J5IGR1cmluZyBkYXRhYmFzZSBkb3dudGltZQ0KICAgICAg
ZGI6IHN1cHByZXNzIGZpZWxkIGluIGRiIHN0cnVjdHVyZQ0KICAgICAgZGI6IHVzZSBvZmZzZXQg
aW5zdGVhZCBvZiBkaXJlY3QgcG9pbnRlci4NCiAgICAgIGRiOiBhZGQgcmluZyBidWZmZXIgZm9y
IERCIHF1ZXJ5DQogICAgICBkYjogZGlzYWJsZSBTSUdIVVAgaWYgcmluZyBidWZmZXIgaXMgdXNl
ZC4NCiAgICAgIGRiOiBkYiByaW5nIGhhcyBwcmVjZWRlbmNlIG92ZXIgYmFja2xvZy4NCiAgICAg
IEltcHJvdmUgcGlkIGZpbGUgaGFuZGxpbmcuDQogICAgICBwZ3NxbDogYWRkIHZhciB0byBzcGVj
aWZ5IGFyYml0cmFyeSBjb25uIHBhcmFtcw0KICAgICAgdWxvZ2QuY29uZjogYWRkIG1pc3Npbmcg
cXVvdGUuDQogICAgICB1bG9nZDogdXNlIGRhZW1vbigpIGZ1bmN0aW9uDQogICAgICBTZXQgcmVs
ZWFzZSBudW1iZXIgdG8gMi4wLjMuDQoNCklseWEgVHVtYXlraW4gKDEpOg0KICAgICAgRml4IGF1
dG9tYWdpYyBzdXBwb3J0IG9mIGRiaSwgcGNhcCBhbmQgc3FsaXRlMw0KDQpQYWJsbyBOZWlyYSBB
eXVzbyAoMik6DQogICAgICB1bG9nZDogY2xvc2UgbG9nZmlsZSBkZXNjcmlwdGlvbiBpbiB0aGUg
ZXhpdCBwYXRoIG9mIHBhcmVudCBwcm9jZXNzDQogICAgICBSZXZlcnQgInVsb2dkOiBjbG9zZSBs
b2dmaWxlIGRlc2NyaXB0aW9uIGluIHRoZSBleGl0IHBhdGggb2YgcGFyZW50IHByb2Nlc3MiDQoN
ClVscmljaCBXZWJlciAoMSk6DQogICAgICBuZmN0OiBtYWtlIE5GQ1QgcGFja2V0IGNvdW50ZXIv
bGVuZ3RoIDY0IGJpdA0KDQpWaWN0b3IgSnVsaWVuICgxKToNCiAgICAgIEV4ZWMgbGlibW5sIGNv
bmZpZyBjaGVjayBvbmx5IGlmIG5mYWNjdCBpcyBlbmFibGVkDQoNCg==


--=-B8Deui24OajgKTqJD+wr--

--=-weiKAKPefre4hNoE1v2g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iEYEABECAAYFAlKPVlQACgkQnxA7CdMWjzLQhwCcCVYKQ/3ojfUMzvT/RdBr1/lz
7U4AnRtYAoqFTrBWijPYRl8jFHhJ1u7C
=napV
-----END PGP SIGNATURE-----

--=-weiKAKPefre4hNoE1v2g--

