From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 10:16:48 -0800
Message-ID: <1386440208.2195.3.camel@jtkirshe-mobl>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
	 <52A36235.1040406@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wnG7MPoY3KGYK3LrPKGm"
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60112 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754624Ab3LGSQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Dec 2013 13:16:59 -0500
In-Reply-To: <52A36235.1040406@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wnG7MPoY3KGYK3LrPKGm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-12-07 at 22:00 +0400, Sergei Shtylyov wrote:
> On 07-12-2013 6:17, Jeff Kirsher wrote:
>=20
> > From: Anjali Singhai Jain <anjali.singhai@intel.com>
>=20
> > RSS can steer packets based on recognition of all
> > sorts of different headers.  Enable some more of them.
>=20
> > Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8
>=20
>     This line has no place in the upstream patches, and I'm seeing it
> in=20
> several patches of this series.

This is an internal hash id, so that we can track upstream changes back
to internal git tree changes.  I did verify that this was acceptable and
is being used in the kernel in upstream patches before pushing this
information.

>=20
> > Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_main.c | 38
> ++++++++++++++++++-----------
> >   1 file changed, 24 insertions(+), 14 deletions(-)



--=-wnG7MPoY3KGYK3LrPKGm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSo2YQAAoJEOVv75VaS+3OxbMP/1ZRPhhdTvm17dcTHTBJYDoL
q1GPsb+xC1bDM7Izvf5vFV0lH3F+Zif8hfAZfz4Rvfa9HTvfQFLQNyI83tpEig2I
NFzKB14CJXa0bpYu6kT9OnfxFrdPh45Cm7Z1+QD2jTWRRop4FtDsQG/CTDVbO2t5
d0SktrUVLaYzxRbpp3QGyNzD14MOYU+YiwpRLZEpPh6fevO6AB5a3FDPhIveUvhj
yhO8iaFGtOLZfhrCWkLPiw6jhfCHBlWzIKfcJZu6n09ole81O6/66JopFNZNPSKz
oqS2B2cv8YoEFtwem8xOhLcIui7VGMEhozlDIt4Bdrg75eExtsi5gDGEy2W9A64H
YEhDb4LP+FYJ3xfa3VivzQmWBku58UIPK9XUM4kO2prAwmaaQjvvphCvPm29rLjW
mgIBZIzl/vrJBMrIDtbnPU7EOGas6lVw5DuiOdEjpGCsFSq2K7w2vNg9nqrH8EA6
nxtijtQMzWVBJNrL0c/DgwoCLaARWM0AJtgwQ5R1aYvM624nxNanaNEaUZ4saDch
nu9dvM5MbA0wLuruUgvv7J/CUnGnd2M63pNLM+qa2smCfuI7XV5asLp4sduACVKe
XvQBpyKESQIMiPTJcg49ZXK1IBz/b0RCGwp8jmGnW17FqbIbhIdw5+bNcrj1vI5d
J0C/Jttnps/mr9rwxzHa
=/im8
-----END PGP SIGNATURE-----

--=-wnG7MPoY3KGYK3LrPKGm--
