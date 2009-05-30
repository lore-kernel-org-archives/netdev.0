From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/2] cxgb3: Add Aeluros 2020 phy support
Date: Sat, 30 May 2009 04:21:40 +0100
Message-ID: <1243653700.3818.0.camel@deadeye>
References: <20090529075823.30669.28885.stgit@speedy5>
	 <20090529075829.30669.41488.stgit@speedy5>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-+Qj654UzQ52g+d6Z5lnf"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53581 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151AbZE3DVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 23:21:47 -0400
In-Reply-To: <20090529075829.30669.41488.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+Qj654UzQ52g+d6Z5lnf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-05-29 at 00:58 -0700, Divy Le Ray wrote:
[...]
> +	/* TWINAX EDC firmware */
> +	static u16 twinax_edc[] =3D {
> +		0xd800, 0x4009,
> +		0xd801, 0x2fff,
> +		0xd802, 0x300f,
> +		0xd803, 0x40aa,
> +		0xd804, 0x401c,
[...]

Use request_firmware() please.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-+Qj654UzQ52g+d6Z5lnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQBKIKZA79ZNCRIGYgcRAtJ9AJ9bKMQLwEA66DrI6GysxEKJDAlwIQCfVNI9
Y4oZTGxbQy1OsvYhka/rpps=
=Puty
-----END PGP SIGNATURE-----

--=-+Qj654UzQ52g+d6Z5lnf--
