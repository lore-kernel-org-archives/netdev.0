From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fm10k: Fix missing braces after if statement
Date: Thu, 04 Jun 2015 05:37:19 -0700
Message-ID: <1433421439.12224.0.camel@jtkirshe-mobl>
References: <20150604015219.2895.80478.stgit@ahduyck-vm-fedora22>
	 <20150603.235751.1703498220892447151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ulf/OtmxWUx0gds5dgI3"
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7618 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbbFDMhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 08:37:20 -0400
In-Reply-To: <20150603.235751.1703498220892447151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ulf/OtmxWUx0gds5dgI3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-06-03 at 23:57 -0700, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 03 Jun 2015 18:53:17 -0700
>=20
> > While reviewing the code I noticed that one of the commits added an if
> > statement followed by a for loop, but the if statement was missing the
> > braces around the loop.  This change corrects the coding style error.
> >=20
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>=20
> I assume that I will get this via Jeff.

Yeah, I have this queued up.

--=-ulf/OtmxWUx0gds5dgI3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVcEZ/AAoJEOVv75VaS+3OIdIQAJuzHoCLe561oQNx2zmvo5vY
mFlqfS97dXF0QCQuyLSgxm1JdtDmS9mpGkHevy/5yadqSwxzX8Lycs4Qzia1OVdL
HsD2OAO/7UNmdGaIUDRQmNW9eBieO7BYXWoK+JqcsgIZiMIQHGvdY8vlR0ONIOFo
f3mLbbpP5JxvHT7rWMR6QxoVFtRjY/tdA8z2pQN7ETbPGFMyrm8lF6GiQvxNZ/7Y
7cGr3+j4jYmSsa5z/XNd4lLv6+BrZLQllYG7imXnQ2FzVVYGx0AyGUBtu8awOQjz
CtrFFnHPiOhiikXWRsCaPb+17iY+uPm3V0KAQSbUlzS7BYpjxKgpSFzVPlEMboVF
ApAE9kjubqkfITZ5T/31vWxtgztmLs2UrLiLGwTPMFmY0rU0hFcgSTBQ5w59VTda
w7/NTSBw37CQerO/ZQSuu7Sq5c9db8RX2Sy7F9pA5HKJC/zgFYpY+T0hGU88YcZj
KFhmU8VEpXMIK/GlNc5kM75x9pM3INNIzMNBRa1+Ic9nu3h5uODcra1Uw+VmqZ/+
arIXBLH3HIGZEwLNCqvf7dpWi1Mib/q/B4IkuofGj6gWuBVP6Bctcw4aswqzOnjV
OFtVBwoD81DFxLGrtb8QurrPZck/XQFHIarmDdCmy8jEb1oEFMCA935XNAurHj+L
1PIfFLxpXdq3MiKBDV4U
=Wo6s
-----END PGP SIGNATURE-----

--=-ulf/OtmxWUx0gds5dgI3--
