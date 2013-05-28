From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/4] igb: add more register definitions for
 time sync functions.
Date: Mon, 27 May 2013 17:44:34 -0700
Message-ID: <1369701874.2116.136.camel@jtkirshe-mobl>
References: <cover.1369645944.git.richardcochran@gmail.com>
	 <a5df1f05bf9734924969c25879d177c9b16924ea.1369645944.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-O6WQ9EZwpyHcqcOjf2Cc"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14589 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758328Ab3E1Aoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 20:44:37 -0400
In-Reply-To: <a5df1f05bf9734924969c25879d177c9b16924ea.1369645944.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-O6WQ9EZwpyHcqcOjf2Cc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-27 at 11:21 +0200, Richard Cochran wrote:
> This patch adds missing definitions needed for implementing the
> auxiliary time sync functions.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_defines.h |   68
> ++++++++++++++++++++++--
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |    9 ++++
>  drivers/net/ethernet/intel/igb/igb_ptp.c       |    4 +-
>  3 files changed, 76 insertions(+), 5 deletions(-)=20

Thanks Richard, I will add this to my queue.

--=-O6WQ9EZwpyHcqcOjf2Cc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRo/3yAAoJEOVv75VaS+3Ox5YP+wZ/rFvGDaWIsa5Z7QF/dPOV
cVYYG48JIYhjj1VQidVCIbPE6wDBGW2CfGu0KNY2Lczy7HOgttGvnVN2EmOQ0Z/c
w6AxrGK6IerI++gyYQ1q25luEt0kXxV1xoM4EWIysIyX+2RyWhyhteYDNRNKxaEK
MiCsqsMOg0Y/0bCNUY056pLyLq/GPxdm4loROxAhoRHrk5iKCYsmgPxWy/IIh0Er
VNRt188GT9tDzf5C3P+RRp+5Nnbh0RyiwxrZMGcAaKQLHo4jmwf65hWhJkT5TaKy
Ic0wUdf/fZEsZOuM3RtVDgOdjjhnnAvg+08/F2yzNWPepblQ2sh/dB1CQEqSRdlU
r5GpolHwHBqe2w9NfJzoUK2Xil8NLyzogta8k7gkpKR8pcVVJ62HtPqzUd8cLnY3
9Ufv/+vFeRWalH0+Rf4sGI35DVAhdlVSM9C+DOHfqTEib3RTHAh/oxa1p2171zzg
IUnAAdd2x1gQHk8+blJZTvRSZz8k9eZFXK+BgfKWGR/L1viuYcbzxSBz/WJ5maaz
wMKJ1T0LbXZhaUGTBPkX+b7ABqYBazZIS+6Nl/vkqOqKelRFpu/9CfhahSlgk4Wg
dx2aD2l56hu/G6Puqi3mlP2bU1lSI8YcmtNe7Hzhc58NG66GGsioJATgaHXDJQZK
lZ7ft/XuPV/GTFKzhYg/
=cAI7
-----END PGP SIGNATURE-----

--=-O6WQ9EZwpyHcqcOjf2Cc--
