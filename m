From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 11/17] i40e: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:04:33 -0700
Message-ID: <1396119873.2287.33.camel@jtkirshe-mobl>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
	 <de7e007ad0078a6e6eaee0a3a677097b00fa02c3.1396090802.git.romieu@fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZM/7XPbuhE4aCHfcs1+a"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38846 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbaC2TEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Mar 2014 15:04:34 -0400
In-Reply-To: <de7e007ad0078a6e6eaee0a3a677097b00fa02c3.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZM/7XPbuhE4aCHfcs1+a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-03-29 at 12:26 +0100, Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 18 +++++++++---------
>  1 file changed, 9 insertions(+), 9 deletions(-)

Thanks Francois, I have added your patch to my queue.

--=-ZM/7XPbuhE4aCHfcs1+a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTNxlBAAoJEOVv75VaS+3OHnEQAI3xnmsxeCID1IYfv228u0Mt
gyudG+T1ZtFb5fwWiCqpwj3r1OJ8/rzR44gk6dzFdgjLj+cBBBD4fI3ZzmhmuEUk
HuPz006IH6i4qj4KIO3JHnItcCvJa89dLqimumAyT+JxTC1C7+r4fn3Qx6478YZ0
f2yd/lrnkj2VojoP+9R0OD1eBHmSTFGWf7h/uXfTare8DZZRogsoGflfhcMaaur+
wvG01xszbKvoZwyxbnZzMelueA2gmOe/PYsUsq7IsOm/19Zb5Nbrx8wuSN2angUE
vvuOAuKBYk+I9t5v6VXA2DdDb2OZjfJShayyy2iUTJHIpDMmWdsaOfcTWihy2tPq
Ni5JKJl4jugrQnRIF0O9ghdYbvDLja/N4UJ6lEpaYKgAv9aTitqOctgJr7diYxWN
P96uVSHN4f6sQztGd5dlF4FQVgLxzYoHLOmFuIDHSZlBYtcMTEqwS4x5vLBLmEtn
I0ac37ozKFjudfwXRXjt0tCDM4gQ7xOH7zcGC4Uv4zzfGsbWrkZ23uVpYnU99fcX
ATKRl66q3FTK+54ihU0vqGE32jVbSKrWhMRW9mzyN29Di/xNCZHzFjIylaJaOgLG
oGgtWaZIhLYcZ8I1YX7dRqMdyMEu3XBEP9ky1WvjgMNDPwtM36X0YVCzwpQ2nNj4
/kIyr8pique4ERZQi70v
=pYmF
-----END PGP SIGNATURE-----

--=-ZM/7XPbuhE4aCHfcs1+a--
