From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 16:02:02 +0100
Message-ID: <4F0DA46A.6030802@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com> <4F0B7421.6050203@pengutronix.de> <4F0C0552.5080504@grandegger.com> <4F0C2F4A.20500@essax.com> <4F0D4FBA.1080108@essax.com> <4F0D58AE.7070601@pengutronix.de> <4F0D9FC2.2080204@essax.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig3B4CC25FABCEFA1DB366AF93"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40824 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757105Ab2AKPCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 10:02:16 -0500
In-Reply-To: <4F0D9FC2.2080204@essax.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig3B4CC25FABCEFA1DB366AF93
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/11/2012 03:42 PM, Wolfgang Zarre wrote:
> Thanks, also for the additional hints.

You're welcome.

> It might be that I let this patch for now until clarified if we
> should remove or not.

Yes, the just prepare the spinlock patch.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig3B4CC25FABCEFA1DB366AF93
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8NpG0ACgkQjTAFq1RaXHMW4gCgjtgbHJr2bZfwzsnDHF9ha6Nz
Zb8An1NFPkXO+fZPDCz0ueGL1JkubalG
=d5az
-----END PGP SIGNATURE-----

--------------enig3B4CC25FABCEFA1DB366AF93--
