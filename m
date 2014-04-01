From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [patch 00/12] can: c_can: Fix a series of serious bugs and improve
 the performance
Date: Tue, 01 Apr 2014 23:29:39 +0200
Message-ID: <533B2FC3.80300@pengutronix.de>
References: <20140318171007.528610837@linutronix.de> <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de> <533A742F.4090703@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="IkOFxdI3osvLMbH3K2bLQJlFGe8wV0pUE"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58594 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbaDAV3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 17:29:49 -0400
In-Reply-To: <533A742F.4090703@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--IkOFxdI3osvLMbH3K2bLQJlFGe8wV0pUE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 04/01/2014 10:09 AM, Marc Kleine-Budde wrote:
>> What's the state of this series?
>=20
> I'll apply your patches today.

I've applied all patches of this series (with some with minor tweaks of
the subject and/or commit message) to the can tree and skipped the
non-series "can: c_can: Reduce interrupt load by 50%".

Thanks.
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--IkOFxdI3osvLMbH3K2bLQJlFGe8wV0pUE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlM7L8MACgkQjTAFq1RaXHPEqACfbQ6/53LYb7yI29Xox0VAdWn/
I84An3QqJYNoK3q0ttMrHoGPYlA7uKsq
=phoy
-----END PGP SIGNATURE-----

--IkOFxdI3osvLMbH3K2bLQJlFGe8wV0pUE--
