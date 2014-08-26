From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 26 Aug 2014 13:33:24 +1000
Message-ID: <20140826133324.1f4d472f@canb.auug.org.au>
References: <20140826120511.5b5dabef@canb.auug.org.au>
	<20140825.202222.2274651017865689445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/k4q=r_g31y1U8SgX.9M1e7="; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyasevich@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:59618 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757122AbaHZDdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 23:33:33 -0400
In-Reply-To: <20140825.202222.2274651017865689445.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/k4q=r_g31y1U8SgX.9M1e7=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Mon, 25 Aug 2014 20:22:22 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> Sorry about that, I just pushed the following to fix it:
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [PATCH] mvneta: Add missing if_vlan.h include.

Thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/k4q=r_g31y1U8SgX.9M1e7=
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT/AAIAAoJEMDTa8Ir7ZwV4igP/iTQBIi5u8kL7myBMbohZcOI
ZA0ND1iJ2bZPyV6sxTfte9F01SNoFc0+mL13YnaO5ZpjB44OtWba8D7CY4nrYpvf
uGboAEfHBSr6y2wBSBXs+aK0gggt4sDiIjo05dIcO2Xbb+I3QeGNu9sYj8PV5zi5
4LkmuQbn3x23BKUNWtucVYoNt10KHBzlxDMOfa9JYlAX9A/hjyQTE6e8e5XJcVj4
SOpwLtuKPRjCbMRajofQZyljOIVamdcqNRec8YMYoD8v+fZy+8FxhBV1eWTEW6Jf
ooGqmgQlrN1wTl3c/PyEmYtNRdYxML8e0hA2Uu4CYTLAaC3zBRH2gAmAiWh3YdDD
yFHnqfMC1HFMuYlkB9HO6OfU+syK3lSk/Utz30cofXuKTam46/D+TDDEmRp8jth0
cjqceO+cjd3HEX3no07ufV+OyildYJ0WRWJZvZG9pMfuovB9WlJ+LximjnobtNHa
JnTIt0Grnefrs2WySIZMWVw8OdIE+vjQZ7o5P7myJnSPsO1/FdtE9o53uqOdqHuQ
xaxc7NwkTLWzK9vxyL+T3oSCCk+OwpwSeMjyMs7r4x+rVApjr56xTQktnxIQL2dZ
5cRKgdFjbDXgbQK8xX8999VZx8mgQ14G5LqOIitr1/So9q2dcPWQgm448zo+V6+o
GZgZT7MXGR14zCYl80ef
=CPJ5
-----END PGP SIGNATURE-----

--Sig_/k4q=r_g31y1U8SgX.9M1e7=--
