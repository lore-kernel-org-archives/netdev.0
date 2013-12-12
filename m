From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] igb: make local functions static and remove
 dead code
Date: Thu, 12 Dec 2013 12:18:17 -0800
Message-ID: <1386879497.2204.87.camel@jtkirshe-mobl>
References: <20131212120916.688140d9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-EPsI6ioRCnmzS5pYzxq7"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21752 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751526Ab3LLUS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 15:18:29 -0500
In-Reply-To: <20131212120916.688140d9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EPsI6ioRCnmzS5pYzxq7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-12-12 at 12:09 -0800, Stephen Hemminger wrote:
> Make local functions static, and remove unused
> e1000_write_sfp_data_byte.
>=20
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c |    6 +++---
>  drivers/net/ethernet/intel/igb/e1000_i210.c  |   18
> +++++++++---------
>  drivers/net/ethernet/intel/igb/e1000_i210.h  |    9 ---------
>  drivers/net/ethernet/intel/igb/e1000_phy.c   |    2 +-
>  drivers/net/ethernet/intel/igb/e1000_phy.h   |    1 -
>  drivers/net/ethernet/intel/igb/igb.h         |    2 --
>  drivers/net/ethernet/intel/igb/igb_ptp.c     |    6 ++++--
>  7 files changed, 17 insertions(+), 27 deletions(-)

Thanks Stephen I have added this to my queue.

--=-EPsI6ioRCnmzS5pYzxq7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSqhoJAAoJEOVv75VaS+3OeTEP/jpifXh0/e0CxhJhzoUAiBhg
L5WutEvaFgyYqUlfE1YBkuaVBbk7bg9WV7A7d3nJ0ZokWcqM8HHOJvwUJqFkzOnx
YRrrmblntf5Lwv35SaEEASkTgz8l13H2TOrPu2ireMHC5wO8+J0Ob08fmg8ulFJP
23FxxgpTWysuD05VeProjUVpXgtdEpYcH9yhQARHARyIJuKYYB/n/euFwZ8ijtnA
2GgKnJ4FdclIfgwciL6Kt9dQXwszFbocyrq4obj1HVIw91bAaCrE/hI4/0GvKlcB
hTLIeUO8nTIetkZZsIvQ7Fle5cxOxFTx8u06uFCJQ27YI1CZaJdPYE4OB6Y/H354
HSK2hahE9bhwClMh7HNe0wbefB3YJg+baZ2dmFKEQ7kJmjmnYnYJYL7bv8BbH+Nq
o2mW7dqlQdjA3yYUvB78S2/HJy7uTlv6Hq5xMbVdplr8Rw2c7yH8f+toYIE0cGvr
yqk1VUqbrmi+JBhp02CeYFgmHOiPeOy/QQowyF68ecSxzDIqhl6NvYrjLsi9KSKD
/fDgplzAdIr9Y7eWJx43bGVnDFZ4MHlgXWfBIAvAcyh0uvUbzDVAxUvKLXF5vTx1
bbtK3DKec7jbamF+so35m+1HfEIF5cXLNQdlVUpUa1DXR/KYUoB0OkyjMlh+poCP
yeW9UTxHRF5qfWcgkDde
=xwOU
-----END PGP SIGNATURE-----

--=-EPsI6ioRCnmzS5pYzxq7--
