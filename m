From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: remove duplicated #include
Date: Sat, 23 Jul 2011 01:24:09 -0700
Message-ID: <1311409450.2835.52.camel@jtkirshe-mobl>
References: <1311409201-2324-1-git-send-email-weiyi.huang@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-v8/HjZ93KhM4ru+KbEKX"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Huang Weiyi <weiyi.huang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39478 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751471Ab1GWIYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2011 04:24:10 -0400
In-Reply-To: <1311409201-2324-1-git-send-email-weiyi.huang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-v8/HjZ93KhM4ru+KbEKX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-07-23 at 01:20 -0700, Huang Weiyi wrote:
> Remove duplicated #include('s) in
>   drivers/net/igb/igb_main.c
>=20
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> ---
>  drivers/net/igb/igb_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index cb8c6bb..dc59905 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -47,7 +47,6 @@
>  #include <linux/if_ether.h>
>  #include <linux/aer.h>
>  #include <linux/prefetch.h>
> -#include <linux/if_vlan.h>
>  #ifdef CONFIG_IGB_DCA
>  #include <linux/dca.h>
>  #endif

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-v8/HjZ93KhM4ru+KbEKX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOKoUpAAoJECTsCADr/EWUAfgH+wTO5LHb+rNmrdDIC58qjPOA
JQ+HqW0LMAfvKHoNfSs/CHg/gkP1ZOhaH5f+0rg7Lw88zvU0g9Oa4A5FfNC/Y9fM
hbqUWHnaEKsoyA1ZoDL2M/hJ3RN+EfRQS+MAcp1cWk8f9IwS0xtrhseEOXWrUy5j
F93VTzU+KbRJYG1mTvA/tJrmEW5rCamtFm4oLvhxOVmie50fvRUK5Y4WugDyE2DM
ujZ5ryk8PdhK2FOA5KkX6mHmliSpjLBaCQPKXWPWIefDjQQEQDcNCQqQZSbOycTl
O13/WWeeOg/9abnkKfZht4VLUoTPRQC+gJ18/JA7dg60GBaCc9X2H+FxM0gijTo=
=XPO7
-----END PGP SIGNATURE-----

--=-v8/HjZ93KhM4ru+KbEKX--

