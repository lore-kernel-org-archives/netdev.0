From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool 1/2] ethtool.h: implement new MDI-X set defines
Date: Fri, 20 Jul 2012 13:50:06 -0700
Message-ID: <1342817406.2045.22.camel@jtkirshe-mobl>
References: <1342765524-29711-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1342797849.2678.19.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-qbdNtL07S/7EAX3qlk48"
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27115 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2GTUuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 16:50:07 -0400
In-Reply-To: <1342797849.2678.19.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qbdNtL07S/7EAX3qlk48
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-07-20 at 16:24 +0100, Ben Hutchings wrote:
> On Thu, 2012-07-19 at 23:25 -0700, Jeff Kirsher wrote:
> > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> >=20
> > These changes implement the kernel side of the interface
> > for allowing drivers to set MDI-X state on twisted pair.
> >=20
> > Changes implemented as suggested by Ben Hutchings, thanks Ben!
> >=20
> > see ethtool patches titled:
> > ethtool: allow setting MDI-X state
> [...]
>=20
> I don't see the corresponding kernel changes, but I'll hold onto these
> for a while in the hope that they show up.
>=20
> Ben.
>=20

I wanted to wait for Dave to pull the patches currently sitting in my
net-next tree before pushing out the corresponding kernel patches.

I will be sending them out here shortly now that Dave has pulled from
me.

Cheers,
Jeff

--=-qbdNtL07S/7EAX3qlk48
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCcR+AAoJEOVv75VaS+3OtsQQAJzS3xWEpAGO6/WdPVF684H5
a+dV+DNR91iuQQUSYcKX0nDwmluYlrN3vSpGOmeKxINT2zQ2yxajPN8pIgCYNsQK
iEnBAFDqyuGm0RL6Cq9A9fN6OcB3B27PJQuVYYkPGjS851aOgtKKCfA9ckfRcr1C
UfxMeoakKT4CDSeIdttFWKbdWvII4pqTksWLcawJN9laxjHklJdKfkm5fVJ7cAQ6
xqeICLKey7h5uhts8jNrbqJPWsFqoOcFvl87Zvw1n+s90l6ZuNQFyMnTsFO9+Izt
mnoNt3kyytLNDanAkF95X1cm7RtDFlaIVXb4a+zgpWj8B14R0FW0i0R7+UzV+F8d
LqmH8OZzzJj2E0tPwpfB2Uw9DJ2dGLkR4aFGRQYz3MgoVkuRUPQM3OYK+iOsZheG
iTcIXPaHW4XnywyTQNMxd0p50BeOy2mS2TfBzxJlD4Zifhdx4SLsQfa8wcFB7K3r
P0SpSVphNg5lCZYc/n0boAYa2ogPlw4EqS0wJes9HNBSj9Or9fkP5WwJCfNsuUAj
WDPNgVTxC6tDOnuTxQXS6qWjwIib+TV+Y003yktWBJEH5HezbwCLfn3aeSsmf+Jd
bKYuzZnDPQqE3hmgG9bKGiOFGd/y1i0/qysRBf5sYJqmUTwxl9I/Ur7j0xpj2s3Y
Ctfj8AHhf3FOvy2SeDwM
=WsOo
-----END PGP SIGNATURE-----

--=-qbdNtL07S/7EAX3qlk48--
