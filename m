From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: drivers/net/ethernet/amd/ni65.c:1243:8-14: WARNING: PTR_RET can
 be used
Date: Thu, 15 Nov 2012 01:20:31 -0800
Message-ID: <1352971231.2337.41.camel@jtkirshe-mobl>
References: <20121115082912.GB55738@bee>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rhU5Soag/eDG9WdHKjD2"
Cc: fengguang.wu@intel.com, yuanhan.liu@linux.intel.com
To: Xie ChanglongX <changlongx.xie@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20135 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933008Ab2KOJUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 04:20:33 -0500
In-Reply-To: <20121115082912.GB55738@bee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rhU5Soag/eDG9WdHKjD2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-11-15 at 16:29 +0800, Xie ChanglongX wrote:
> Hi Jeff,
>=20
> FYI, there are coccinelle warnings in
>=20
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux mast=
er
> head:   9924a1992a86ebdb7ca36ef790d2ba0da506296c
> commit: b955f6ca776f3bab3d1e2c5fb1d247b203cbda14 amd: Move AMD (Lance) ch=
ipset drivers
> date:   1 year, 3 months ago
>=20
> + drivers/net/ethernet/amd/ni65.c:1243:8-14: WARNING: PTR_RET can be used
>=20
> Please consider folding the attached diff :-)
>=20
> ---
> 0-DAY kernel build testing backend         Open Source Technology Center
> Fengguang Wu, Yuanhan Liu                              Intel Corporation

Go ahead and submit your patch to netdev@vger.kernel.org, I am sure the
AMD maintainer/community will be glad to consider your patch.

--=-rhU5Soag/eDG9WdHKjD2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQpLPfAAoJEOVv75VaS+3OqR4P/iD+TB2HCaXyEFCN3iGPhe+J
8+CyE8u++SjFWJwoYWdCVDvKOMXwk+d8a6OQ3xRGKGsFqdvBXQFhmo+ngu05W4OS
5lMA2espxvPnrjJa8ADzwJdMvx8MSY2/DJqMUv5YAFWcVaW7cHyUoIbpTlJtXpwK
Tw09237ctRdTK67KcwgsacK4YiMFeEmkfjnXTn7zq2A+Xa/NmIzkKqIRTQCtEqt2
zSvqJG10IaQ/ziHO1uqVErXQNBk1Zan2/ZqrLsWKVV5V9IzcLekT7TEyWXhUTmlu
N1XitcGV8JiZ1UyfYQjg5tlipYZ5DyO9JM2MC+/kbKlGEhqWTYJ5dbllE38kLFFv
/YHXgOlxZlt+OF2dLqX/WMWII+EknnbtEqu+cSn6wEUWHQtYeJ7SWP0mKNVeyYEQ
LYqUFfc0XlCcq7v/bMr7uLjvgdnQ25KLE2zz6evSkPakN18ZvUlfvHlPAMuEXzjL
riydW5YASIaAy7b+6fUV7IxGWp5KwTz71fwJ9ezid4SylJqvUkBJdWniRMR7Gcax
O1h/9KPOPYMBVOLnzGwAEY6Kfi/pU3vnuvD11gX5+03qx6TzT9Wbkq1/EF9nALFf
xbcvcjB8SWqjZgQzX3TMO7bUZkY4UfNiGGdvaq8pWhxG9vYnix1w7aOGrT2ym+9h
I5pyn2sBWMsx6lP5HYzp
=2yUl
-----END PGP SIGNATURE-----

--=-rhU5Soag/eDG9WdHKjD2--
