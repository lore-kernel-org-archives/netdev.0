From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [trivial PATCH resend 2/2] ixgbe: use PCI_VENDOR_ID_INTEL
Date: Fri, 20 Jul 2012 00:14:04 -0700
Message-ID: <1342768444.2616.25.camel@jtkirshe-mobl>
References: <1342767729-17788-1-git-send-email-jdmason@kudzu.us>
	 <1342767729-17788-3-git-send-email-jdmason@kudzu.us>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9u46Gw8iKLhPDsJuy8zl"
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


--=-9u46Gw8iKLhPDsJuy8zl
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

Same goes for this patch as well (not being trivial).

I already have several patches submitted for Dave against ixgbe
currently and I am not sure if there would be any issues with this patch
applying on top of the currently submitted patches.  I will verify this
applies cleanly with no issue to my current net-next tree before I send
my ACK.

--=-9u46Gw8iKLhPDsJuy8zl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQCQU8AAoJEOVv75VaS+3OYXAP/Asm544fY0W1VrVAjixS0Efn
RgUNq7y5v+ytiTwT2Wy6OMpdpLU/kgwXx/2F9cjPZhRhmcAN+0UTEtAg7EsqHE2d
BxnG+gg0Qx6mkxr+L9385caY6TrXj5a0T9Ch4QhlaTSCP7CF8pxhxXQ5ZS1PoXvb
KLuKezeLF3OrvR1109Uu6jiAD8hxzEOPgYU6XUDLbXKHXIrCHT7Ck/G/FKfi2fbI
AnP8TapgjYhpGx2+dwcT/g45nWTeKg9qnnQqZrQmp7L9SkwIdPo4FL3RYvPny5XX
5Fwk1OH2OOxpmbszF25/Vf3y6KFH/fsMvBlrLfPNDy0Th4KvGemH1n0WvdxPMRxT
BW6OAGtownoXhpgKN6bTZOVzNUdjvGRnv5Z7MhyMGimRvmTC+v+V6GlHKnk6uoZG
f6PwXs65jfWbNXxa5OFS1BN4pd/DR5vQVPG6g87OrkCR5P8eq7p2LvqfVtDpoyfO
7E+fvlFPdIeGfD/shQTNAFIEh+nuU91GKrfsg4/3ZBPXBYtgcyR93CvxhAksXZIt
rzKi4J8aZSJMm1dVGk7FyaEuFjcTmsDFZ7rSEq1fmggs4RJYptUAhS1j9dTHUgGp
toZQRfdmZJaiWdqRWLcI7oi9jhcQmQOm2SYq1/qEN22QapKRD263+jglt/aNyrvB
ObiSy8Q1X7b/JI2NLtQQ
=AZPZ
-----END PGP SIGNATURE-----

--=-9u46Gw8iKLhPDsJuy8zl--
