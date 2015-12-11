From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 3/4] i40e: Kernel dependency update for i40e to
 support geneve offload
Date: Thu, 10 Dec 2015 21:45:11 -0800
Message-ID: <1449812711.3194.95.camel@intel.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
	 <1449598334-97674-4-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-go4S+PSJbl2UYx75OHII"
Cc: jeffrey.t.kirsher@intel.org, Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14014 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976AbbLKFpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Dec 2015 00:45:18 -0500
In-Reply-To: <1449598334-97674-4-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-go4S+PSJbl2UYx75OHII
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-12-08 at 10:12 -0800, Anjali Singhai Jain wrote:
> Update the Kconfig file with dependency for supporting GENEVE tunnel
> offloads.
>=20
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
> =C2=A0drivers/net/ethernet/intel/Kconfig | 10 ++++++++++
> =C2=A01 file changed, 10 insertions(+)

--=-go4S+PSJbl2UYx75OHII
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWamLnAAoJEOVv75VaS+3O1WQP/3msoGFvaUSjDQ9LebJJ1agm
GL73Wj+3Wcq0d4ZxB8g2d5pJV4Vr4Ge60YLKCFgE98tSG27SAtaBZyq010m/Zr0W
ikuetjktHfz3GAoMz7G224VZ8XxlhesyU9bngZ9JTJQUdrc7O8MrSUPcakgjFpT0
aKpJHWcCUZIuo4OgPAqUDOI4CdyNQWUNW1lpw3v5GiQP3qInK0KoxA+SKJRK7wag
eKPj5ghldYS7v4ODXMuj136AqBjeFT49FeFA/p4BTglUR7+EKQOQRvCSASv0gA/Q
JUbVV1LK5vhDSImSqhzaf2MZuvmF3rx0lljs6+7L29BlpfOfiVFVWfON7oR+cZuE
L2tQqka+z/K3sGOPqaZK59pyVPzKURDOkFMwhfvn0lXMOxRy5/f0vTGH0E5zQ8is
QddXOIZ1eTUnwtKYI0kkh2qa9/uJ9Q3taqshW+vdxevhzLrLGdUTXVRMNuu0OUgJ
tD4SwD/g3SkiBsM2rr0QRkn8fJX9+IsDgtnl2TtPUEIf9CEIpKNYVQmjnER6K7Zb
Ap/aji6cSndLQV2ejeqO3VXQDbYuHKndEFZWr4p8DMsIMU6Zu2gS4cGVNBnSKuLY
GNUikvVv+iunUbA8mRXtAosgYAIrCTH15T/nGi19Mnshgr10tATUcFIWNJdhbJhV
johPpcY9ogAEFdTi6umw
=/vbX
-----END PGP SIGNATURE-----

--=-go4S+PSJbl2UYx75OHII--
