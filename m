From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 23:55:04 +0200
Message-ID: <1184363704.3928.6.camel@johannes.berg>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
	 <1184320965.30334.2.camel@johannes.berg>  <20070713110534.GF5328@kernel.dk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bl/Piu0PLx7BIK7M0IFX"
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35032 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544AbXGMV4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 17:56:46 -0400
In-Reply-To: <20070713110534.GF5328@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-bl/Piu0PLx7BIK7M0IFX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-07-13 at 13:05 +0200, Jens Axboe wrote:
> On Fri, Jul 13 2007, Johannes Berg wrote:
> > On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> > > I'm seeing TCP connection stalls with current git, and a bisect found=
 the=20
> > > following as a possible cause:
> >=20
> > I'm also seeing stalls with synergy.
>=20
> Please try the below.

Thanks. I already had your mail in the other part of the thread marked,
I'll give it a try on Monday or Tuesday; I'm away from the setup where I
always see the problem right now.

johannes

--=-bl/Piu0PLx7BIK7M0IFX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGl/S3/ETPhpq3jKURAinXAKCdwMRnfzAzCXdsgc6CNvB7oX+UXwCglnJi
JRyG5khMj0GJ84QwcF6ftvk=
=UmeE
-----END PGP SIGNATURE-----

--=-bl/Piu0PLx7BIK7M0IFX--

