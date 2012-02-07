From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgb: Remove unnecessary defines, use pr_debug
Date: Tue, 07 Feb 2012 15:32:27 -0800
Message-ID: <1328657547.2782.41.camel@jtkirshe-mobl>
References: <1328645837.15787.3.camel@joe2Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rT1PQczuc6BB+HEmjPUF"
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44135 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066Ab2BGXc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 18:32:56 -0500
In-Reply-To: <1328645837.15787.3.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rT1PQczuc6BB+HEmjPUF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-02-07 at 12:17 -0800, Joe Perches wrote:
> Use the current logging styles.
>=20
> Remove unnecessary _DEBUG_DRIVER_ and PFX, use pr_debug.
> Coalesce format.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb.h      |   12 ------------
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |    4 ++--
>  2 files changed, 2 insertions(+), 14 deletions(-)=20

Thanks Joe!  I have added the patch to my queue.

--=-rT1PQczuc6BB+HEmjPUF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJPMbSLAAoJEOVv75VaS+3OjogP/3yTL23uzECqsbHndk2FBEV1
zV0YRroggobT+uD9bSCBFCaMJDSY7c1Lm4c+keH1qBLAmjxQye3P7qAghM8YTqoF
CK6NMQ6/+fprRSaQASlmnwEGjWBeU7B7NhDGbP9ResbYHHQUJnTxAi/HuPYxbjcP
9QyRuYt+zCbiFiSYNboIINswWY87E1ybSwJ2noAQyGwcPrEDlj8b715s1ya92BsS
n0FbQvQjwGpW6YQHMXNcvuJO14u8V0Nc3liBbmPTdkcdTVoz8Zj64s0kNw2H+GBZ
B/XS55qffNjQdAoJ2PUJjcWG29aQPX3WnVUUUpVLBcpS7uRezZs2eSDi0IeG1s7h
1Ypq/LyZB3vHH58fPe9DqBwAhBxmEPXXUXOsRV64xqE5USmUBqNBGIwP0eFqu9+R
+ag9dhU59ctcAJCHYVeX7Z7rwNmvEHToGt+6Rlx0nFWDQqJdc7j6FMtJudVHgi0W
80/Kuumy49cj3YVpzmFIYEU+C/jkISUFcU7bxXw8RmeF9e0nzcBwyKLHiduKcH8n
Qw1L4TDIQBjghSLOOsUEUMpleDAaMWe/id0GMqWZ6PQBmZogyT21I8x1Zc10pzGB
+nS7D20kjvFuErta2E7UKLGSfBS2XkTWRgn0aAZSwMFfNcseRBjbiKgfEEhms0IH
RW+QnNho49o9ugR6cX+N
=JwLT
-----END PGP SIGNATURE-----

--=-rT1PQczuc6BB+HEmjPUF--
