From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH resend 1/2] ixgb: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 00:11:17 -0700
Message-ID: <1342768277.2616.22.camel@jtkirshe-mobl>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
	 <1342767729-17788-2-git-send-email-jdmason@kudzu.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JRF3GNWKTgG/tfwV2Qpe"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41816 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106Ab2GTHLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2012 03:11:18 -0400
In-Reply-To: <1342767729-17788-2-git-send-email-jdmason@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JRF3GNWKTgG/tfwV2Qpe
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
>  drivers/net/ethernet/intel/ixgb/ixgb_hw.c   |    5 +++--
>  drivers/net/ethernet/intel/ixgb/ixgb_ids.h  |    5 -----
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |   10 +++++-----
>  3 files changed, 8 insertions(+), 12 deletions(-)=20

Like I said before, I do not consider this patch "trivial" so it is
interesting that you submitted again as a trivial patch.  At least you
CC'd netdev like I asked.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-JRF3GNWKTgG/tfwV2Qpe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCQSVAAoJEOVv75VaS+3OulQP/jtHWbY4eqYpvFHutpiO87he
d4lsTrCFQHNA4YQvO5JMISxrwAZZJ9EhZBxQhkIJqVVcWerYmuKW3cYhmeLmc1pu
aou+A1/togbpad1EgKL/Ph17dKVlcLGVT5ZPe03jtjCxYfiYmKNkBebubP1vK7v9
8O45WwkDHbBeVNvdpYTFgnek5qSlt2xc5Qbk5mspj1H6wmU42b4+clDmGrSoqw2A
AHGoNmpPs76FxL/InfXtjqasP36jkJmxErr3myK9xv3RHR79WB45bHOuDsRHANwn
m0fuYybaXTmv/CdVHRrUHgocr3LrGxB0lRbIhzsSp/xxvcnMoxOeotMT9gdcIJQB
FduBENqQIiC9CRpbHo2AgGxXOSyBbc9oNY2IGbNP03cLTNWzewLbfQUR6scW4xkK
frPscMabZYkp6ftI+rL5cPpcCnKdcaIr+RlJU1OutALkw1NPRDg8IXlcHII9HE/h
tLUndoA5ZzCXoG4kiW08CP3Q5On0KhfqvFZ7J8JF8u6rc8Kz+TAwtiIqJ0NG2g6y
Y6H68fCcjSh7K05WMwdPdHrbbF/k/8UN+qEoVfQAQR1wYWbh9yJO47XL98e/DZ2y
LH4dJVX23uMeVXKAZSLodqE8GnCs+88NutdjhYKJAdS+qs4CCGwd2xV+QTe7unDI
Cijb3p2Pr4LCxoqkxdvo
=G4ST
-----END PGP SIGNATURE-----

--=-JRF3GNWKTgG/tfwV2Qpe--
