From: Markus Pargmann <mpa@pengutronix.de>
Subject: Broadcom BCM54610 Linux support
Date: Tue, 7 Jul 2015 12:58:24 +0200
Message-ID: <20150707105824.GK4552@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZG5hGh9V5E9QzVHS"
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45704 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756407AbbGGK63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:58:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZG5hGh9V5E9QzVHS
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

I found the phy driver which supports broadcom BCM5461. But I am not
sure if this driver does support BCM54610 in fiber mode as well? Or if
there are any open datasheets which could be used to write a mainline
driver for it. I would appretiate any information about this.

Thanks,

Markus

--=20
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |

--ZG5hGh9V5E9QzVHS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVm7DQAAoJEEpcgKtcEGQQj4wQAK75CyU04n5i/plqpyh1T3Vp
MSA7xDb4yZ+9neLeFygWq/HNF2q+22atKeQ9JRZp35onagf0qAbXQeiakNzglPQr
GMFacEI6kn6YFRyzWeJIGrG5Wh/OUS31ingoPfBBGKxmruQBaLYTpoWnYVH/6oeQ
zUn/yE8JTlNQXU2ilFqzL/FjAUC2qiEq6fOX0M6H3UWwR5VdroWVx4CR3Fmk8si+
j2jgt8Ox/gf1tz003JMTjO1/fAzDFNFwI+AbhcFr93BnXJ619aowrwEw7UZ/g+if
3D7TreAS/WA0kpnPjlQIuc5Gn3Wc2sIlJuPvGKkS7/9aM7RjqL1kTBPq6EZB8zvI
Kbc2W5pxNXPfJaHNMVVNOn9nevIt9JKqytjsSuwLC4VscikrRcNrNDpIONMha/3c
pAdz5OfEmGwouO6/24BKz3Crhyqj+nYadE/BnHp+kMz4K/x66rYfGRKcXhTW0E6w
/DodoNkCOXyA99fakzbhnVN31mszxu+goHKBx1RDNoPOlHm4fwPPK56hlRyxM4Vt
VPQbtCGUdesEB39rsi1/eQuGrBgC/BasPE8iffGj1QQquafB9sausJPDIfYVYY3d
K43IQMxTfYtKjco24EQ2lIwS+tQP/KiOUiP2QxzaRVnjk1hCMLQpky+xXFT97Clf
gSMyK3XzlXALFMaz2qZp
=HS1a
-----END PGP SIGNATURE-----

--ZG5hGh9V5E9QzVHS--
