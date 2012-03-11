From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 2/2] e100: enable transmit time stamping.
Date: Sun, 11 Mar 2012 01:56:07 -0800
Message-ID: <1331459767.27038.6.camel@jtkirshe-mobl>
References: <cover.1331400160.git.richardcochran@gmail.com>
	 <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dxmwuVat0FazKFDQ7VTi"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12455 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752266Ab2CKJ4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Mar 2012 05:56:09 -0400
In-Reply-To: <33c61d135f4fd62e5128466633302414ead0092e.1331400160.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dxmwuVat0FazKFDQ7VTi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2012-03-10 at 18:29 +0100, Richard Cochran wrote:
> This patch enables software (and phy device) transmit time stamping.
> Tested on an old PIII laptop with built in NIC.
>=20
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/e100.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)=20

Thanks Richard, I will add the patch to my queue.

--=-dxmwuVat0FazKFDQ7VTi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPXHa3AAoJEOVv75VaS+3OuvoP/36aRPmh5wOh4CbKDzUyMPYz
SCb5mDIfWPbDYe5b5/qu1TTnXn9ZZdWuc95Gv4+aZZuUk+A12sPQVWQd+NYP2hRJ
0NXHjKDye/bclu/wg/Tyzl7+5rxnwkqfe9Zalml4o2IZ0uML0O5RtHeZb1rvdcxO
2cilrgKxcH2uCrOWilkzxvzIVYARLjH46jVJHsxc3TXBsSs1YaWHZf315VDNPUmD
LPjEnxWniZWtqXCsqLVA3LMoepYXVjtWMHY6fpqhzIoFCd1KCFc+zMKMPx/RCD9b
LV0u+9vUlw13126qAC0oyxj3g/xvNnzTXwHiF7eO4p/F2CHBL8rNmMLvD2AYKSLc
/bwF+2rGLsEfb1/BtA0zfmNSu173KbMx3rrLAVU7xNDRsdKL4iwT7rWvj6CXtK/+
yMFl9NydjFzPhPq4llKESn1Mx4IA6vccMcxer2jRZwiLJzpqEz3yRgceO2GvO6Ao
RF4arfWlhIbc7kkiRXQf/ImQqGP92B9NBCCWC87Rnd+f8/2zGTE8MtUSNl9cBZyl
B94EtIW4nYpCWCSwIdovujbNj+RROYGOGAGgvf1hEpp4Dv0YWJjyXTY28iytODAB
FiF07/BVldbZ58dTD1zkWqNKY9S6EXn3CIvZ6XUe2RGk04kNLxrL8f5bCJg6ddLf
vWLA5Vld/Cv9yap8dvRA
=DtgS
-----END PGP SIGNATURE-----

--=-dxmwuVat0FazKFDQ7VTi--
