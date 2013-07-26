From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH] e100: dump small buffers via %*phC
Date: Fri, 26 Jul 2013 04:12:34 -0700
Message-ID: <1374837154.32309.1.camel@jtkirshe-mobl>
References: <1374751459-17994-1-git-send-email-andriy.shevchenko@linux.intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lO4JS5fuXHR+VlS/JBi0"
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:18893 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756914Ab3GZLMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jul 2013 07:12:50 -0400
In-Reply-To: <1374751459-17994-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lO4JS5fuXHR+VlS/JBi0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-07-25 at 14:24 +0300, Andy Shevchenko wrote:
> There is nice specifier in kernel that allows us to print small
> buffers easily.
>=20
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/e100.c | 15 ++++++---------
>  1 file changed, 6 insertions(+), 9 deletions(-)=20

Thanks, I appreciate you sending this again...

I already have this patch queued up for upstream and it will be in the
next series I send.

--=-lO4JS5fuXHR+VlS/JBi0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR8lmiAAoJEOVv75VaS+3O+v4QAIXr2QUpoiMuA1OpOyCbMeql
vjpCH8GDuJABJCcH2l0FP6UEIg1UF08qTbr8Z16P0uAk0idMC+FXL4j5bGsZIYYH
cpplTc7VRURzbLJW5LmtORb/FYo7+q49mWtSs8mn8pDW5ouK13Eux6VcQfYwUgFW
3qq5pOV6Pmeml8HshKssn2VK3grRah17Y7m5fhPbu8Y9tInww+jOS4I+1S0tCZ3L
WkagyRC1S759MlKCH0JI5T1hSbJMbfaHvVVhFg3IEPFFBiIGFjOT1VxU0G+qAdJH
dTdH0Lo/pr4z0O9Gyu1QUvagK1awB0ChGqSkXYJ5esvE1+TeSr0Oa1v9Uc1PRPAp
2S38rC7o5A36jI9eUzXJTZ5TAOhto2C+fO7A3tLXKpBuZFiJOrbbc1BrcTuyVY0Z
b0TjQBPr5LVHiMhZqm4437JflynfNEefYgMk6C26CEpbOYT9C3R3ssmTTrnqDU9V
vxQcc1DgLTOu+ESLa3ZkGZo3NeSYQJX6cmEsEEGuyUiigLmraqlfQLDlpqN0u+d8
3e4LiP4VP6joDbYvN1SB1fi+82t/wFlgFf2u1lQXTxUBT9jAJd2irXEWKNIlFoxU
QwJuW0yziCSckx7L9EXjpg61r4rnH05+SEV5ZopPbnKwC6soUWPxZFuSSmXRWMsz
0JPxGXo3Bw3Y7PIAUgL1
=C61z
-----END PGP SIGNATURE-----

--=-lO4JS5fuXHR+VlS/JBi0--
