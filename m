From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Wed, 01 Jun 2011 12:53:18 -0700
Message-ID: <1306957998.3076.18.camel@jtkirshe-MOBL1>
References: <1306956602.32125.28.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-6bly30bwX0zpRACjuJvF"
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43839 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355Ab1FATxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 15:53:20 -0400
In-Reply-To: <1306956602.32125.28.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6bly30bwX0zpRACjuJvF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-01 at 12:30 -0700, Joe Perches wrote:
> Does anyone still think moving files around in drivers/net
> would be sensible and a suitable candidate for inclusion
> in 3.1?
>=20
> Here's what Jeffrey proposed:
> http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>=20
> Here's what I proposed before that.
> http://www.spinics.net/lists/netdev/msg149717.html
>=20
> I agree with Jan that the current 10/100, 1000, 10000 speed
> selections mechanisms are less than ideal.
>=20
> Perhaps it'd be worthwhile to remove that speed distinction.
>=20

I am over 90% done with the work and have been trying to finish up the
patches so that I could get them out as an RFC here in the next week.

I did remove the current 10/100, 1000, 10000 speed selections in my
current patchset.

--=-6bly30bwX0zpRACjuJvF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN5piuAAoJECTsCADr/EWUmqsH/3+GxC8KesT8xs5R7OhWoxP+
2SuOqgdO6DneWacbcRpI6qr4K17kcTS8X/uaeF7r7+Ul43soYZPFPWFf/n6uju/V
T1Tju3YWrNPOh7yP1sa2ZRGJdpiedXn+sPNcyeYZBi3NenQKN+4b1VAR/QgriUT8
GFEo3ORkbicoapecS73jCdNgDSftlTeOZagiHUuwg+WuumPhC5q25fS9r0EcDbL5
hqg2ku1ijgHEQUM9UX3+zdq1xhxEkT/QHgCByA1UM10u7KFudalIQ7eS9HGYCh+c
lqpD4rNKEvRvtK1VwjMHAmx68M4mfBBhNm0fG1CN2d8lL6f2r04gXP2i8RR8yw8=
=Rn6q
-----END PGP SIGNATURE-----

--=-6bly30bwX0zpRACjuJvF--

