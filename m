From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] rfkill: document removal of notifier chain
Date: Wed, 08 Apr 2009 17:21:30 +0200
Message-ID: <1239204090.16477.1.camel@johannes.local>
References: <49DCA88E.6060400@tuffmail.co.uk>
	 (sfid-20090408_153722_059382_FB44D658)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-A8tAStuHIgonzXwXWBoQ"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ivo van Doorn <IvDoorn@gmail.com>, netdev@vger.kernel.org
To: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46382 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934485AbZDHRBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 13:01:12 -0400
In-Reply-To: <49DCA88E.6060400@tuffmail.co.uk> (sfid-20090408_153722_059382_FB44D658)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-A8tAStuHIgonzXwXWBoQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-04-08 at 14:37 +0100, Alan Jenkins wrote:
> This unused feature was removed in 4dec9b807be757780ca3611a959ac22c28d292=
a7
>=20
> Signed-off-by: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> ---
>=20
> p.s. Is netdev really the right list for rfkill (as listed in MAINTAINERS=
)?
>      I have a feeling most development happens on linux-wireless.

You're right, and I'm rewriting rfkill and part of that is changing the
maintainer to myself and the list to linux-wireless.

I have no problems with this patch, but note that I'm rewriting that
entire file as well so it's not really necessary in the long run -- now
that -rc1 is out I can hopefully convert all in-tree rfkill stuff and
get the patch in.

johannes


--=-A8tAStuHIgonzXwXWBoQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJ3MD3AAoJEKVg1VMiehFYM20P/ijeb7uniPa1/F43DcuKD9ME
dyR5SQBEvb1l0srS4K95fn768JNYdqeVpsRCz3n9JPhF/e97D3RpYaEV+qML85rS
qwBzorujcv8p8YpLR+QtylTdjbMOvwbABAiSQEKb9PH/5MihlLTmbxqNoWlsVmzR
JVU50wXiSvZ6D6l1tK3kkjDqNwZYyYd7Wy6Vti4K/5c2/oYV9K6UV2QiqKiIJ7kQ
lUKkjKSzgVlVqHO79PUmtRI/E7PegfRnUiCDjULNELM5VtCW4sAlU+dsK0QdDpdx
nqlHftAPoKY1KRS4x2VCga9gVQsIBk/+l3us8R5TvLO/USJlk2SleLpNQYFmJMS1
CwQtymv6czM9SjaWQVrozanSTROPOlmg7AdUN+FeAuyePCJi0bSvYhXSMyVrxCQU
XsBJNGOc4XdA2dnwfrg6G08usvXti9QKcTdfQjAO9hcILWqSlHhnOkwxLj4V7LqW
hzh5qZWBmboEvK52bRu4rFE+wyD9h4OZy2LCZXjgC0aPiNFFly2fxFR9iF6yslJ5
SCIx96Kb3Od5zyrsy5zvyfCJw5CKXFwog2DeJkzzmdWyHH+THbXW1H8YrgFSarfU
NMsrjMTYqCiuBWzDBiK0zGy+8lVBfneEAz6EY66QRDYfHAa16lc7EjYRu9qXBfC3
1Y1gN+G10oCYlVaTFkOt
=zMms
-----END PGP SIGNATURE-----

--=-A8tAStuHIgonzXwXWBoQ--

