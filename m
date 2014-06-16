From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -next 12/26] intel: Use dma_zalloc_coherent
Date: Mon, 16 Jun 2014 14:15:06 -0700
Message-ID: <1402953306.2247.0.camel@jtkirshe-mobl.jf.intel.com>
References: <cover.1402863904.git.joe@perches.com>
	 <98cd6b066087e10da2dbf2a92080197a40a5e4ec.1402863905.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Wx3P/8cQ5s26qFOQCdVv"
Cc: linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <98cd6b066087e10da2dbf2a92080197a40a5e4ec.1402863905.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Wx3P/8cQ5s26qFOQCdVv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-06-15 at 13:37 -0700, Joe Perches wrote:
> Use the zeroing function instead of dma_alloc_coherent & memset(,0,)
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)



--=-Wx3P/8cQ5s26qFOQCdVv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTn15aAAoJEOVv75VaS+3OaSMP/j2/Dcsam+xILQUiptBHNDxP
7m38P5wHRLqqKty6nXFug/ndvKGBmNO+8OzMKrZ9A37ep+sYSeJGaD+GrZ20masK
M4GQk2LLtWrtWV68ODvmDcCFR0A8m3WDBo5/LsTqY8tOmARS30ed5IfNdpZMAcdS
lmwxQ67sGG12/4/hfla10ni7ae0UhFgyxlg2iUT7zYmjQAH0girsf+0d8rVMlwm8
BG4PaYpFf3ZzelnvxAN25ZPMU/VGXD6Sqe2vxSC3VWJk9q0MDOTIw+f2wgCsL7qF
HPPCsMMtSwQdlRF1+vtxZJKQXrAE4PLGqIC+Ru8iuRNxcRXWY/7yEb3MJpr2vOIt
ukLk0URwqo1D6iFOLnlN0uxJ2FmDFIPlqODgVwHud/dIBCsJm7bSseOl+++bVBeI
86AKmo4Ohyx5wUSLZsK9I7Kd1f9eEOhOUquTO0dDAjAndMfE46Ifvxmmcb9jLTy9
pt4aGDhNXtLq6NoP5w6UuRZ5/ZbNHqtqIesPgEm52LCGhbsRxJWxY1TZ/rusg0o9
dhQV/NJXHVhnD/qjcYIxsrz/Hc/BSyxK5Xjih0tsLxN9P2cySK0GgMOdlJignDDf
pVJQshZ9l/4fKpA8Q8mn/Wjx8gyoT3mQdemIjYuJZHCHyS5Fe5URhkOdDHMfXhKS
dmHk5okTTBAwdwPO609W
=pwP3
-----END PGP SIGNATURE-----

--=-Wx3P/8cQ5s26qFOQCdVv--
