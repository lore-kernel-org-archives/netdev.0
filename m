From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next] i40e: Fix dependencies in the i40e driver on configfs
Date: Tue, 03 Mar 2015 12:42:25 -0800
Message-ID: <1425415345.2556.85.camel@jtkirshe-mobl>
References: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yYNOwoTVHVKAVQl/yq3h"
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5633 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753AbbCCUmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 15:42:25 -0500
In-Reply-To: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yYNOwoTVHVKAVQl/yq3h
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-03 at 12:38 -0800, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>=20
> Module dependencies are broken in the case where CONFIG_I40E=3Dy and
> CONFIG_CONFIGFS_FS=3Dm.  This fixes the broken dependency.
>=20
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/Kconfig | 9 +++++++++
>  1 file changed, 9 insertions(+)

This is to fix the current compile issues, I will continue to work with
the i40e development team to address Dave's concerns expressed earlier
in using configfs.

--=-yYNOwoTVHVKAVQl/yq3h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9hyxAAoJEOVv75VaS+3OsgwP/RRoIz8DqOAeqtHlCxRCzjhb
hcMZ+fw1CIXus8Utw9n7CSsUpBIoyblmCHcg2f46RH4/G2Wig7s9eR2ZdYwjoOcI
NbggHsFOdpB5qK9sJ1H4FXaW+IUFP4qApqXCibsK6Nu3g7M/9dZqjS/vXWhrbZNG
IkiJg/VU7jYBeonah5qe4QOmNIEcAGSBlu29NOi2NFl8PAAR47Yh0yj6xVG++IiH
G6hWV/1LLTCmmM4XYZle3sy+BL5o42VdwRhsaUtEThPcGbGYBvbsUevm71Orsd+S
B4e6ENO8ztMo6YQp+/yCHuxHakRTlhs18ubL3pY4O3OuCIouXY2L0bo/Nyks8Fnk
AuKUgr5y2iNVFCmqI3520bxsHoT5mX0xUAeEuxc5uABmYMf2rawspTVRGagM0zD/
EcBm2OLmni7yNKel90BGWVwfMneM27dAlHUozyfybRlra+bjH46U+Pds3ot4w1SV
iWN+z/X4AHS6HlRA57xwBfEC+r5hXX5tcg/RUHWY91ZDgRz0ovpQTyD+fkD+NkM8
FLEJtO+MZZeywdV1fDsJr5qRiAPOnFWYu1WS0aUjYUT3s8yCyvNiRaGUvhhdzgDa
gSIw2Qins6UKwkTxvbl6+OuoMXEItppRj2XZ31vN2f0wp3QdNvvtDLCy1trJ+4LM
dNjU2ziSGJDWA5yH+PMv
=sjqM
-----END PGP SIGNATURE-----

--=-yYNOwoTVHVKAVQl/yq3h--
