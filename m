From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 1/1] net: phylib: remove the length limitation of mii
 bus id
Date: Tue, 20 Mar 2012 08:50:59 +0100
Message-ID: <20120320075059.GA3849@pengutronix.de>
References: <1332217679-3703-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TB36FDmn/VVEgNH/"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42275 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472Ab2CTHvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 03:51:01 -0400
Content-Disposition: inline
In-Reply-To: <1332217679-3703-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Aisheng,

> So changed to remove the bus id length limitation, a lot of handwork.

You might want to try 'coccinelle' [1] next time. This is a tool exactly for
such kind of work. Already some basic knowledge can help you for a
number of tasks.

Regards,

   Wolfram

[1] http://en.wikipedia.org/wiki/Coccinelle_%28software%29

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--TB36FDmn/VVEgNH/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk9oNuMACgkQD27XaX1/VRvAMQCdFedF2bnIx04zEuzkDEkZEW8T
V34AoIOx7Lexc/rUkqdmKIBF1trvRta2
=qftQ
-----END PGP SIGNATURE-----

--TB36FDmn/VVEgNH/--
