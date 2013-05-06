From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [GIT] Networking
Date: Mon, 06 May 2013 16:32:46 -0700
Message-ID: <1367883166.16445.13.camel@jtkirshe-mobl>
References: <20130506.170537.2116026617074159336.davem@davemloft.net>
	 <CA+55aFzQ8MzrmPQNPfLFA3nVQVDR3HL+RwcGrAwanJCKRxL2=A@mail.gmail.com>
	 <20130506.190922.168696209163637134.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9+2u/fKRmvtpRVYMB+cl"
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21958 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757621Ab3EFXc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 19:32:56 -0400
In-Reply-To: <20130506.190922.168696209163637134.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9+2u/fKRmvtpRVYMB+cl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-06 at 19:09 -0400, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 6 May 2013 15:57:15 -0700
>=20
> > On Mon, May 6, 2013 at 2:05 PM, David Miller <davem@davemloft.net> wrot=
e:
> >>
> >> Just a small pile of fixes:
> >=20
> > Ok, apparently the e1000e problem didn't get fixed yet. Should I just
> > revert ce43a2168c59 for now, or do we have a fix for that forthcoming
> > shortly?
>=20
> It is coming very shortly.

I am preparing the patch now to send upstream...

--=-9+2u/fKRmvtpRVYMB+cl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRiD2eAAoJEOVv75VaS+3OxNUP/0GbnIVeUtVXFc9IkWNaWihv
U4zRF+bZrp+Wg/bWnTEr4bVElxti1Y1QOxVrXljadBb4vC47wxewtunflHSVnEO3
29KYJoi6y0eZ2fp+vqmZsWpUsfkwfLz092j3i4oN+qsLaGkVpMNzEjSUx071tGzq
DPTKYg8sXPCCjnnHfYXVbrzv0Ukz2MyZO5DQWIrO6DE2VScWZjRLGjs3L5TGMyLG
YCNs4oZlxBUkbctwRMzWKrrr41dLgIfQsUAxdZ6wYjKmWoQkQeoSsBkYONibPDka
zfR75+n5+Mwd8AIE8xljAwCvX3leH3Xb+JTUeGU4u+WULAoOli7W6BIEFnvpEL7c
ZnacZCoLlpKvFlpxldvmhuwLnxVNrQQDEjlI44cM2DzCVhAUP0cIAFPVDGZ4FwQZ
AdpcoGZB6icNPpeskWtD+v7M6Jz+/tLo7MtMd3BhgOB28hXqs2/sGoSJkQdEYxlH
bmxWlj9tYRe5E0nNX7YK2YOckCQ9SMjB/Md0LI2QriKtGjS4a9ZA4qRcZpQLu87c
LsLii1wmHnObgJU98bR4WJyJSbuBIaeh6HVtAczq8jg3HF+tHclowGuKqegM3Poz
uInb6h5JEprTrZN6YqC0dRlGcyv0tXjgP4QjA/7XazYoZjpYlnWlDTwgN6waKdm3
YDgikDTt0AOJeBvlWp6E
=6wVd
-----END PGP SIGNATURE-----

--=-9+2u/fKRmvtpRVYMB+cl--
