From: Andrey Panin <pazke@pazke.donpac.ru>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sun, 1 Jun 2008 11:25:28 +0400
Message-ID: <20080601072528.GA786@pazke.donpac.ru>
References: <4824D1E1.10007@sun.com> <20080509.154538.28321777.davem@davemloft.net> <4835A007.7020601@krogh.cc> <20080522.104145.193700531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Cc: jesper@krogh.cc, Matheos.Worku@Sun.COM, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754222AbYFAHbo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080522.104145.193700531.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 143, 05 22, 2008 at 10:41:45 -0700, David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Thu, 22 May 2008 18:32:07 +0200
>=20
> > Does this mean that I can expect every 10G card to have this limitation
> > under Linux?
>=20
> For now, yes.  The transmit path itself in the generic network
> device layer is where the serialization comes from.

BTW does this problem affects bonded interfaces ?

> I'm travelling now for 3 weeks so I won't be able to work on
> this stuff until I get back.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--=20
Andrey Panin		| Linux and UNIX system administrator
pazke@donpac.ru		| PGP key: wwwkeys.pgp.net

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIQk7oIWZCBzwS8mkRAhDiAJ42bLiTUpsMP4qvh7l1FOupVYHKDwCgy+el
KajYYDoPgUCb7jsYEX6vSNs=
=CeWm
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--
