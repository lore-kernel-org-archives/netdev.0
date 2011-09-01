From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [linux-firmware v3 1/2] rtl_nic: update firmware for RTL8111E-VL
Date: Thu, 01 Sep 2011 04:55:32 +0100
Message-ID: <1314849332.3092.130.camel@deadeye>
References: <1314807407-1512-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pfbJ9BHQJJJWHGSoxxn2"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46828 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757550Ab1IADzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 23:55:46 -0400
In-Reply-To: <1314807407-1512-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pfbJ9BHQJJJWHGSoxxn2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-31 at 18:35 +0100, Hayes Wang wrote:
> Updated firmware with stability fixes.
> Version: 0.0.2
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  WHENCE                |    2 +-
>  rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3552 bytes
>  2 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/WHENCE b/WHENCE
> index a47b307..eb7bdfd 100644
> --- a/WHENCE
> +++ b/WHENCE
> @@ -1657,7 +1657,7 @@ File: rtl_nic/rtl8168d-2.fw
>  File: rtl_nic/rtl8105e-1.fw
>  File: rtl_nic/rtl8168e-1.fw
>  File: rtl_nic/rtl8168e-2.fw
> -File: rtl_nic/rtl8168e-3.fw
> +File: rtl_nic/rtl8168e-3.fw (version: 0.0.2)
[...]

Like I said before, the version belongs on a separate line:

File: rtl_nic/rtl8168e-3.fw
Version: 0.0.2

Ben.


--=-pfbJ9BHQJJJWHGSoxxn2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATl8CNOe/yOyVhhEJAQom+w/9FVEuuYMi1wG8WEPUGSWQ6pJ454lFA6xM
Tp4K++Lke4nOHQZ3s/UgQgDdhKIDGOeGrPGlXXJx80i+IkpfeM/ZvRlopdZYzCfz
TepbohobFQHoHv3u94g7EE9mc5SUmdGLldMPBHgnquCttSoEvELDk2UQSRKL8izi
h7NCHmoFT+kntv017hrc8Ldnds0+JzGVR/RHMAIK1Fdt3yHm4lPCd+iqmqotHUNI
4evJV/aV44FaSyzfggVNqA4GU5mYz7+J9lCpeB0Nxf+wwL8/NaquXn2bGND+Ta4M
NLUlQdPDylPP3lhEigz/cceva7yQZOU1rvjFqVx3h6fOPpdY/A9qpgICVBdPy5AV
TZhUn57dlX0MyHUm+vH4UNcCVn2w1TSJPedGoNCnz5pq3ogZtmEpEx3Rp1YfOIcB
6aPBP1aD4/mJT3vbave67ISduXzjMvXSCv5PXLnafHYnMIV3H+AdzHcwLx5LWbAw
82C77xZ3zohVc6QchQDPLLQbcT24AQEoF92KK+VlauXQSRiSlgL8ITPiO2LvRWK8
OFulr8fSgmz2E3A16RW/z11d9rlCp+tn7Ccs1GPn6ixAnvL6x05gJhQlKpVmVvBc
RwCmHVgYUhcz7dHMHAyTs9kI4HE+OrHzSAD7EtmqSzFX1cJ+LB9/jf3VjuTQq+0t
xKSdgDGhfjI=
=45Pi
-----END PGP SIGNATURE-----

--=-pfbJ9BHQJJJWHGSoxxn2--
