From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 5/9] ixgbe: Convert uses of __constant_<foo> to
 <foo>
Date: Wed, 12 Mar 2014 13:50:55 -0700
Message-ID: <1394657455.2167.7.camel@jtkirshe-mobl>
References: <cover.1394644825.git.joe@perches.com>
	 <a8b7fce92d51c6c97e1450bc291b0815325935d0.1394644825.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O3VCieOghYswgqeJ/Ynr"
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a8b7fce92d51c6c97e1450bc291b0815325935d0.1394644825.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-O3VCieOghYswgqeJ/Ynr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 10:22 -0700, Joe Perches wrote:
> The use of __constant_<foo> has been unnecessary for quite awhile now.
>=20
> Make these uses consistent with the rest of the kernel.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |  8 +++----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 30
> +++++++++++++--------------
>  2 files changed, 19 insertions(+), 19 deletions(-)

Thanks Joe, I will add this to my queue.

--=-O3VCieOghYswgqeJ/Ynr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTIMivAAoJEOVv75VaS+3OLPsQAJLC0WAXCJa2CsnJZ4NArziX
6tKkDN2++A2zzZ/ezDsEFSts2RP6a5+JIBnnQQ4ZEjeJ8mf79qRP/6p9PBAPQo5c
pl53a5ZC00tfMecy2UsoBPKV92WtjEi2J/H+PH002/eZHLizLaEW2Iw2EKUCsXGN
BZdnnBTAAIljusjNp2wzEyMWv777O1N50eH6Ht3GT0p/fQVi294r2G5PxRksSDw8
hFMX/sntupYHrVF3RVkGn9MtdmUNZofHkSrfiO6cEghx2eu5gDffCH+CIfXXjWI3
434MfwZtX7yvfjf38OJC+tCNzNGM6kV7fcXFh4VvQtJnFnMJeZX5Hp3RILt987Lv
pgMitSI26aJfapZ8R1Ni6FJh2KaRsFFNL5er9Z9YtZLJBLc+rRK/aMU5B9zKmB/h
WVAGOhus4EnPvA8pP/P3iuVtx5atLD7G8WKAxDVVV73R/F6mLy0mEvmgHrkZKcnO
w2eJnGdGsR4j/QHlCVSx/2csBT4u+poEHIvU1Gvbe2Kx+/zj3RKoac3G8WT2JCJd
QEZPSVav5S/PI91DJ+8B0NUh0OIqOjEMmfJxPNjyTIuIvevQi7X2HRjJRPPTX+Vy
LCed0rN0ioSRHTYQoRS1PZlMkQgdnnPe5S5gpiycld6lfLjLRIArMDzhVhKGgEWa
lRM3m1PV/STXmNkF9uc7
=lRut
-----END PGP SIGNATURE-----

--=-O3VCieOghYswgqeJ/Ynr--
