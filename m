From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/6] rework d80211 cookie pointer
Date: Sat, 04 Nov 2006 00:10:32 +0100
Message-ID: <1162595432.24673.4.camel@johannes.berg>
References: <20061102223854.692274000@sipsolutions.net>
	 <200611031404.32926.flamingice@sourmilk.net>
	 <19467.82.113.121.16.1162580893.squirrel@secure.sipsolutions.net>
	 <200611031714.55463.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ex7uCe0/qHkDV94kcWeH"
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org,
	Ivo van Doorn <ivdoorn@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Hong Liu <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:13727 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932489AbWKCXL6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 18:11:58 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200611031714.55463.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ex7uCe0/qHkDV94kcWeH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-11-03 at 17:14 -0500, Michael Wu wrote:

> I still prefer obtaining the name of the master interface because well.. =
all=20
> other network drivers prefix their messages with the name of their interf=
ace.
>=20
> The master interface name should be as good as the wiphy index to enumera=
te=20
> attached devices.

I'm trying to get rid of the master interface mostly. I can surely add a
way to get it if we finally decide that we want/need to keep it.

johannes

--=-ex7uCe0/qHkDV94kcWeH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUvMZ6Vg1VMiehFYAQJJiBAAjyIGpKwxM9M0jQcmu3ShXLen38tf/0dx
y9IPOArF9uAoij7qk5FR4L9p7CGcf01NHMsUybaqi2gaB8RsbenG7Rn0P7rT0x7M
LCOs11GbX9thqeAJ7P6qHFiKCF5Bls8E8TprGSyjgZV00HZo537ThF2IbpHm6nUS
0neL1wTSCp4xP+Dwx4l/MTFNZK+MQVabaapeLRgEf3tCWCnTpns0MKo2+FSXjDGH
H2n+N/Zv8uPYQmhe13iX2TgCGmuDaY1DUVgoOmP194uRHhMWE3d1SmuheT3NK2OW
jReS4uvHkImICo79WjF3GlW54Pp0bjoJyf7nhd9dHIQzJKjnxI6PqlycpJqkV5Vl
ERjPpJRql2GODeMF1TI3rUu8/KTUJUZz7/7s5ZArdLH1af4spXWW15ko+6Y6mInG
Mon/sR04KXdY+BtGuo3F8lUJ3fEjsaPFLdvwryiYP0Iy4Kz+eVUc+/Pmmm5adoY/
QfAjgEvxdTZvt4NUcr25hpW7KvVpCevEK+QscU5rfbGoo3jt7Og4b8DXZfDw9yRg
Xe9vLRI1eWHKNu/MiUyygixwF7/+TmK8hH64EirbcTuxWdvIEvOhy+0WMzt15WFq
AbOcChFlyhFShCvwKP4gA/WYUY2VofsOLCilsGS0dSNr0XlZGv6kdi/SBxYkxcBn
4k+roNCmlA0=
=FpmU
-----END PGP SIGNATURE-----

--=-ex7uCe0/qHkDV94kcWeH--

