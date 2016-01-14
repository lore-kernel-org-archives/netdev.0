From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [requrest for stable 4.1.y inclution] Fix for CVE-2015-7799
Date: Thu, 14 Jan 2016 13:18:49 +0000
Message-ID: <1452777529.7020.67.camel@decadent.org.uk>
References: <56978CFE.1010703@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-GBwe6rpIpyKWwBwZw3Vs"
Cc: netdev@vger.kernel.org
To: Yuki Machida <machida.yuki@jp.fujitsu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41410 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750828AbcANNTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 08:19:11 -0500
In-Reply-To: <56978CFE.1010703@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GBwe6rpIpyKWwBwZw3Vs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-01-14 at 20:56 +0900, Yuki Machida wrote:
> This patch is the fix for CVE-2015-7799
> Upstream commit 4ab42d78e37a294ac7bc56901d563c642e03c4ae
>=20
> Stable 3.2.y has included this patch in v3.2.75.
> https://cdn.kernel.org/pub/linux/kernel/v3.x/ChangeLog-3.2.75
>=20
> Please include in this patch to stable 4.1.y.

Commit 0baa57d8dc32db78369d8b5176ef56c5e2e18ab3 is also needed as
preparation.

Ben.

--=20
Ben Hutchings
Anthony's Law of Force: Don't force it, get a larger hammer.

--=-GBwe6rpIpyKWwBwZw3Vs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVpegOee/yOyVhhEJAQqQCw//cOqVjfXQBhggxSs0NzPLXkD6F1uk/QFO
SNKap2PHlxma2B8ub5fEqbcqz9O7iH37jjUoPfOtAbT46DJ7Rf28Jk+UO3XhuN29
cvnNTLGFICprOXvUB1dpnfkkRDWMTdm8b0h0Gd6WDb5R+Glp1REOYNTveT0fa1UU
7wQ8aeba/JF14RsrnOUk9z27ji27EQVAoFZ8DGI/NY1c0JL9SYQnulvPahwB3HUp
pOkdaP0wwGCedoN3Pgb++X0DV8rNNpH2UA/GrDzZpGwV3zimvffas3ttaLYW87Jq
66ZJuw35H22Rxh8jgnOyfws9TSdRX8TegUpuhYcmQNQAFS6tsz0b0pWDwLNRVjJ1
aTyjoyscq9CGRcIJMiVUY2W/ZnCeUh4PHL1Yp8Htbs52vtE6ZZnN0C9KMTFe/SPm
DYw4di9GrlbfvqK4CDhoy7F1F6yJ29E7LXta8XP2ysszV8chO+e2JpUraq9SmauQ
0F0WPewPs3djChl1wCafPCNa47CLWj8HEt9bNxmhUEX221nQkjT2iFUXeVXH8/t3
jPSvLJNLwVpKtgOnyIEGzVZHsGIkNkfPEhaIb++g3GDP+bceisIt++n5hx/OEF4u
nChkMRHMdPhR9nrBrkvgh/KQSgtodVOhXpBwzq/MBeIKOiHQADgOH411qyQYs2SI
Pm6qQE7/WM0=
=jObA
-----END PGP SIGNATURE-----

--=-GBwe6rpIpyKWwBwZw3Vs--
