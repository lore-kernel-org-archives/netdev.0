From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 0/11] Update support for MPC512x
Date: Tue, 26 Jan 2010 13:16:21 +0100
Message-ID: <20100126121621.GA4431@pengutronix.de>
References: <1263932653-3634-1-git-send-email-agust@denx.de> <20100120112232.GD5041@pengutronix.de> <20100126090633.74257b1a@wker>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HcAYCG3uE/tztfnV"
Cc: John Rigby <jcrigby@gmail.com>, dzu@denx.de,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	linuxppc-dev@ozlabs.org, linux-mtd@lists.infradead.org,
	linux-i2c@vger.kernel.org, rtc-linux@googlegroups.com,
	Dan Williams <dan.j.williams@intel.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47282 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229Ab0AZMQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 07:16:29 -0500
Content-Disposition: inline
In-Reply-To: <20100126090633.74257b1a@wker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HcAYCG3uE/tztfnV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> No, I don't have a git tree for this now, sorry.

No problem, I set one up at:

	git://git.pengutronix.de/git/wsa/linux-2.6.git

It is based on 2.6.33-rc5 and contains the newest patches for FEC and I2C. =
(I
will pick up the patches as they show up on the lists, so this tree will be
rebased!)

This tree includes all MPC5121-patches and the two USB-patches from Anton. I
haven't actually tested them yet, but they all applied cleanly, at least.
Testing will come soon...

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--HcAYCG3uE/tztfnV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkte3RUACgkQD27XaX1/VRueqACgzELpbWZLj3PaSUx0F9SZp7FX
PbQAnjyi1ZRptgosw9GUBZlgJzczKcNh
=/8WQ
-----END PGP SIGNATURE-----

--HcAYCG3uE/tztfnV--
