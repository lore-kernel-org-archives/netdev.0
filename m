From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 1/7] can: m_can: fix possible sleep in napi poll
Date: Mon, 03 Nov 2014 18:02:15 +0100
Message-ID: <5457B517.8030805@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="cBAHCjmOJBQujXtb9UUH0cxSPdx7dHgIc"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54645 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbaKCRC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:02:26 -0500
In-Reply-To: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--cBAHCjmOJBQujXtb9UUH0cxSPdx7dHgIc
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hey Dong Aisheng,

the state of the patches are:

1: can/master + stable
2: can/mster
3: can/mster
4: can/master + stable
5: waiting for Oliver's opinion due to the user space change
6: waiting for your input
7: waiting for your input

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--cBAHCjmOJBQujXtb9UUH0cxSPdx7dHgIc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV7UXAAoJECte4hHFiupUMZIP/18GH0PZaGMprHQKsthf5Vnl
n9/fbjB9kUrWk+KoTQK6gb2a4TlJb2+4NkL1qLEjWiKRG8nTu7D1J2hmV18uQ64I
SXe54q0EeC4KsTdE27Aj2+IbkL+xP9SNkdmMc6GuY7QORBZIxbYNlKZFWySRVv+d
mbYloZGjTk1U9c3xoyRNp7CI8ovTPoSjmWCxHmiAeuNhi0YsN65T8wm0a4O+Eicm
kGwmiCDeK0/n/IIgjiISxdhp5liuYErKMm/FH9MxicsVLqgq45qbu6Gcy1XTPdGK
tli8duHbiMhsR1ncV3yf6PYdtDb1gVR0Vs8ovAEDsSFMp6LRezR4Q4e7l8ZmSvTW
Hkx0x+cNybj+51w3GpFcKxFCbte8BfEWfL3XeBMjp9Amr3fu0cc455HV24e65H0v
uequw0dsY3InmUz+gG50L3Qaj2rC54vCRiSo9YKudmw1iPriF+2RLXT0SjFC4lPI
tuUiS4vch5LwghvgN/6o1ce16GLReBfoJRKkuZWV5NR5EOALJlgK8LeaTr0QjqQ3
+iPD+SjwYbyvtBUmXWYNDiOLT5t5ZHH9ZRUA1/0iohPh+gNB56TDx+5kOMxVejZR
+SQQcdm/twPlOeDrOkTUPvPlooAX5d9gEl76bqK/j2aPA4/n2+QGzQbCe19fOZX8
Wew+QSnRhEivWxx4khoz
=+UOf
-----END PGP SIGNATURE-----

--cBAHCjmOJBQujXtb9UUH0cxSPdx7dHgIc--
