From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 05/17] ixgb: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:03:01 -0700
Message-ID: <1396119781.2287.26.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <73d3fb2312cec80d7891f8da2f7089b8c4752f9f.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-994/DoIEP/BUy2ymWZhT"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28053 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752095AbaC2TDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:03:03 -0400
In-Reply-To: <73d3fb2312cec80d7891f8da2f7089b8c4752f9f.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-994/DoIEP/BUy2ymWZhT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-994/DoIEP/BUy2ymWZhT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxjlAAoJEOVv75VaS+3OGRIQAI5UtLj1AElJjbzbH87VOzYM
KEg0iQUn9n2aa+8sSmMPv8wouOhOLnwL7HLZciCvJrCjTbSSvoZYjebBzgvE2NZN
j6Jc6QgjdQ7ijJp02QdGBJNYkWBvMsyBAXW2ug6C1GxXd/qshjtMITlBBeSno0h4
iT3SZVg9jAZjg5PJzwoRx7eB72SzNaElmf29jnBXpQCXett+QmaExxlK9ofF5VO9
KIdPoPp/oueWgP4m3eCj56rGOAg6N3UaxtRPMq5Lt317LOyOfAcuJs5ePzKkQ3+1
hbYhJyALYnbM6nGR5rMAOYFfJE54nvGFU4MFqacFAMu3EJdy819zq6FgUtwiKNxB
fMg1Bv4La8SZrmGKTHdoxy7aE7ZGemNZh7xCIxyXoO4UJP0oiwNe4kX9WUWTeAAy
uF+AR4hxDS1Eg/GdvCs8oICmaSSvUO1xryXfYf8+Z85l4+RtWPZ5IntAodsu2Y59
LZC8u4b3e8ckfV+qOG7USWZ6NiEbHKtowJNl1fv+JppaqkiciVrgg/oejThxrScP
Fr4y4Pm8MhIHIsncPsPXjl//4Tytk2PsKNd6yGB8+jxqRpP5t+G6dO5Ki5nTiF/v
vfa3FUlGKnvdXF2JJmOY5YUMj9uHMX7FWdMmC5uQmd25A0tsYBMAEUTzhjmT+ze2
n/8fv82pCJSA0GcWsb7a
=otd+
-----END PGP SIGNATURE-----

--=-994/DoIEP/BUy2ymWZhT--
