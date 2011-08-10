From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [linux-firmware v2 1/2] rtl_nic: update firmware for
 RTL8111E-VL
Date: Wed, 10 Aug 2011 13:54:20 +0100
Message-ID: <1312980860.2591.1267.camel@deadeye>
References: <1312978979-1808-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-OBxF+ZFQ8OeEOxPpqWu1"
Cc: dwmw2@infradead.org, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57729 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754108Ab1HJMy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 08:54:28 -0400
In-Reply-To: <1312978979-1808-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OBxF+ZFQ8OeEOxPpqWu1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-08-10 at 20:22 +0800, Hayes Wang wrote:
> Updated firmware with stability fixes.
> Version: rtl8168e-3_0.0.1.
>=20
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  WHENCE                |    2 +-
>  rtl_nic/rtl8168e-3.fw |  Bin 2804 -> 3264 bytes
>  2 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/WHENCE b/WHENCE
> index 4b88f1f..a463417 100644
> --- a/WHENCE
> +++ b/WHENCE
> @@ -1626,7 +1626,7 @@ File: rtl_nic/rtl8168d-2.fw
>  File: rtl_nic/rtl8105e-1.fw
>  File: rtl_nic/rtl8168e-1.fw
>  File: rtl_nic/rtl8168e-2.fw
> -File: rtl_nic/rtl8168e-3.fw
> +File: rtl_nic/rtl8168e-3.fw (Version: rtl8168e-3_0.0.1)
[...]

Please don't write the version in yet another way.  It should be:

File: rtl_nic/rtl8168e-3.fw
Version: 0.0.1

Or, if you insist on duplicating the name in the version:

File: rtl_nic/rtl8168e-3.fw
Version: rtl8168e-3_0.0.1

Ben.


--=-OBxF+ZFQ8OeEOxPpqWu1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATkJ/fOe/yOyVhhEJAQq/6w//Rbl3Fn/7E2hogZ1qBujiUe+k8XIg805M
unCUK3rVKc/trg+duuc+D9o8AdG21hN3UsmAKMNtAlYPBUCBoVP9qPF2D6iE/pJw
CoCbnw+7lKzoi8WFOd3ULH2U0ZL4dzD61mc+UswlQtT0rSTLRW4SxbFyOTtwtD3l
BnlPrFt+HRonciRxdixxhnBSOYtsB1FERRheuws/YUJ48i6a9dZu1nbn3V6m0k5A
3XNYWpWkK+N5K14s5t3O+UZ2be3o0I3Zxvgv7eOHH5S8F6KMWms9jzgOPgpwc4lD
ZymAFi8OGlvbFifnUG8UP8Wki7hK6eItZk4w8SiK9U7hawQL0xKooDUAYHpuq7Is
MgP7YvzeOsM5Bt4kmu/qHvjwJ/kaYjQ2a1KN8AIEXcGd3xApf4dwtKlg/UVNzIgH
DU9mP4QtH2mDj378xNEF2Rq9wZwgF5K2gZSgOCVBdOKBe4pxb1YYhcSX9CC6+ofU
jK46rGYgR8Rfz6z5z+981A7/smVWmTZ9pz/oq2G881pbPvgkKv70TIWh9NXlFNDK
PWvgqtK6BJhdd48AuwXakFQFUZl/qrK7N0mxaRyK6WoXfMHlLvxAftLHFpWb8k/M
eO18Cy93RHwHMwUutGiNA4hxktRWsm/VK0LxKFZGNFepjlkrPMnb298vH/eZLHFy
lullkx8hekU=
=lVh9
-----END PGP SIGNATURE-----

--=-OBxF+ZFQ8OeEOxPpqWu1--
