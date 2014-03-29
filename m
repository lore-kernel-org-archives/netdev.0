From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 09/17] e1000: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:04:07 -0700
Message-ID: <1396119847.2287.31.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <5317eb48fee5ca58a806268ebb7726924d926834.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-miFeq/cuBrfaFgsBoVgb"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48713 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaC2TEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:04:09 -0400
In-Reply-To: <5317eb48fee5ca58a806268ebb7726924d926834.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-miFeq/cuBrfaFgsBoVgb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-miFeq/cuBrfaFgsBoVgb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxknAAoJEOVv75VaS+3Osk4P/1m3oOjSnflFtxNuFJMR56xy
l7yaBD4Fyd6B7iYEmxwrDos2L7DJ+89dir7batXuJxhMTtS5QMmLcdxDgy3A5PED
F5AH+bNOz0d1XKjCt14KwhXlNFdYrmS4JzeDaWkX/9BX3RjzkT7bbpwWPj848vvI
eSeXH9JPbs9S+S5KEQAKF4kxe6L/HmzyaZ+gQvMaP+iDmm+JnryR51RuZGBC4IWK
sRLdRZ1LkcWBYpIRPvrmQwfsLR4L1bF061utKphrUiNw0Eb3kkBvdXvFzUWQp4YX
nAAz6A1Dbz7vGD52Q25WLRVvPLaZDzT34i6qS/9F3Gv4zHd+XcxM4msqgRuZTClm
3FxLQPjRLk6HdaHI5azMwQCjDY/6dXD6umjBlm4pRYrT9DuYN8k82U+EtmflmsVC
wGLGr5wbfA9tkwjymwMMkV0yZCoRDeuQFTvQfJFq8JOUBJdsh/fDOTPWKZI8dRf2
e2v1/vU5rrJtzxfC4Z9Drhpl1JGrZsAWvS6JfdTlUf3bLmw+6CWHEPn3OsG/kVqf
sHbcw9EYRaTG77gdIRNhQzpZpWFk3egQKlDmT9ccXCY0V7KmnP2NANKhcLOgu0ML
Y8HH01CzDgDlokMRKLURwXopEZdk7WXoonAj6qM+q75pnQ2MvUbNL7k5i8Gd/ziS
BIPSNut4AqMWI1pjv3Ku
=z78S
-----END PGP SIGNATURE-----

--=-miFeq/cuBrfaFgsBoVgb--
