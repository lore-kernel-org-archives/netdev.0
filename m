From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 0/3] rtnl_lock fixes
Date: Wed, 08 Jul 2015 16:23:43 -0700
Message-ID: <1436397823.3214.15.camel@intel.com>
References: <559BF5F8.2000500@virtuozzo.com>
	 <20150708.161533.531768243562810631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tdj6OMx1R103Rv7yqqec"
Cc: vvs@virtuozzo.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22184 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007AbbGHXX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 19:23:58 -0400
In-Reply-To: <20150708.161533.531768243562810631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tdj6OMx1R103Rv7yqqec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-07-08 at 16:15 -0700, David Miller wrote:
> From: Vasily Averin <vvs@virtuozzo.com>
> Date: Tue, 07 Jul 2015 18:53:28 +0300
>=20
> > While investigation possible reasons of net_todo_list corruption=20
> > on rhel6 based OpenVZ kernel I've found few places not fixed in
> mainline.
>=20
> I'm assuming the Intel folks will pick these up

Correct, got them queued up.

--=-tdj6OMx1R103Rv7yqqec
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVnbD/AAoJEOVv75VaS+3Opr8P/A4arem0PP/GhlbByjxdr9tA
spc3iVMdCVAmvsgNilpYUtOchswfSBRIED5ixFpPabCVSYB4GvribyrLbzuMmCug
qGUEZ82++diOgWf7UH2XcRaCZCpWkEpZalFZmucOsueP5cR8b/zzssOSgnbG6/zw
ukIYpNIBEpi5wavVaJEmqKMJakw+bH30FSk078GCyJFCapoOcr7/7lHRbJX0Aske
vlIqX3WgXBFr6c2fCAD/vPVss8/jIWTMyLP/cWIvs5DQ+qbg7JELGlNgvgahlr2r
yaLKr2OrZPMReZwH94B3d8mpZJhPz3q+ZOtMITZCGlS3uJINuQLJbGQq9DAEVS1m
p4GoZSOEMk58ZxhrzXd7DyGDA2DX8gHZmdAa5w5Dx6+nDYMgxNaI+D6XGu+uPXy+
hgQ8N/fU5Ft/4I8BYod17WJrn9aQosfBcUiaE5vMC0v72JiruDgeafL0bHlwjQXc
0KBvIARkpRhj9GkO1mYp1JKShHxLP/k6Gd9ZdcBihjOjzaamcje1geergasF4+1u
TDpr7jWZVfS1PSLDorLTgM7bKi9WbrtZJ9l5V8RKh2QmAQ7mUiq6rj0PGgi1jMZk
/cF6T4kwpWr8IviGtlOW+58y5C5VE8wu7tCfZlIo4Wci8ngsNvkJyZibiCjmKT/4
LKDxtTdDPYxWYlnl2ii4
=HoMt
-----END PGP SIGNATURE-----

--=-tdj6OMx1R103Rv7yqqec--
