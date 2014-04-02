From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 1/4] e1000: remove debug messages with function
 names
Date: Tue, 01 Apr 2014 18:45:23 -0700
Message-ID: <1396403123.2230.2.camel@jtkirshe-mobl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
	 <1396399939-18420-2-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IwGN4PNpSsxI24g8LLKr"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:27286 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707AbaDBBpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 21:45:25 -0400
In-Reply-To: <1396399939-18420-2-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IwGN4PNpSsxI24g8LLKr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-02 at 02:52 +0200, Jakub Kicinski wrote:
> e1000_hw.c contains a lot of debug messages which print
> name of invoked function and contain no new line character
> at the end.  Remove them as equivalent information can be
> nowadays obtained using function tracer.
>=20
> Reported-by: Joe Perches <joe@perches.com>
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_hw.c | 124
> ----------------------------
>  1 file changed, 124 deletions(-)

Added to my queue, thanks!

--=-IwGN4PNpSsxI24g8LLKr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTO2uzAAoJEOVv75VaS+3OMcgQAKCDhmDxasO8theHc/vrOJ/f
/Rbe9IOTXPMV5uuh6z5FSPJMrspSDzDJ2JV4hWd4H7nBmQz7yEIYcLDf6sOeXJoi
lrJ6etvjzJe0wBwKx6nzYtHZlF8mNI0Bu+7yIsXtQMXdW7peCbiyjeWY8P1y6T0s
Ff0QfMQQ9nmbdqHoJ8j+MscUscOAk5pbR6BbZkH/wLbkCA3lmMOfLakjqc4vO56e
YGaAazcJc7l9iveE7KwAPqluOklioN786Gr+HwNBP2+TVib4BzkgODW8a7TzCS7U
YRo8Ij3D2CrGIG/Shmr76XV8gHfd6KWMSFSG3sUTV3ZNaVcqCnKHlheCVTlV3SUI
AUoJCP/sT2j19/Mo7XTrkyB8Pceqbjh82jvTng+kfKegBQehaxLe99PK4Z9lBDl0
0A2wsytD97dFNpeIjFfsBxfwiY/M2tW5FxiY7G9bmomt+H/U7loUJv6mcvAdHvom
602VgYpj54LNMFTUTDvponRd/LJAWqdAaCOORqtYojiVO5tnq+2u91vW0e17uNCA
kz67e1bX5Z6PCbZaE+reUuin3wK1PlBtkfZhWsR/yfAh73nYyeuaiJGRXYoepAug
hWu64u0eaMNqCZWsUwmKtLrwOxFo2OE+WUYECBxQV7xRAKa31jOb0zkjy24t/QBF
9Cwoxl6jWcp1m/JNAYbS
=pTxK
-----END PGP SIGNATURE-----

--=-IwGN4PNpSsxI24g8LLKr--
