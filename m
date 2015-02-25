From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e: fixup comments jumbled by i219 support
Date: Wed, 25 Feb 2015 13:23:43 -0800
Message-ID: <1424899423.2622.1.camel@jtkirshe-mobl>
References: <1424891471-2833-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NYA/nCyh3hAjfx4/ZMQd"
Cc: netdev@vger.kernel.org, David Ertman <david.m.ertman@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:6725 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbbBYVXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 16:23:44 -0500
In-Reply-To: <1424891471-2833-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NYA/nCyh3hAjfx4/ZMQd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-25 at 14:11 -0500, John W. Linville wrote:
> Commit 79849ebc0e06 (e1000e: initial support for i219) jumbled some
> comments in e1000_init_nvm_params_ich8lan.  This patch rearranges
> them in a way that I think makes more sense.
>=20
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: David Ertman <david.m.ertman@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)

Thanks John I have added your patch to my queue.

--=-NYA/nCyh3hAjfx4/ZMQd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7j1fAAoJEOVv75VaS+3OTf4P/1FxC/6UkC3txnvI9ZcEkD5A
74hkibcDdBNcv3s4VjNsY3c+vdhz4zdMMGVF20kzsVzB9+3H0ZG2GZy2p9+euoLi
X2m/8h7NtjZldJlRaaaJtocJfWMXfq/Qdnkx4sd8wdlqOA43h1bUNoBsSjNZC0y3
Zw+NkuLVZls2XO9B0SbJPGfZOpv3FmP/9Zy/KX3zAYTEe6DJPmgK08JXUK4vczqc
8d/NA2kbvACCJq8H0UPqvl98nJc0z8vHVsTrOnACEzdDy/fFCvMnWni4O22CdMy1
9lwam0cRagbGtTE97tmq6hD6NxVQDAYJ64q990nvFpO17mw6zrePtwTGLheU2Zhj
sCAxoe1Nhd2c/f7Ek7kJUr3RHXWezaxhrtB9mpdPk+KOky1sTSrNegx/JgHBB2q4
bR342jJTtwNeoH9eLAfsy3sFzanvw6HwY1uWx0ZloXashHGqa9f2PgFlm/jV8N7H
hk2vJ6Bm1CtbkFGaX5ZHHmungiLlRPeF0k4Rix8A8L1Q6cpvDbnRBfORkoMlJU8D
KHVH+Go3SeHFv8oCNlRiuEXpz/VU2v35Y1nMuihC8U6bfOQo3vK5fl0cROu9VfDB
g3KVqye1utKDUOW0tBEF6bYV8D63GIH3gKgZr47t6P4eNqF4hhF1VrMWSlEM9kxu
hctXhKKaLVC2YSfzLl/m
=a8eQ
-----END PGP SIGNATURE-----

--=-NYA/nCyh3hAjfx4/ZMQd--
