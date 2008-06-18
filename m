From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Bug 451804] New: kernel: KERNEL: assertion (flags & MSG_PEEK)
	failed at net/ipv4/tcp.c (1354)
Date: Wed, 18 Jun 2008 12:06:44 +0200
Message-ID: <1213783604.1312.4.camel@johannes.berg>
References: <20080617144056.GA19275@codemonkey.org.uk>
	 <20080617.223555.226018311.davem@davemloft.net>
	 (sfid-20080618_073601_309997_A9751720)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-OGqx8/vz4iEkoenMpYwD"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:44881 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbYFRKHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:07:36 -0400
In-Reply-To: <20080617.223555.226018311.davem@davemloft.net> (sfid-20080618_073601_309997_A9751720)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OGqx8/vz4iEkoenMpYwD
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-06-17 at 22:35 -0700, David Miller wrote:
> From: Dave Jones <davej@codemonkey.org.uk>
> Date: Tue, 17 Jun 2008 10:40:56 -0400
>=20
> > This one been reported yet ?
>=20
> Looks to be an ath5k specific problem based upon other
> reports I was able to find.
>=20
> For example, have a look at the "Transfers stall with ath5k
> on compat-wireless drivers" thread on the ath5k-devel list:
>=20
> http://kerneltrap.org/mailarchive/linux-ath5k-devel/2008/6/4/2028874

Maybe that's also just a variation of the header clone bug? ath5k also
needs sw crypto.

johannes

--=-OGqx8/vz4iEkoenMpYwD
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIWN4wAAoJEKVg1VMiehFYzmcP/1lOUGkI0j8uzfCNaUijhkZG
3KUfpK8wa7VNYyihG+p9n8pF0nfc1vKk2zDmr9AwwPJap9ewUytW/Fh2VzX9rAL2
mi78fguGD9tcXZcTYg7rn9pr66kJyF6uxpYDZqgRzTK4ATfy5HcWR6cszG+2BzV3
hD2ffq5irsrOgNV9RVm81jDM9ydGYwx1o8FM6iGCA+JwES2UzsrurH4oP04yffpP
ozX+Nd0SZxOttagApYzX/Y91uTMd+fkP10ggMxbBQr/4mUo4UjOsrhZkYN0sQVtG
gWLs7GVQS6sF9gddWHS9/lhJ6JaM6qzN5euDxS4HlmzkFms+55N/hLGQASLb9gHb
1eHNnd8vV1Hli2d8FiZUS17BSTIv71HSGEjZfaU+xvQ3Gp6iG0d/IHeQH7zZxoVA
IKHcxGFQRjxN1bwtQhoI0STuWszueQbDcKwE/qLcqhS95pS9RaFfCt6w9JcwRJlV
SI2mDUAtVgc8ELpaQSFBDuXjdmF99+EfJgnzUTSZTygd8GrjdRYmiJqUqLRLFjZB
wcjWAfXC4LO6Rm2MyrnSP1Fiph52sQd7xvg9JHncDbrqp5bnkR3sxigae7/M9NZq
LOE2C3a6M4EbGLZvnKXPDhbX9aausWiB8JRci6gU3f2Rxy4oQn1XjQLLuWi3biyS
35N9zos3+XsrcYu2s0P8
=7TBL
-----END PGP SIGNATURE-----

--=-OGqx8/vz4iEkoenMpYwD--

