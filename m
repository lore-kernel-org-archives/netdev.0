From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH] net: sh_eth: avoid NULL pointer dereference in ring setup
Date: Wed, 2 Mar 2016 18:11:14 +0100
Message-ID: <20160302171114.GB5439@katana>
References: <1456932370-4143-1-git-send-email-wsa@the-dreams.de>
 <56D71909.2020503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8P1HSweYDcXXzwPJ"
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56D71909.2020503@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--8P1HSweYDcXXzwPJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> >Reported-by: coverity (CID 1056464)
> >Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>
>=20
>    Will you respin or should I?

Please go ahead. You have more knowledge about this driver, so you will
be faster.

Reported-by: Wolfram Sang <wsa+renesas@sang-engineering.com>


--8P1HSweYDcXXzwPJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJW1x6yAAoJEBQN5MwUoCm2f4YP/RK+M6cJbDu0CkdyqbN/db+8
pKj3MkxY5MbODjoHlCxLCtuAj9WGp360/X4MDBbgxME2Me8oXwUjOvtYlroO1yxP
YyngNGZ0haWjWheuoLSE6+IH0kfr5zUflGdJnQFEAlSMDmVTWn1+q6TallhVVPqh
5hpYdm6oGWBSVZQTeBpotwt89iuG9bZnSCz9oeBqvgV68jB2Qwdjl3+1r2amZS16
1KwN7sf5wRAHDqTPwgnNx/G4O8fQzAnW/v9LUjTdhJqqlhux/xrG8C9cAYfpH8KP
Jzn2xWNmllKF1AmvwPnJadpHDeUGNfeNM7EtEaUT4KHwBVeYMXLnhkhf6r2KNi5h
6uV7BdenDO92pZKB1mx9lgfPbs5FKPakBx+VHqukFYCs5CjjCUmR7HesXTwxzmtd
YhPTR9Z40ma803kLmuyTnyv/CLLzBr3x3q9U59BGAniVSBOoPYCHM4HT27PEbit7
49gxGYpbnQnH2EjVJvANx/8C9vurMS5YxHZsiDasIciP+IYy1HmhUlfSmZE0tQsj
BzOL2r8HqDgFjSej6mM2gikkJIeIto/zrBosYXPlHMYJOtVnoPG9akn3phUGwu7T
nKyYGjU6xGAdlzIG/BuDk+RCIo5NBS3MsYHWLh1jYPiOoCFESMkk55zR0JF4wyrD
QkcsUd5S+BZ5EI+hAwD9
=TWSn
-----END PGP SIGNATURE-----

--8P1HSweYDcXXzwPJ--
