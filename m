From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [RFC] PCMCIA patches for 2.6.34
Date: Wed, 6 Jan 2010 15:03:32 +0100
Message-ID: <20100106140332.GA5299@pengutronix.de>
References: <20100106114531.GA29913@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
To: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37602 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932165Ab0AFODd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 09:03:33 -0500
Content-Disposition: inline
In-Reply-To: <20100106114531.GA29913@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dominik,

> here are some patches relating to the PCMCIA subsystem, and intended for
> 2.6.34. I'm interested in your input to this patch series. They'll be
> sent to the PCMCIA list shortly, with CC to other lists if deemed

Looks interesting, I will pull your master(?)-branch this evening and give =
it a
test. Any hints on what to try/look for especially? Suspend/Resume seems one
candidate next to the usual "I'll try a bunch of cards"...

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktEmDQACgkQD27XaX1/VRv0lQCgkT9UIU+bFHdItrIAijhOa/AN
iiIAnAgw0RB0iKXZyFhM6EQCoj7sHFkw
=hjqS
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
