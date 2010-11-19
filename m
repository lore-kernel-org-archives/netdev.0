From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Thu, 18 Nov 2010 16:34:24 -0800
Message-ID: <1290126864.29524.6.camel@jtkirshe-MOBL1>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	 <1288316896.1836.41.camel@Joe-Laptop> <4CCB3BF1.7070000@windriver.com>
	 <1288390127.28828.225.camel@Joe-Laptop>
	 <1288396919.15283.23.camel@jtkirshe-MOBL1> <4CD323AF.20609@windriver.com>
	 <AANLkTim2yH7eAqqYQW+JVC5GtFR5mX4uZnMa02+yubFk@mail.gmail.com>
	 <1290124345.1817.53.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-OjTJCQ/bVDJbWtmORbfB"
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:15386 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107Ab0KSAe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 19:34:26 -0500
In-Reply-To: <1290124345.1817.53.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OjTJCQ/bVDJbWtmORbfB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2010-11-18 at 15:52 -0800, Joe Perches wrote:
> On Thu, 2010-11-04 at 19:28 -0700, Jeff Kirsher wrote:
> > Joe and I are working to organize the drivers into
> > /drivers/net/<technology> directories and to cleanup the Kconfig to
> > reflect the organization.  Ethernet drivers will be in
> > /drivers/net/ethernet, and so on.
> []
> > We are hoping not to drag this out and plan on getting this into
> > 2.6.38 (net-next) within the couple of weeks.
>=20
> What is an appropriate time frame for doing these
> reorganization file/directory moves for net-next?
>=20
> David, do you have a preference?
>=20

I am almost ~50% done with the patch, I am hoping to get the patch out
this weekend.  I have been testing as I go to ensure that there are no
breakages,that has been the reason for the delay.

--=-OjTJCQ/bVDJbWtmORbfB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJM5cYCAAoJECTsCADr/EWUxEUH/0mMApvbygWeEEc4QXul2eFr
+7L1/UyJ2GaMgC5QN/A0fqDjym/7lQIpxGQyFhmYI6vDDOSFW9zFE2gQlFoEQijb
f9Crx8qf9gNL+3RsEjfoTsuBN4xNAGR8mzMopS6iXcdeuBIAFGG7WIly3X9avQ45
OlJRv/0k6ZNdnKW/0/ySKIMORBENIqi4vN3zrl+5j5oZMul+9wSLGJ/eyKwyW8Kp
ynHE6t7qJuQDcZ1OZgWwwskO/xQq2Jz2fVn3/N8SU2C93xVuQwEZ/+NR5/1oW6hE
DF4nGpMsf3vD/kYEJDaSUFK0QwGRfNJDUCkQeQd8jDwaFMZCjm44F977TwJlrjc=
=3RAk
-----END PGP SIGNATURE-----

--=-OjTJCQ/bVDJbWtmORbfB--

