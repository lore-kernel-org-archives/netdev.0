From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] e1000: Neaten
 e1000_config_dsp_after_link_change
Date: Thu, 09 Feb 2012 20:04:54 -0800
Message-ID: <1328846694.2761.26.camel@jtkirshe-mobl>
References: <1328846511.1936.4.camel@joe2Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ht6MyvRXUh9NMSNmGbK1"
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2764 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758229Ab2BJEE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 23:04:56 -0500
In-Reply-To: <1328846511.1936.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ht6MyvRXUh9NMSNmGbK1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-02-09 at 20:01 -0800, Joe Perches wrote:
> Separate a complicated bit of e1000_config_dsp_after_link_change
> into a new static function e1000_1000Mb_check_cable_length.
>=20
> Reduces indentation and adds a bit of clarity.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c |  156
> +++++++++++++--------------
>  1 files changed, 73 insertions(+), 83 deletions(-)=20

Thank Joe, I have added the patch to my queue.

--=-ht6MyvRXUh9NMSNmGbK1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPNJdmAAoJEOVv75VaS+3OWagP/iIO50/wCXamUszSSTD3WDpz
3ORx+2nYQa+C+GSBvBMg72kVIjNCW5wss/GWwesaYJdBGIKHr6qgGJNcUgL+vb/q
TYp4NXrsv23B9uYdcwVbn3Vp3voh2i39xp2gak9LcnPgSBeiJAWw7myvmRn097WF
siunhMzLAHiJpfyTYZK5n0yWU7MBa2ZIgq0XqrQabq1I52X8c+KayQytlmO53JWb
hq3yEi26zLltITRMJrUCwSVrqwviklJ2N83rH3rmixFp/wJXQioWT7ZwkPSrO5kr
jB1XgDRJwf6ALu5am7us0fyRkf2okHxNCp0cLG3PP7SdJfeHgrysmorq7FZeqQeK
p0+oUr5olbiD0Hj0xEHbmM4u/re0IMzX8pi4XZ/Y72Trm8i9aUXasJgZM7Q+x+L4
RKu6i1tEglb3GK+Dw8oMSIOxIrN55vZIeSKXQYCog7HySahW1M73CKlwLYZTRZtL
xxjhCoHSs7x/m9SQnKPDjXXAVWHWvXrd77s1aTdL89QZyPqnJKf4w8m9Rg3uXNYm
Gww5Qnbbr2fyXWvrFd2xFZB7nNDF1sIk8Kunm67UDrKW/ESrCZKqcn8c4xZ6TbrT
fDA5wSttbpbJ11BQ3Y+Z24USoDNiKXNtAPA20kweHGXgdRTNTZPMEJMODdrEaC6g
AcXpAWbZRhOdo2XjNvOY
=7kaD
-----END PGP SIGNATURE-----

--=-ht6MyvRXUh9NMSNmGbK1--
