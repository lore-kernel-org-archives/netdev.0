From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: Assign true and false to bool type variable
 instead of 1 and 0
Date: Tue, 06 Dec 2011 19:43:59 -0800
Message-ID: <1323229439.2415.23.camel@jtkirshe-mobl>
References: <4EDED071.40900@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ShIW54JysF8Dkqd2bcQ3"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26601 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754964Ab1LGDoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 22:44:01 -0500
In-Reply-To: <4EDED071.40900@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ShIW54JysF8Dkqd2bcQ3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-12-06 at 18:33 -0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
>=20
> Use true and false instead of 1 and 0 when assign value to a bool type
> variable.
>=20
> This patch is try to keep the style of driver, and according to
> David's
> suggestion on patch "e1000e: Avoid wrong check on TX hang":
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D132296931201839&w=3D2
>=20
> v2: add more description
>=20
> Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   34
> ++++++++++++++--------------
>  1 files changed, 17 insertions(+), 17 deletions(-)=20

Thanks Michael, I have added your patch to my queue of e1000e patches.

--=-ShIW54JysF8Dkqd2bcQ3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3uD/AAoJEOVv75VaS+3OsDEQAJ6Acy8afrVMU9AbyZJ3ILcd
FJOX0QB3WrXIwkBAnxSHhhZZue00subodISvQCb1/uW5xGlDBh1KPqOua8Ngdpqj
M8+bAQKE4K/7n+KbPyqCW+Rv4CVUC0d1sZajYcMKeglEKGR5VtNTqw2ELTXh9Scp
Ira3qygr6wemS87N/d5dJsiTem13FGsHUUlR/Z3g2THLlnk6bXAQtRijFThMhLBb
UOWN9+o6QSJ56LBnz9aMiFG0FdfjHaBnyPuNDsL0UkR2LE7N3FgFRpQ8lh6DPqIl
0bl3gCZQ2vi+YhK44dR2HK/ZCfANL3EDwPYwOxQ6ixU1lIZZHFdzh2jqsVcsbWqt
NuY5rRRnHIB46b/gPv0bmMCzIs78tLJRRGRK1AX7boh+ar1FfBodzX3ZlE1miPBn
sReVpzyoIE/lP2Syknld0ugVfoKpnl2LVYvtxKAYHFHGdODy9cNlVHcgexUXQtos
EtIfa/FbTl2wz6QY+e9PDqfU0F+7Z82xet6NOfwGmihR20ApUXWwUiSIL3PIFMg3
KT8G64dydwmZWKyFWH8S9Lf6E+0/kkXE0Vqo5VE1K2TtbUDNxKmVmr3GGetSf69O
81NKxWwyhHAfZ5zzoXTJOtbJ5ie+CPIP+2XJuiKs1gKJFDdxDGYcY+8BHrKRWBJY
w56v4+G0nkRSFCMJZF/C
=NV/j
-----END PGP SIGNATURE-----

--=-ShIW54JysF8Dkqd2bcQ3--
