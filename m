From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 1/2] igb: display a warning message when SmartSpeed works
Date: Tue, 15 Jan 2013 18:54:20 -0800
Message-ID: <1358304860.2177.15.camel@jtkirshe-mobl>
References: <50F60EBB.4000800@jp.fujitsu.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8jibLvp8W/5JIhWtUH4K"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	tushar.n.dave@intel.com, e1000-devel@lists.sourceforge.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53432 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756719Ab3APCyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2013 21:54:24 -0500
In-Reply-To: <50F60EBB.4000800@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8jibLvp8W/5JIhWtUH4K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2013-01-16 at 11:21 +0900, Koki Sanagi wrote:
> Current igb driver doesn't tell nothing when Link Speed is downgraded
> due to
> SmartSpeed.  As a result, users suspect that there is something wrong
> with
> NIC.  If the cause of it is SmartSpeed, there is no means to replace
> NIC. This
> patch make igb notify users that SmartSpeed worked.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)=20

Thanks, I have added the patch to my queue.

--=-8jibLvp8W/5JIhWtUH4K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQ9hZcAAoJEOVv75VaS+3OpI8QAJHjFHTw8THV2nV2qK+nhdQk
LloOdqQ13w5Ws2qaMaNGi015S79BFAYAmHfB6eAbuigtMfqprEhrBdUMY1RpCmwM
NHH0ehwi8Qo6czfIE3czMZJ4THb/cIPX5qMPApEbB1r09+zdn0kCErnSfdLbSsZl
VNjpX86Jb/Xl4QYHShyxjV19KGdhIFI904jv9U+v7Hb/sgmciuoxmYVkeWaupYCk
+T/JBQFAvPb8iDG8UosbGVRqKYZs9UAbO3FMmHTVb7ehdh2HZhua1ombQkGaMMJA
8/hVrn42OtZF7pgwYdNFPWlm+OHxaE21ykASvnyfLDmsjXxA77VlazKlMrVt2qeK
iIhUqJWrV82ZMK++Ir0A8eeWfGPqQ5o0VZpdWBWN7taGA+rPUKiEZtenQtuuc7IW
xsfe8YVLJ092Y3KB7nTgR+YTJ8E737lsOy42IPYW+k1WOQFPUAF0F5miJ4hQghLG
jyxrRuYwamUmuzV38udvDVHo+ugVeWYkPdD238IGYK7ZXokeEZPGhz9Jym86594Y
3MPcIw0EjTZrt2ds3iQSS+WLPPvLmYcIVqHq2jfDKutfY3Q1N+QMDQv4GLv0yTyT
yIkzngIV3Vvt7bUuc9K1NIZEYT7vWNu1KG+2zQ2wbPZnBAUQxpsNLE1smGV791VG
wtu3z6OUFAyPh1xzVklh
=Y4Sf
-----END PGP SIGNATURE-----

--=-8jibLvp8W/5JIhWtUH4K--
