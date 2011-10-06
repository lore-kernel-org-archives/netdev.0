From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 6 Oct 2011 16:09:04 +0200
Message-ID: <20111006140904.GD1974@pengutronix.de>
References: <4E8C78E8.3010605@hartkopp.net>
 <20111005155127.GB13794@pengutronix.de>
 <4E8C8175.2040202@hartkopp.net>
 <4E8D528D.8020607@hartkopp.net>
 <4E8D7065.8040905@grandegger.com>
 <20111006092456.GB1974@pengutronix.de>
 <4E8DB4C9.30109@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="48TaNjbzBVislYPb"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60684 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758253Ab1JFOJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 10:09:07 -0400
Content-Disposition: inline
In-Reply-To: <4E8DB4C9.30109@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--48TaNjbzBVislYPb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> Ah, i did not get this from your code example
>=20
> 	if (can_dlc & 1)
> 		*payload =3D in_be16() & mask;

Sorry, I thought it was obvious that I was using pseudo_code here :)

> ... it would be nice if e.g. Wolfgang could send his patch after some tes=
ting,
> as i currently don't have access to my MPC5200 hardware here.

What about Andre?

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--48TaNjbzBVislYPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk6NtoAACgkQD27XaX1/VRudMQCeMX3yMc+Au65BwKDocJNXtG/d
RxgAoJnY/p0csrHa0o/7SpnQdtEhEOQn
=Sxlb
-----END PGP SIGNATURE-----

--48TaNjbzBVislYPb--
