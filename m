From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: Re:Re: [linux-nics] [PATCH] e1000e in linux-3.18.0: some
 potential bugs
Date: Sat, 20 Dec 2014 04:47:47 -0800
Message-ID: <1419079667.2461.92.camel@jtkirshe-mobl.home>
References: <000f01d01c2b$4af1b3b0$e0d51b10$@163.com>
	 <1419070952.2461.82.camel@jtkirshe-mobl.home>
	 <aaab622.119b.14a67ba656c.Coremail.baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jw7U6ttgA8NZ78lwfKC0"
Cc: netdev <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: =?UTF-8?Q?=E7=99=BD=E5=AE=B6=E9=A9=B9?= <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5234 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947AbaLTMrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:47:48 -0500
In-Reply-To: <aaab622.119b.14a67ba656c.Coremail.baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jw7U6ttgA8NZ78lwfKC0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 20:44 +0800, =E7=99=BD=E5=AE=B6=E9=A9=B9 wrote:
> Thank for the reply!
>=20
> For the first reply:
> I let some functions fail on purpose to test error handling code, and
> then run the driver in reality as well as monitor the function calls
> in runtime.
> The results are in my report.=20
>=20
> For the second reply:
> I admit you are right, and my code style need to be improved.

Adding netdev and e1000-devel mailing lists back onto the CC, since =E7=99=
=BD=E5=AE=B6
=E9=A9=B9 removed them in his reply.

--=-Jw7U6ttgA8NZ78lwfKC0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlW/zAAoJEOVv75VaS+3OZ3EP/07fnuCIIRe08tJdSTeMuxvO
QFk8wGujwWN4p3gbFFeET0m407Z0/3k6wpKt2wLiNfbvTVg25LdNUr8hFW3hvSVQ
gNzh2o4b7sW2TaO4rtGovzgazLsLorRjZFol+vOGhkozeiDbrlpOt10hXMJYbZlZ
/fv436yHmwMUxr+rFcLr/hXXV6tE65JJklEFwXMYFxhXndBbiuQff62zU6AZDbVy
lC43UtR3KYaNFIfi/hFo1L+WHeR2XODcnZHw/rLsVJasehDngpOt6jkwMAW9NEAB
ETbeZ49VImcEDd3YecEsnZRpCt6rNjy2VWYKieW1VF+SKcOelMeosNIsTVOvktCF
1woCXf52Yp4jO57FmAf+rUoo4kGgyrzMKJuiJtwgZ6bQeQHewtXIkqSyX3C8+gVS
pqJ/WnnGxatX9bZCBM24AxRqkMeKKdL2unFKNs26+0RDxlWWSSFbCItMTz0Nnoh/
39AC1xwLHoQnnK0MiXJ/7158Hj27zxji/Q/xswKffhOjAeWMmKOhP70fG/LyAZ2O
a3zU0psHSGx3CfwovU4adIFohw96OOtYxhGouhSwEYSoN6pw8T8y4d/AUyln6nHi
Todag0Nx0Aya1exMAjYm58AbewEY+G4qPLdGchYeBbHmgTWp4Ka2feBaT9BRX8pY
enWFNaSNdV23Uw64iiTX
=p7VH
-----END PGP SIGNATURE-----

--=-Jw7U6ttgA8NZ78lwfKC0--
