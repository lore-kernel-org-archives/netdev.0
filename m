From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 06/17] ixgbvf: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:31:15 -0700
Message-ID: <1396121475.2287.46.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <3c17d6be148052aa3d3dcc31197e833fa5c20b5b.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-sOdQ2WD1RhA3mRk8yyXG"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53442 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751591AbaC2TbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:31:17 -0400
In-Reply-To: <3c17d6be148052aa3d3dcc31197e833fa5c20b5b.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sOdQ2WD1RhA3mRk8yyXG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 16 +++++++---------
>  1 file changed, 7 insertions(+), 9 deletions(-)

Just noticed the title should be "igbvf: ..." since there is no ixgbvf.
Francois, I have fixed up this patch in my queue.

--=-sOdQ2WD1RhA3mRk8yyXG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNx+DAAoJEOVv75VaS+3OpNAP/2lBvdlqs0pX8f8ami6zZ0BK
EFT89NPobT86qAfcvFnW6nx1iDCxus9rSpARev+v3ANURs/NEq8uTt72/JmsJjtS
Vn9Y/e7IPYrlAhJFLVL+/mgIvhbMENdz2TGERd0hDHz0ElgAaZuvQUQ+5uRk+0dl
Kv/HXBNgI+VMrZ9+ROnKuJyUwYTLlmy5i5l8iZv8cc2c0+9K+oqAfWK3hmoe+xqZ
r+ffWWNAkSfSjwWY+TJz2CCHVW1KE1Q8pwi9xCLpTdYkkXTdYpP1rK2bxSLm1ILZ
XGd0/RKch5r8dlgnNBWzRzlmn0a3YTZNk6eZr1+2N0/2zTyvefMHPLu5/7Doohmj
XCuWHATY/NBggvtHZwSSbvXD4gkz/+t/S+VtlZyukwI5nuAXDaco500p0nQZ5xzY
4vasyog+YRK8iXsWpSntyrL0/Um/Wa7J00ElNMSPHL0T1YRrSju+M+5MV13SMxan
EaTiAa/koHKol4roELwSRgXaye7VJWciulkmQ50Zm+xhrLGbHB/6FWYcRv0SZi8K
EQabsUlPEca31wUDqIOXvn4I86AjKdlF5j++/isF9v+i2GHgljZKPZ8Dnfd6PmMa
W6Cy/mTt124t71rD210a4dm7jpwdhG7yJJ74UCBBbIWxaa4sgMV8eH0KCmjoqHFR
oNJnMYOXzdrh1QSVQCQ8
=v3ce
-----END PGP SIGNATURE-----

--=-sOdQ2WD1RhA3mRk8yyXG--
