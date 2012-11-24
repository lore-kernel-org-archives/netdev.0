From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: sched: enable CAN Identifier to be build into kernel
Date: Sat, 24 Nov 2012 13:22:34 +0100
Message-ID: <50B0BC0A.1050506@pengutronix.de>
References: <1353667497-25676-1-git-send-email-mkl@pengutronix.de> <20121123.142258.816355331172102352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig50E8DDFA211A744F6E4FA658"
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58929 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab2KXMWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Nov 2012 07:22:40 -0500
In-Reply-To: <20121123.142258.816355331172102352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig50E8DDFA211A744F6E4FA658
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/23/2012 08:22 PM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Fri, 23 Nov 2012 11:44:57 +0100
>=20
>> This patch makes it possible to build the CAN Identifier into the kern=
el, even
>> if the CAN support is build as a module.
>>
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>=20
> Why is this so critical that you're asking me to merge this into
> the 'net' tree mere days before Linus makes a release?

Sorry my fault. I intended post that patch against net-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig50E8DDFA211A744F6E4FA658
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCwvAoACgkQjTAFq1RaXHML7ACeJ+W+ECYoX6ZDWgHX2OudEjJc
MFEAn3hQZP8SFlocUNn1J2GDJ1AIZQHp
=DDXc
-----END PGP SIGNATURE-----

--------------enig50E8DDFA211A744F6E4FA658--
