From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 11:26:29 -0800
Message-ID: <1415993189.2478.0.camel@jtkirshe-mobl>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-mPGjXDaG6lvL1v0DvvjU"
Cc: netdev@vger.kernel.org, linux.nics@intel.com
To: "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59243 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965598AbaKNT0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 14:26:47 -0500
In-Reply-To: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-mPGjXDaG6lvL1v0DvvjU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-14 at 14:16 -0500, Martin K. Petersen wrote:
>=20
> Attempt to look up the MAC address in Open Firmware on systems that
> support it. If the "local-mac-address" property is not valid resort to
> using the IDPROM value.
>=20
> Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

Thanks Martin, I will add your patch to my queue.

--=-mPGjXDaG6lvL1v0DvvjU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUZldlAAoJEOVv75VaS+3OmoMP/A6buGc2cCYv5BAADRdCpwnf
rhUnVSGyJYjMyVM8K7V2lJ1r9hxVis46eTZ5KlBGaQQ2ECLYJBhcpJcUr0rwcTo6
COCB6sXhGIUj8/SxNllm3dXXarFjRQDDOhKiBKbtEzpCmNEuhCiQHBqW5d/qBd6g
PjEgDxV1OQjSZ/Yo40u2Ue4LCDRCuwqLVLwDFIOhJnXet3GeSAENJRpcOxRib0pU
cRFzgnh2H4E+o8XvGlqpU8hIcXN/qWY3m4f5m9Vgh06iMoqvZ3yrHRrNxbSQGkp6
PYBrRp+lgdNEq8B1X75DMSFWHqfZLmj2VL4LS9KSEJTudP/Ig3yasm77nI50zA0Q
gVy7+KpATH8PHEIqyiFU/2vGJKPy0z6E73LFI7FgdrOQxHSWHlEaH7STk5caJpH7
L/0qpLjQFXJ4nQt+SOERYxeYSYFe1bwuMC0RN7QbWIp27POCOt343E39QXyUwPhu
UnEgjb7Lvgul9z9Ii1fnZbqfNDyVqX855m9HbRBepaHg/gRsgDnvqVs1+PwTJdIe
mWWwoXWgUtp+j4KJWgP/bdpiTOeXXMiiwGnu4VJFQVdCCCjwD2SI9QdR0mLpCVNb
JdYvhVk0V5oaA9GWkrazyoSUzphaS6znnoDC+yq1i98JaqoceAB4gKX3+ZhUsXue
ZbWtPwkgFoztL363nOGv
=wuoe
-----END PGP SIGNATURE-----

--=-mPGjXDaG6lvL1v0DvvjU--
