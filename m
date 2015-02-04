From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: mark constant as ULL
Date: Wed, 04 Feb 2015 03:59:41 -0800
Message-ID: <1423051181.2589.48.camel@jtkirshe-mobl>
References: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kEblFV4tEYQl6B81Slvw"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	e1000-devel@lists.sourceforge.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:9060 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932316AbbBDL7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 06:59:43 -0500
In-Reply-To: <1423050064-25087-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kEblFV4tEYQl6B81Slvw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-04 at 12:41 +0100, Stefan Assmann wrote:
> This avoids a compile error on 32bit.
>=20
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Thanks Stefan, I will add your patch to my queue.

--=-kEblFV4tEYQl6B81Slvw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU0gmuAAoJEOVv75VaS+3O5L4QAKADD4G2VsY157fjliSU0YIA
dE2BluFpycKmj7sjjA0DR/pUIoqK/n3tVTaXx82kmwkuDuygHd+JZhi46gplRoth
6vwLndYHLR4W+55QsfpFnlXkjnUbqvvWCynaMV2QKx6cjE0ypwSc7u+QgGZlLzh7
yz1cVGzu3K5EIsgP21dmVeHeZmJDrAAWZpy/TrnGZct3iydXb5o0bfJjtY/rMSQr
WEe8798YEyYDz+y8kvPZOa2msg/A8uDSbJJsAqYyMfPtxzHNCo+BYiGa3DKyVvL6
hkGTZmR5RdomVw/hTVOAbc9/6D9rj/OTTGHuXx/RR5KcaQ1QXynBWr/QbVLDe9Zw
F2ezOGBUEF0xjCxcKKrD2YRHFBYP87cdd9jjWYfFn2zf7iqP0yoy/DekQQ646Rdg
4cJrBuapIjDycZy+GFVlbT0EnAM106zHKIkiXwHjNuLcN2fT/4H+/9/udxtl1qi5
1tT0WlDJebpu77QjmXeGjEvOkTB70+s6kIzjLTgaqBX0xbdiFLKg+OHFMUxyEP0j
qHstMqjXIw5M2GTv8rIqJraMpbIz64ggAXXFocsPD/y4rvUFxTHETYsoIkqSUBZc
jPrsN/pTfETFti4sq+vcFANDVLSCzqkz7fBZx0YmWf3mAOvc40Y9xC8g1guebSzj
7dZkfLzrZRKycExtiiLI
=YcGj
-----END PGP SIGNATURE-----

--=-kEblFV4tEYQl6B81Slvw--
