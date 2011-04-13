From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: Remove not used blink_led_start/stop code
Date: Tue, 12 Apr 2011 17:29:37 -0700
Message-ID: <1302654577.2950.60.camel@jtkirshe-MOBL1>
References: <4DA4E016.1050800@kernel.org>  <4DA4E099.2080206@kernel.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-PnsSFzGbZ2MXXDllRomC"
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54058 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab1DMA3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 20:29:48 -0400
In-Reply-To: <4DA4E099.2080206@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PnsSFzGbZ2MXXDllRomC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-04-12 at 16:30 -0700, Yinghai Lu wrote:
> There is no user for those code.
>=20
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>=20
> ---
>  drivers/net/ixgbe/ixgbe_82598.c  |    2 -
>  drivers/net/ixgbe/ixgbe_82599.c  |    2 -
>  drivers/net/ixgbe/ixgbe_common.c |   56
> ---------------------------------------
>  drivers/net/ixgbe/ixgbe_common.h |    2 -
>  drivers/net/ixgbe/ixgbe_type.h   |    2 -
>  drivers/net/ixgbe/ixgbe_x540.c   |    2 -
>  6 files changed, 66 deletions(-)=20

Thanks for the patch, I have added the patch to my queue of ixgbe
patches.

--=-PnsSFzGbZ2MXXDllRomC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJNpO5xAAoJECTsCADr/EWU1EcH+wQDXX/rWjdV/2ldXG+XhzgJ
9dDz5CD/mClnC5EfLL0PiqD6AXThCyWN3JUiT7Vt0Zh2Jg57rlTkoacBQFAFNTBc
7yvA+rqZdy6S7W1UNjtY/k4Gltj+nIj2hb1UrLLcdKdsxp7BYofSi9pEln6eqCcW
VvilKtsLjHJX5hLDIYrqd6LL6J26NdPntLtwhMAw5v9xTs9Hv7wBDUgSYSXpS/SF
OpfZy3aW7h6Ft9kxom1m/rMWSGp6e/eKH/+U8ITu1FXG2wj+uAok6kr8Ll/mmByr
J3Zrgefgc6HpRYLgV0R8bhXBDO7Wc3s4scLqNyWuh6gmjkUEnaDUtOhCj6H516Y=
=XLWA
-----END PGP SIGNATURE-----

--=-PnsSFzGbZ2MXXDllRomC--

