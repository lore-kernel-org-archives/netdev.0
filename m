From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Update Intel Ethernet Driver maintainers list
Date: Fri, 03 Oct 2014 15:04:36 -0700
Message-ID: <1412373876.2408.18.camel@jtkirshe-mobl>
References: <20141003213835.147369.71088.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hUCOPzoLlwE/MqWuYL/n"
Cc: netdev@vger.kernel.org, matthew.vick@intel.com,
	alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30826 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756562AbaJCWEq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 18:04:46 -0400
In-Reply-To: <20141003213835.147369.71088.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hUCOPzoLlwE/MqWuYL/n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-10-03 at 14:45 -0700, Alexander Duyck wrote:
> I will no longer be working for Intel as of today.  As such I am removing
> myself from the maintainers list and adding my replacement, Matthew Vick
> as he will be taking over maintenance of the fm10k driver.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Dave, no need to wait for a pull request on this one. :-)  We will miss
you Alex.

> ---
>=20
> Just wanted to send this out as a notice, I have internally submitted a c=
opy
> of this for Jeff Kirsher's tree to have submitted via a pull request.  I
> should only be without a corporate email for a day or two and will likely=
 be
> back up on my new email account early next week.  In the meantime I will =
still
> be on the netdev list via my gmail account.
>=20
>  MAINTAINERS |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c2e7a06..e36f464 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4784,14 +4784,14 @@ M:	Deepak Saxena <dsaxena@plexity.net>
>  S:	Maintained
>  F:	drivers/char/hw_random/ixp4xx-rng.c
> =20
> -INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf/i=
40e/i40evf)
> +INTEL ETHERNET DRIVERS (e100/e1000/e1000e/fm10k/igb/igbvf/ixgb/ixgbe/ixg=
bevf/i40e/i40evf)
>  M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>  M:	Jesse Brandeburg <jesse.brandeburg@intel.com>
>  M:	Bruce Allan <bruce.w.allan@intel.com>
>  M:	Carolyn Wyborny <carolyn.wyborny@intel.com>
>  M:	Don Skidmore <donald.c.skidmore@intel.com>
>  M:	Greg Rose <gregory.v.rose@intel.com>
> -M:	Alex Duyck <alexander.h.duyck@intel.com>
> +M:	Matthew Vick <matthew.vick@intel.com>
>  M:	John Ronciak <john.ronciak@intel.com>
>  M:	Mitch Williams <mitch.a.williams@intel.com>
>  M:	Linux NICS <linux.nics@intel.com>
>=20



--=-hUCOPzoLlwE/MqWuYL/n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJULx10AAoJEOVv75VaS+3OcdMP/1trFwdKxBgr9TBIaKiXMUah
u60y2elum4gZh/+vD8hk5AtMk7MpQwm4ClKkJAGv/d7IEiMwkbU95rkPpH8+t1iO
/++3mGGkG7wwHoMj8rPDb87BlYxvMONuRWAlTo3MwI3z5dS+8BIZuUibGiHB5haD
qYvnEsPxM0FlSXp84IhpcwWK1OQJu3Wy0xn/KPuUbi2Masyzv7nxsQmAQa3lvZ1b
krUXa36dB27hu/Cld9VrUO5bKYYicyaHbboE5qg0ZyEdGNZWUiYvWjSjHiID/dnP
lrGV6/5jsNVC3LO4OrwiB3ROGKTmSfprt3BXt8BtU41rcJVDbfi6SiNNW/vounLt
dUhxDoiEw7ZCNhY9+nIhTRs4Y0Ms1MufNkmFayXbIjvJeDkGGROeN8P6/5dWCb82
NjCiMPS401yKWqm8kesCTzInP3sDZ+2x6Yzee4NqJe0ODH3Ycw4lMiiJIJM7w1xu
ECC6r8poIEXtFv8BmCpyUqZTneHTH5b2c12qdIe99iylhDW0hLzmmxcnDSPSCQr1
eUHAK7mcGxv51gN5+mScdoNUGjf4WJyxxqoKV2pyK39badRMhVsXgZobrlHR3BvK
PUF5tg0cDFYQJnfw+iX4DQW4eY8KyHqm7o7wF7lNv+QgtOWANGGl13svFdcm+JAF
MX6GdhdB2rYIQzWkozj8
=NtSu
-----END PGP SIGNATURE-----

--=-hUCOPzoLlwE/MqWuYL/n--
