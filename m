From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] stmmac: re-add IFF_UNICAST_FLT for dwmac1000
Date: Wed, 04 Apr 2012 09:33:21 +0200
Message-ID: <4F7BF941.1020009@pengutronix.de>
References: <1333475057-3752-1-git-send-email-mkl@pengutronix.de> <4F7BF165.6060106@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig40F529C098E0912D1320EC20"
Cc: rayagond@vayavyalabs.com, netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35157 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab2DDIOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 04:14:35 -0400
In-Reply-To: <4F7BF165.6060106@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig40F529C098E0912D1320EC20
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 04/04/2012 08:59 AM, Giuseppe CAVALLARO wrote:
> On 4/3/2012 7:44 PM, Marc Kleine-Budde wrote:
>> In commit (bfab27a stmmac: add the experimental PCI support) the
              ^^^^^^^
>=20
> I get another patch associated to this commit:
>=20
> git show db8857b
           ^^^^^^^

Copy paste problem on your side?

> commit db8857bf5bd888d763e1984f9449d0b824b39ee1
> Author: Florian Fainelli <florian@openwrt.org>
> Date:   Mon Jan 9 23:59:20 2012 +0000
>=20
>     stmmac: use an unique MDIO bus name.
>=20
>     Signed-off-by: Florian Fainelli <florian@openwrt.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
>=20
> maybe, the commit should be:
>=20
> git-show bfab27a14
           ^^^^^^^^^

Yes, as I've written in my commit message.

> commit bfab27a146ed4d722c6d399f844f955f29cd2b81
> Author: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date:   Wed Dec 21 03:58:19 2011 +0000
>=20
>     stmmac: add the experimental PCI support
>=20
>=20
>> IFF_UNICAST_FLT flag has been removed from the stmmac_mac_device_setup=
()
>> function. This patch re-adds the flag.
>=20
> Yes this flag was removed by this PCI patch.
> So it makes sense to re-add it!
>=20
>> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
>=20
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Tnx.


Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig40F529C098E0912D1320EC20
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk98AuAACgkQjTAFq1RaXHMUtgCgkWFLXPrfDutE7lExFDES4vK2
nAQAn1xLtkZt6U2tJg3pB1cS8u2PdezJ
=/NXO
-----END PGP SIGNATURE-----

--------------enig40F529C098E0912D1320EC20--
