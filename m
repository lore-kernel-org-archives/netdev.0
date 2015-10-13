From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40evf: fix 32 bit build warnings
Date: Tue, 13 Oct 2015 11:59:14 -0700
Message-ID: <1444762754.2870.30.camel@intel.com>
References: <6607276.TY67sbLLqL@wuerfel>
	 <1444717101.2870.16.camel@intel.com> <57023416.17EujnXPCo@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-a2qPI7N/nJdGiIJAzEFN"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	kbuild-all@01.org, Andrew Bowers <andrewx.bowers@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:47636 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476AbbJMS7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 14:59:16 -0400
In-Reply-To: <57023416.17EujnXPCo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a2qPI7N/nJdGiIJAzEFN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-10-13 at 13:37 +0200, Arnd Bergmann wrote:
> This is the majority of all build warnings we get on allmodconfig
> (both i386 and arm),
> so it would be really nice to have it fixed before 4.3. For all I can
> tell, the
> patch still applies on your branch too, but see below for the rebased
> version.
>=20
> I also note that your branch is not part of linux-next, is that=20
> intentional?

No, I assume it is because the linux-next maintainer has not picked up
my tree.
--=-a2qPI7N/nJdGiIJAzEFN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWHVSCAAoJEOVv75VaS+3OEagQAKBQa35bSpPyehdCYlWJTA8h
4hSVmoXujSPajk0i5fmt6kX1zd+T3eiqu1VrPb+B8yvb+13zNvSDvLhjYPZm6HJJ
c4bD/bYHTEfQaCN0R01lktn9nPyX75Bgkro/tI25FfB/TpyLDZWwh1R7nUbSmErT
4I37ypT8AAYsq0aF85ab5T2nCZMsCuA/WFYCibC6qHJfgkkTw6a1ZIdawgP1d9yL
/8Yosyt9xdVwq/RH2nGn0RikWfGoKpx9lkGPEpr7ao/Rw6gvUwYKJXE2J/co0/Ml
yFasarmN1EPvvRTUFx3fo4Xux/rZ1dYr3xlr4H5stZvb8U/OijsLBQF01vIBtG+G
axH6n6fvG1OfWd1GgB4ecTUkcVMfUPAH3Pt+EcqqZ5xZVl6m+mcUJpUWewo2E6hH
EeYuulWQQMkXFAuxAI6oMxvXd2daBYFAhGayXCyIiepM/53y3Z0xDls64X7PzaDw
KqmNSj0w20mXmhMjyZhI2Bh53ERL0BFhh2li0V8ktumz+1eb1s2XYY7l6fRm1sfc
eAJoA1Sjzh0gaPvqUYDSiDG7o7eyWyAVqY0PMC1opyOCultX3ShEeAOtTkWrPzo+
neED5SDDMFSmIvHeEjfkR+bNhFZXIDw/xTDWkmUfjoHg0Rkvp/9jxTXlXNkTbsNk
yTwd15t1y7JPZm2BO81r
=ym+K
-----END PGP SIGNATURE-----

--=-a2qPI7N/nJdGiIJAzEFN--
