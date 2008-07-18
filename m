From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Fri, 18 Jul 2008 11:26:43 +0200
Message-ID: <200807181126.48246.laurentp@cse-semaphore.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <200806261321.24338.laurentp@cse-semaphore.com> <20080626175523.54728d07@vitb.ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2242542.1L37p45jF7";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:13517 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753880AbYGRJ0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 05:26:53 -0400
In-Reply-To: <20080626175523.54728d07@vitb.ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2242542.1L37p45jF7
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 26 June 2008, Vitaly Bordug wrote:
> On Thu, 26 Jun 2008 13:21:23 +0200
> Laurent Pinchart <laurentp@cse-semaphore.com> wrote:
>=20
> > > There should be no dependencies. When the OF GPIO support is not
> > > selected linux/of_gpio.h will define of_get_gpio() as a stub, so the
> > > fs_enet driver will fall back to the legacy binding. =20
> >=20
> > Have we reached a consensus on which tree the patch should go to ?
> I think it should go through powerpc tree, not seeing too much
> netdev-generic stuff in here. If noone will object, Kumar will pick it up=
 I
> guess...=20

Kumar, could you pick it up ? I'd like to see this in 2.6.27.

Best regards,

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart2242542.1L37p45jF7
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEYEABECAAYFAkiAYdgACgkQ8y9gWxC9vpcylQCeP9v241eeSA2tmrCd3KgEg4kz
TNcAoN3ygIWKOz/WUpLCSpXsSG6ZXgUL
=Lmbt
-----END PGP SIGNATURE-----

--nextPart2242542.1L37p45jF7--
