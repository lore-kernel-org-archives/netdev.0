From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH resend 2/2] ixgbe: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 00:17:09 -0700
Message-ID: <1342768629.2616.27.camel@jtkirshe-mobl>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
	 <1342767729-17788-3-git-send-email-jdmason@kudzu.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZckCw4wa40WjLMLN+Jbo"
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1342767729-17788-3-git-send-email-jdmason@kudzu.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ZckCw4wa40WjLMLN+Jbo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-07-20 at 00:02 -0700, Jon Mason wrote:
> Use PCI_VENDOR_ID_INTEL from pci_ids.h instead of creating its own
> vendor ID #define.
>=20
> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |    4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |    8 ++++----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  |    3 ---
>  3 files changed, 6 insertions(+), 9 deletions(-)=20

This applies cleanly against my current net-next tree and looks fine.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-ZckCw4wa40WjLMLN+Jbo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCQX1AAoJEOVv75VaS+3O0gwP/2xO+VT6fZUmeTNMCsm2KE0I
XfjnBF/D6tbgaaAFjcBbSAzvh+XZxw4uTYtPAqXE4ugZpTC3+/HXoCRTs9L40fyZ
sbo3sQibzUwa3FFKrDEQWFLAKGOOQo1wELEK5aTlYHn4mcjhLEX+HsKApgu+q2Vl
RUDBQQ8rUIqKHrG+ZOhojDM9Vw6pTG9VlfTXnkDbDr87q6ku1g5QgagLO8qaiO0t
t/k8zQKlYRetusXTNrwpYTVCVEahfG7hJuMmsaWCCogLT4qbvGZ1Aiw/ygZM9/l6
Dff+ysvFxeRol6PS4AHh2cuQ5tavKG0BfFgvTr4oN1OCKS/PTXD6jj5brMCN8Lvt
XP0EgxeaUPYYdrS+qXgUtAw/hWlGRAMp5rJmVu55Dpn2K3EHdWrWCKg5l94egi2u
Bl9nFoeXjgPbkSMhrJ1zcO+X+5H/zNnmxtAgKkIEB72AM1LJijllKT8QIdXMBqMe
H6vjTKBEJAWcWEoGyoicyqdF7YLSgX4NiELSUPbGUkNDgauE/WWqHkjBmj0tsl8g
Vin2D3+ghpHObm3MP6M0P7QlCl5HxElcvYhnNxKBec2OV+UvrQLovCykxYqp3tXl
w+4xQG4BLxfj0bLBcGsY1On1M8IgG7KngcVuFJYnbp9cNj+lwdk0UvkoWKTHTOWf
OkXOQ7dK5gE+5/K0lN/E
=qbc7
-----END PGP SIGNATURE-----

--=-ZckCw4wa40WjLMLN+Jbo--
