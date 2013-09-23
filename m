From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: remove unused including <linux/version.h>
Date: Mon, 23 Sep 2013 14:09:55 -0700
Message-ID: <1379970595.1906.1.camel@jtkirshe-mobl.jf.intel.com>
References: <CAPgLHd9B7h-w7sXPep5baH9XV=Yb1zNAU539hLm+Zx+6PRnejg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xcnRuBDE3KRdvazOqHTF"
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, shannon.nelson@intel.com,
	yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13169 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752809Ab3IWVJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 17:09:56 -0400
In-Reply-To: <CAPgLHd9B7h-w7sXPep5baH9XV=Yb1zNAU539hLm+Zx+6PRnejg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xcnRuBDE3KRdvazOqHTF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-09-23 at 11:39 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> Remove including <linux/version.h> that don't need it.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/intel/i40e/i40e.h | 1 -
>  1 file changed, 1 deletion(-)

Thanks! I have added the patch to my queue.

--=-xcnRuBDE3KRdvazOqHTF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQK4jAAoJEOVv75VaS+3OJq8P/2sD5LY5FkeFgU06MMFb633A
8v6s9trr6xFbdifZrTET447R7IC6kHvjqR6gQ9IMPgysob1JjsQDzxKpyl5fnTul
M4kB3zctIo01IvsGErE6ZzyrdihPcqVKXpcHHaM/I6Lj0BFxJPKzKlXaoK3PqWwp
e5NOwZJZfhk3NPMdZQP9YD8OzhQ17kAyUDthsDWRnZbwLF2i0okqRK4FT6+LilPl
Nfdn96SNbwWYuRkPrGguFyui8WocXcjvo+RT/9dSPTqw6RkAHgJmEmVIA2pXmwpA
KniE0Xa1gf0LoESGXxss1HMvEFqb5s988Mj5ZhiH/35aDEiUkju3Smef7ocoy6iv
c7SGwnPx+XLJabfyLBoTnefKx3voNxSSOLTAWzCcJY2qTiOHHruwpQ3/kYmafpFX
9VTtSAthjcHPt7QFJh2KNoZIKxVYSN/J+p+SqeqFfjj/UJApID5aNDcfVGfoXF5x
MH8jQaGZhZtxNyw9EcswKbDLG1+C0YyndAniMJ0GD8k8vcSy1paJ2lrjzawTBfG5
SYlruqG45fdA8uLXVxt/8BEqP39A2hPSR14NPsGvwR2td2zF2hfDVh1Ucnuwvru5
ndTqoCIX2TKOQ20uM/XeoHO2/SLCpLP5ai2Mpx3VYjz3YjiOZHVQwpYjw8Ks7MWY
XVzxnaLhPx1FhIbE5G9Z
=QAHs
-----END PGP SIGNATURE-----

--=-xcnRuBDE3KRdvazOqHTF--
