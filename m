From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] batman-adv:Make the function batadv_is_my_mac bool
Date: Thu, 11 Jun 2015 07:53:04 +0200
Message-ID: <55792240.7040301@meshcoding.com>
References: <1433989533-30587-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="9gTnF6mtLX9dRp5O2QxwJwliO85mJSd85"
Cc: mareklindner@neomailbox.ch, sw@simonwunderlich.de,
	davem@davemloft.net, b.a.t.m.a.n@lists.open-mesh.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:26472 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbbFKFzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 01:55:12 -0400
In-Reply-To: <1433989533-30587-1-git-send-email-xerofoify@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9gTnF6mtLX9dRp5O2QxwJwliO85mJSd85
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Nicholas,

On 11/06/15 04:25, Nicholas Krause wrote:
> This makes the function batadv_is_my_mac bool now due
> to this particular function only returning either one
> or zero as its return value.
>=20
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>

NAK.

we already have ("batman-adv: main, Convert is_my_mac() to bool") in
net-next that does exactly the same. I guess you did not pull the latest
changes before writing this patch?

Cheers,


--=20
Antonio Quartulli


--9gTnF6mtLX9dRp5O2QxwJwliO85mJSd85
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVeSJEAAoJEOb/4TMchkvfmqUP/183aLW7L69kngRDMdeXoR+O
kIghnYAnakndcpKLtABMDtscmvKcRMmc2XHqgUeooKMYmoGO4YBwKtb6RhXL2KM1
cClVc4TFXaEktD8yQZsfYwiRrdHAuc6cpNtrsFKiEx+3NokZe8OArQg/UGTaqmQf
8wI0J+4BXzCeX2ayHzEZhBJajKz9cBZb4724uT8trNgI76ThlSnXNpCbBifoUTIk
SqM6uf6FasXjaK/ocPzYqHm6bbEebaL2PsNXvdnC7oyTEGS1EiYcjJvfnRhcK/Kr
0I9fcSqoM0jhPwHZNLxbrQlkcMMTXy8aa4kS9A7Biwn8CVyKyHIuPPiEtEj/7Z2N
s8h0/yBTMknnGoAq0yqS5lvlNfoZ5FoNNyNNVTdbTQtNu3qp8LnadPwGRF2Ok1/U
ynYoKwpSqKK8Hoyu/tjct15+6ij0RpAZmq8tXvDIHpNpXnPU2duHfmx0bRvxg+eX
L19KNtifRlfKX5M/YO/H5HxENw3o48TMGQC4DB3mCi1695qM41B5cQl1a1NYNRHu
VDp1/fH8AzaLhe5DXfOghL8L9JwHFKjjVU3fjuajp/EBjler5Q5H/B3uNxNuYfAz
PBENuFaQG0TycNR2++v+2GofhAtriyMZRStBG6Ucb+cpwNK6oMPp0wU74hz+1v/K
TmtEZZ/hNkm3BYXvO3Wq
=sBDq
-----END PGP SIGNATURE-----

--9gTnF6mtLX9dRp5O2QxwJwliO85mJSd85--
